---
title: Chat - Authorization
description: Chat 3 - Authorization
weight: 5
---

{{% hint warning %}}
Work-in-progress
{{% /hint %}}

# Chat - Authorization

{{% hint info %}}
This guide is based on [Flutter Authorization with
RLS](https://supabase.com/blog/flutter-authorization-with-rls).
I'm making my own version to better fit the narrative I want to convey in this
book.
{{% /hint %}}

## Introduction

Currently, the chat is open for everyone.
If you put an app like this on the app store, and people start using it.
Within long the chat would be flooded with horrible things.
You know like scammers, drug dealers, bots and people posting what they had for
lunch.

What the app needs is private chat rooms.
Such that people can discuss meaningful topic in peace.
All the important stuff in life.
Like how to defeat Gwyn, Lord of Cinder etc.

We create [Row Level
Security (RLS)](https://supabase.com/docs/guides/database/postgres/row-level-security)
policies to enforce that rooms are kept private.
RLS allows you to make access rules directly in the database.

Silly full-stack developers, spending so much time writing back-ends.
All they need is Postgres (and Supabase).
If you think about it, most back-ends are just fancy wrappers around a
database.
And Supabase is a featureful generic wrapper, so it can be used for many
different kinds of projects.
🤯

_♫ I'm all about the BaaS, no back-end ♫_

## Schema changes

We need to introduce a new rooms table.
Run the following from SQL Editor.

```sql
-- *** Table definitions ***

create table if not exists public.rooms (
    id uuid not null primary key default gen_random_uuid(),
    created_at timestamp with time zone default timezone('utc' :: text, now()) not null
);
comment on table public.rooms is 'Holds chat rooms';

create table if not exists public.room_participants (
    profile_id uuid references public.profiles(id) on delete cascade not null,
    room_id uuid references public.rooms(id) on delete cascade not null,
    created_at timestamp with time zone default timezone('utc' :: text, now()) not null,
    primary key (profile_id, room_id)
);
comment on table public.room_participants is 'Relational table of users and rooms.';
```

Then alter messages so it references a room.
If you have any existing messages in the database they won't have a `room_id`,
so we need to delete those.

```sql
delete from messages where 1 = 1;

alter table public.messages
add column room_id uuid references public.rooms(id) on delete cascade not null;
```

We also need to enable real-time changes for the new rooms table.

```sql
alter publication supabase_realtime add table public.room_participants;
```

Finally, we add a function to create a new room.

```sql
-- Creates a new room with the user and another user in it.
-- Will return the room_id of the created room
-- Will return a room_id if there were already a room with those participants
create or replace function create_new_room(other_user_id uuid) returns uuid as $$
    declare
        new_room_id uuid;
    begin
        -- Check if room with both participants already exist
        with rooms_with_profiles as (
            select room_id, array_agg(profile_id) as participants
            from room_participants
            group by room_id
        )
        select room_id
        into new_room_id
        from rooms_with_profiles
        where create_new_room.other_user_id=any(participants)
        and auth.uid()=any(participants);


        if not found then
            -- Create a new room
            insert into public.rooms default values
            returning id into new_room_id;

            -- Insert the caller user into the new room
            insert into public.room_participants (profile_id, room_id)
            values (auth.uid(), new_room_id);

            -- Insert the other_user user into the new room
            insert into public.room_participants (profile_id, room_id)
            values (other_user_id, new_room_id);
        end if;

        return new_room_id;
    end
$$ language plpgsql security definer;
```
