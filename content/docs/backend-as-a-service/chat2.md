---
title: Chat - Messages
description: Chat 2 - Messages
weight: 4
---

{{% hint warning %}}
This section is still work-in-progress.
{{% /hint %}}

# Chat - Messages

In the previous part of the chat app series we implemented password based
authentication with a login and a register page.
In this part we will extend the project, so you can send and receive messages
from other users.
You know, to make it an actual chat app.

Open your project from last part or download the [reference
solution](https://github.com/fluttered-book/chat/tree/authentication).
Let's get started!

## Supabase project

Before writing any new Flutter code there are just a couple of small changes to
be made to the project in Supabase.

### Change the schema

We are going to extend the schema with an additional table for messages.

![Visualization of schema](../images/chat-tables-dark.png)
_What the resulting schema will look like._

1. Open Supabase dashboard
2. Navigate to your project
3. Go to "SQL Editor"
4. Run the following SQL

```sql
create table if not exists public.messages (
    id uuid not null primary key default gen_random_uuid(),
    profile_id uuid default auth.uid() references public.profiles(id) on delete cascade not null,
    content varchar(500) not null,
    created_at timestamp with time zone default timezone('utc' :: text, now()) not null
);
comment on table public.messages is 'Holds individual messages sent on the app.';
```

### Real-time query

Supabase supports real-time queries.
It allows clients to listen for changes on query result, so it gets notified
when a row in the result change.
No more hitting refresh or periodic polling for your app to fetch fresh data as
you would with plain HTTP.
Just listen on a result set and changes will automatically get pushed to your
app.

To use the real-time functionality we need to first enable it.
This is done on a per-table basis.

Run the following in "SQL Editor".

```sql
-- *** Add tables to the publication to enable real time subscription ***
alter publication supabase_realtime add table public.messages;
```

{{% hint info %}}
It can also be enabled with a from the Supabase dashboard.
{{% /hint %}}

## Implement chat

Now for the implementation in Flutter.
Open up your project.

### Models and mapping

We need to add a couple of model classes that match the database tables.
I think the simplest way is to use
[dart_mappable](https://pub.dev/packages/dart_mappable).

Add the package.

```sh
flutter pub add dart_mappable
flutter pub add build_runner --dev
flutter pub add dart_mappable_builder --dev
```

Then define the models.

`lib/models/massage.dart`

```dart
import 'package:dart_mappable/dart_mappable.dart';

part 'message.mapper.dart';

@MappableClass()
class Message with MessageMappable {
  final String id;
  final String profileId;
  final String content;
  final DateTime createdAt;

  Message({
    required this.id,
    required this.profileId,
    required this.content,
    required this.createdAt,
  });
}
```

`lib/models/profile.dart`

```dart
import 'package:dart_mappable/dart_mappable.dart';

part 'profile.mapper.dart';

@MappableClass()
class Profile with ProfileMappable {
  final String id;
  final String username;
  final DateTime createdAt;

  Profile({required this.id, required this.username, required this.createdAt});
}
```

Simple enough right?
Hold on, there is one small caveat we need to work around.
The data we get from Supabase use
[snake_case](https://en.wikipedia.org/wiki/Snake_case) for column names.
And the naming convention for Dart is
[lowerCamelCase](https://en.wikipedia.org/wiki/Camel_case).
It creates an issue since the two styles don't match.
We can solve it by instructing `dart_mappable` to use a different case style
for the mapper it generates.

Create a file `lib/models/models.dart` with:

```dart
import 'package:dart_mappable/dart_mappable.dart';

const caseStyle = CaseStyle(
  head: TextTransform.lowerCase,
  tail: TextTransform.lowerCase,
  separator: '_',
);
```

Now we are at it, we could also add some exports for the models which will
allow us to import both with just a single `import` statement in other files.
Just add these two lines to the top of the file.

```dart
export 'message.dart';
export 'profile.dart';
```

Now you can import both models with just `import
'package:chat/models/models.dart';`, instead of `import
'package:chat/models/massage.dart';` and `import
'package:chat/models/profile.dart';`.

Replace `@MappableClass()` in each of the models with
`@MappableClass(caseStyle: caseStyle)`, so it will use our newly defined case
style.

Then generate the mappers with:

```sh
flutter pub run build_runner build
```

### Service

Now that we have our models we can extend our Supabase abstraction with some
methods for streaming messages, fetching profiles and submitting new messages.
Add these method definitions to `ChatService`.

```dart
  Stream<List<Message>> messageStream();
  Future<void> submitMessage(String text);
  Future<Profile> fetchProfile(String id);
```

And implement them in `SupabaseChatService`.

```dart
  @override
  Stream<List<Message>> messageStream() {
    return _supabase
        .from('messages')
        .stream(primaryKey: ['id'])
        .order('created_at')
        .map((maps) => maps.map((map) => MessageMapper.fromMap(map)).toList());
  }

  @override
  Future<void> submitMessage(String text) async {
    final myUserId = _supabase.auth.currentUser!.id;
    await _supabase.from('messages').insert({
      'profile_id': myUserId,
      'content': text,
    });
  }

  @override
  Future<Profile> fetchProfile(String id) async {
    final data =
        await _supabase.from('profiles').select().eq('id', id).single();
    return ProfileMapper.fromMap(data);
  }
```
