---
title: Chat - Messages
description: Chat 2 - Messages
weight: 4
---

{{% hint warning %}}
This section is still work-in-progress.
{{% /hint %}}

# Chat - Messages

## Schema

We are going to extend the schema with an additional table for messages.

![Visualization of schema](../images/chat-tables-dark.png)

```sql
create table if not exists public.messages (
    id uuid not null primary key default gen_random_uuid(),
    profile_id uuid default auth.uid() references public.profiles(id) on delete cascade not null,
    content varchar(500) not null,
    created_at timestamp with time zone default timezone('utc' :: text, now()) not null
);
comment on table public.messages is 'Holds individual messages sent on the app.';
```

Supabase supports real-time queries.
It allows clients to listen for changes on query result, so it gets notified
about changes.
No more hitting refresh or periodic polling for new results.
Changes are automatically pushed to interested clients.

To use the real-time functionality we need to first enable it.
This is done on a per-table basis.

```sql
-- *** Add tables to the publication to enable real time subscription ***
alter publication supabase_realtime add table public.messages;
```

_Note: It can also be enabled from the Supabase dashboard._
