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

You know what the app needs?
Private chat rooms, so people have meaningful conversations in peace.
All the important stuff in life, like how to defeat Gwyn in Dark Souls and so
on.

To make sure anybody not invited can't access private rooms, we will utilize a
feature in Supabase called [Row Level Security
(RLS)](https://supabase.com/docs/guides/database/postgres/row-level-security).
It allows us to create policies for who can access what at the database level.

To learn more about Row Level Security [**watch
this**](https://www.youtube.com/watch?v=Ow_Uzedfohk).

Those other silly full-stack developers, spending so much time writing
back-ends.
All they need is Postgres (and Supabase).
If you think about it - most back-ends are just fancy wrappers around a
database.
Supabase is a generic feature rich wrapper, that you can customize for many
different kinds of projects 🤯.

_Of course, I'm kidding here.
There is definitely a need for a back-end in many situations._

## Schema changes

To make private chat rooms work, we need to customize the schema a bit.
We need to introduce a new rooms table.
Run the following from SQL Editor for your project in [Supabase
Dashboard](https://supabase.com/dashboard/).

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

Next, we need to alter messages table, so it references a room.
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

Finally, we add a [database
function](https://supabase.com/docs/guides/database/functions?queryGroups=language&language=dart)
to create a new room with the current user another user as participants.

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

## Authorization with Row Level Security (RLS)

To make it writing our RLS policies a bit easier we are going to create a small
helper function to check if the current signed-in users is a participant of the
room.

```sql
-- Returns true if the signed-in user is a participant of the room
create or replace function is_room_participant(room_id uuid)
returns boolean as $$
  select exists(
    select 1
    from room_participants
    where room_id = is_room_participant.room_id and profile_id = auth.uid()
  );
$$ language sql security definer;
```

Let's enable RLS for our tables and define policies for them.

```sql
-- *** Row level security policies ***

alter table public.profiles enable row level security;
create policy "Public profiles are viewable by everyone."
  on public.profiles for select using (true);


alter table public.rooms enable row level security;
create policy "Users can view rooms that they have joined"
  on public.rooms for select using (is_room_participant(id));


alter table public.room_participants enable row level security;
create policy "Participants of the room can view other participants."
  on public.room_participants for select using (is_room_participant(room_id));


alter table public.messages enable row level security;
create policy "Users can view messages on rooms they are in."
  on public.messages for select using (is_room_participant(room_id));
create policy "Users can insert messages on rooms they are in."
  on public.messages for insert with check (is_room_participant(room_id) and profile_id = auth.uid());
```

The syntax for creating policies is `create policy <description> on <table> for <action>
<condition>`.
Where `<description>` is a human-readable description of what the policy does.
`<table>` is of cause the table that the policy should apply to.
Action is SQL CRUD operation, so select, insert, update or delete.
Last, `<condition>` specifies under what condition the action is allowed.

{{< hint info >}}
When enabling RLS for a table then all actions on any rows of that table are
denied.
You will need to explicitly define policies that allow certain actions again
under certain conditions.
{{< /hint >}}
