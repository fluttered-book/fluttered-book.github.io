---
title: Chat - Messages
description: Chat 2 - Messages
weight: 4
---

# Chat - Messages

## Introduction

In the previous part of the chat app series we implemented password based
authentication with a login and a register page.
In this part we will extend the project, so you can send and receive messages
from other users.
You know, to make it an actual chat app.

Open your project from last part or download the [reference
solution](https://github.com/fluttered-book/chat/tree/authentication).
Let's get started!

{{% hint info %}}
Again!
This guide is based on [Flutter Tutorial: building a Flutter chat
app](https://supabase.com/blog/flutter-tutorial-building-a-chat-app).
I'm making my own version to better fit the narrative I want to convey in this
book.
{{% /hint %}}

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

### Cubit

You've guessed it.
We are going to use a cubit again.

This will be the state.

`lib/chat/chat_state.dart`

```dart
import '../models/models.dart';

class ChatState {
  final List<Message> messages;
  final Map<String, Profile> profileCache;
  final String? error;

  ChatState({required this.messages, required this.profileCache, this.error});

  ChatState.empty() : messages = [], profileCache = {}, error = null;

  ChatState copyWith({
    List<Message>? messages,
    Map<String, Profile>? profileCache,
    String? error,
  }) => ChatState(
    messages: messages ?? this.messages,
    profileCache: profileCache ?? this.profileCache,
    error: error ?? this.error,
  );

  Profile? profileFor(Message message) => profileCache[message.profileId];
}
```

A message reference the profile that have sent the message.
In a conversation you will have many messages send from the same profile.
You can easily join a message with a profile in a query.
But, you can not use join when streaming changes from a table.
We therefore have a cache of profiles in the state object.
That way, profiles can be lazy loaded as new messages arrive.
We can also check the cache to avoid loading the same profile multiple times.
Smart, right?

`lib/chat/chat_cubit.dart`

```dart
import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../common/chat_service.dart';
import '../common/widgets.dart';
import '../models/models.dart';
import 'chat_state.dart';

class ChatCubit extends Cubit<ChatState> {
  final ChatService service;
  StreamSubscription<List<Message>>? _messageSubscription;

  ChatCubit(this.service) : super(ChatState.empty());

  void listenForMessage() {
    service.messageStream().listen((messages) {
      emit(state.copyWith(messages: messages));
      for (var message in messages) {
        _loadProfileCache(message.profileId);
      }
    }, onError: (e) => state.copyWith(error: e.toString()));
  }

  void submitMessage(String text) async {
    if (text.isEmpty) return;
    try {
      service.submitMessage(text);
    } on Exception catch (error) {
      emit(state.copyWith(error: error.toString()));
    } catch (_) {
      emit(state.copyWith(error: unexpectedErrorMessage));
    }
  }

  @override
  Future<void> close() {
    _messageSubscription?.cancel();
    return super.close();
  }

  Future<void> _loadProfileCache(String profileId) async {
    if (state.profileCache[profileId] != null) return;
    final profile = await service.fetchProfile(profileId);
    emit(
      state.copyWith(profileCache: {...state.profileCache, profileId: profile}),
    );
  }
}
```

`listenForMessage()` will subscribe to messages using the ChatService.
It returns a `StreamSubscription` object what we are supposed to clean up when
the cubit gets closed.
Otherwise, we create a memory leak.

For each new message the cache is checked for a profile.
If none is found, then it will fetch the profile and append it to the cache.
The cache is really just a map of profile ID to profile.
We create a new instance of the map each time a new profile is fetched, because
states are supposed to be immutable.
There is a slight overhead to creating new map instances, so this
implementation is not viable if there are millions of people chatting at the
same time.
Premature optimization is the enemy of quick progress.
So lets just assume the app won't get millions of users overnight and move on.

## Widgets

The time has finally come where we are ready to make an actual implementation
of the `ChatPage`.
Aiming for a layout like on the picture.

![Chat page displaying lyrics from Brojob - Tuff love](../images/chat-page.png)

We need to create a couple of widgets to achieve it.

### Chat bubble

We are going to add [timeago](https://pub.dev/packages/timeago) package, so we
can easily show how long it has been since a message was submitted.

```sh
flutter pub add timeago
```

`lib/chat/chat_bubble.dart`

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:timeago/timeago.dart';

import '../common/chat_service.dart';
import '../common/widgets.dart';
import '../models/models.dart';

class ChatBubble extends StatelessWidget {
  const ChatBubble({super.key, required this.message, required this.profile});

  final Message message;
  final Profile? profile;

  @override
  Widget build(BuildContext context) {
    final isMine = context.read<ChatService>().userId == message.profileId;
    List<Widget> chatContents = [
      if (!isMine)
        CircleAvatar(
          child:
              profile == null
                  ? Spinner()
                  : Text(profile!.username.substring(0, 2)),
        ),
      const SizedBox(width: 12),
      Flexible(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          decoration: BoxDecoration(
            color: isMine ? Theme.of(context).primaryColor : Colors.grey[300],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(message.content),
        ),
      ),
      const SizedBox(width: 12),
      Text(format(message.createdAt, locale: 'en_short')),
      const SizedBox(width: 60),
    ];
    if (isMine) {
      chatContents = chatContents.reversed.toList();
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 18),
      child: Row(
        mainAxisAlignment:
            isMine ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: chatContents,
      ),
    );
  }
}
```

Show a spinner until it has the profile fetched, in which case an avatar is
shown.

Layout of the bubble is reverse if it is your own message.

### Message bar

`lib/chat/message_bar.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'chat_cubit.dart';

/// Set of widget that contains TextField and Button to submit message
class MessageBar extends StatefulWidget {
  const MessageBar({super.key});

  @override
  State<MessageBar> createState() => _MessageBarState();
}

class _MessageBarState extends State<MessageBar> {
  final _textController = TextEditingController();

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _submitMessage() async {
    final text = _textController.text;
    if (text.isEmpty) return;
    _textController.clear();
    context.read<ChatCubit>().submitMessage(text);
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.grey[200],
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Expanded(
                child: TextFormField(
                  keyboardType: TextInputType.text,
                  maxLines: null,
                  autofocus: true,
                  controller: _textController,
                  decoration: const InputDecoration(
                    hintText: 'Type a message',
                    border: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: EdgeInsets.all(8),
                  ),
                ),
              ),
              TextButton(
                onPressed: () => _submitMessage(),
                child: const Text('Send'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

### Chat page

`lib/chat/chat_page.dart`

```dart
import 'package:chat/common/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../account/register/register_page.dart';
import '../common/chat_service.dart';
import 'chat_bubble.dart';
import 'chat_cubit.dart';
import 'chat_state.dart';
import 'message_bar.dart';

/// Page to chat with someone.
///
/// Displays chat bubbles as a ListView and TextField to enter new chat.
class ChatPage extends StatelessWidget {
  const ChatPage({super.key});

  static Route<void> route() {
    return MaterialPageRoute(builder: (context) => const ChatPage());
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ChatCubit(context.read<ChatService>())..listenForMessage(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Chat'),
          actions: [
            IconButton(
              onPressed: () {
                context.read<ChatService>().logout();
                Navigator.of(
                  context,
                ).pushAndRemoveUntil(RegisterPage.route(), (route) => false);
              },
              icon: Icon(Icons.logout),
            ),
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: BlocConsumer<ChatCubit, ChatState>(
                listener: (context, state) {
                  if (state.error != null) {
                    context.showErrorSnackBar(message: state.error!);
                  }
                },
                builder: (context, state) {
                  if (state.messages.isEmpty) {
                    return const Center(
                      child: Text('Start your conversation now :)'),
                    );
                  }
                  return ListView.builder(
                    reverse: true,
                    itemCount: state.messages.length,
                    itemBuilder: (context, index) {
                      final message = state.messages[index];
                      return ChatBubble(
                        message: message,
                        profile: state.profileFor(message),
                      );
                    },
                  );
                },
              ),
            ),
            const MessageBar(),
          ],
        ),
      ),
    );
  }
}
```

In `create` function given to `BlocProvider`, we call `listenForMessage()`
immediately using
[cascade-notation](https://dart.dev/language/operators#cascade-notation).
The `listenForMessage()` method is what makes the `ChatCubit` subscribe to messages.
Without the call we would not see anything.
