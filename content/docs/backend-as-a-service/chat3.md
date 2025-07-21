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

## Models

Moving over to the Flutter side.
Since we've added new tables to the database, we need to define a couple of
more models to match.

`lib/models/room.dart`

```dart
import 'package:dart_mappable/dart_mappable.dart';

import 'models.dart';

part 'room.mapper.dart';

@MappableClass(caseStyle: caseStyle)
class Room with RoomMappable {
  final String id;
  final DateTime createAt;
  final String otherUserId;
  final Message lastMessage;

  Room({
    required this.id,
    required this.createAt,
    required this.otherUserId,
    required this.lastMessage,
  });
}
```

`lib/models/room_participant.dart`

```dart
import 'package:dart_mappable/dart_mappable.dart';

import 'models.dart';

part 'room_participant.mapper.dart';

@MappableClass(caseStyle: caseStyle)
class RoomParticipant with RoomParticipantMappable {
  final String profileId;
  final String roomId;
  final DateTime createdAt;

  RoomParticipant({
    required this.profileId,
    required this.roomId,
    required this.createdAt,
  });
}
```

For the sake of being consistent, we should also add exports for the new models
to the top of `lib/models/models.dart`.

```dart
export 'room.dart';
export 'room_participant.dart';
```

Remember that you need to run code generation to create the mapping code.
Open a terminal in your project folder and run:

```sh
flutter pub run build_runner build
```

Delete previous output if you get asked about it.

## Service

We should also adjust our abstraction service to match the new stuff we've
added to the database.

Open `chat_service.dart` and add the following to the `ChatService` abstract class.

```dart
  Stream<List<RoomParticipant>> participantStream();
  Stream<Message?> lastMessageStream(String roomId);
  Future<String> startConversation(String otherUserId);
  Future<List<Profile>> searchProfile(String text);
```

And add the following implementation to `SupabaseChatService`.

```dart
  @override
  Stream<List<RoomParticipant>> participantStream() {
    return _supabase
        .from('room_participants')
        .stream(primaryKey: ['room_id', 'profile_id'])
        .map(
          (maps) =>
              maps.map((map) => RoomParticipantMapper.fromMap(map)).toList(),
        );
  }

  @override
  Stream<Message?> lastMessageStream(String roomId) {
    return _supabase
        .from('messages')
        .stream(primaryKey: ['id'])
        .eq('room_id', roomId)
        .order('created_at')
        .limit(1)
        .map((maps) => maps.isEmpty ? null : MessageMapper.fromMap(maps.first));
  }

  @override
  Future<String> startConversation(String otherUserId) async {
    final roomId = await _supabase.rpc(
      'create_new_room',
      params: {'other_user_id': otherUserId},
    );
    return roomId;
  }

  @override
  Future<List<Profile>> searchProfile(String text) async {
    return _supabase
        .from('profiles')
        .select()
        .textSearch('username', text)
        .limit(12)
        .order('username')
        .withConverter(
          (profiles) => profiles.map(ProfileMapper.fromMap).toList(),
        );
  }
```

After login (or registration) the user will be presented with a list of rooms
representing previous conversations they have had.
They will also be given the ability to create a new room (start a new
conversation) with another user by searching for their name.

The `participantStream()` method a stream of participants.
The RLS policy restricts the result to only participants in rooms for which the
current user is also a participant of.

The `lastMessageStream()` returns a stream with the latest message that have
been submitted in a given room.

We can use `startConversation()` to start a new conversation calling the
`create_new_room` database function.

{{< hint info >}}
RPC is short for <a
  href="https://en.wikipedia.org/wiki/Remote_procedure_call">Remote Procedure
Call</a> which is general term for calling a function (aka procedure) on
another computer or process in a distributed system.
{{< /hint >}}

We will use `searchProfile()` to search for users to start a conversation with.

## Overview of conversations

We need to add a new page from where the user can select a room.

![Screenshot of RoomsPage](../images/chat-rooms-page.png)

We will use the cubit pattern as usual.

### Rooms state

We start by defining the state.

`lib/rooms/rooms_state.dart`

```dart
import '../models/models.dart';

sealed class RoomsState {}

final class RoomsLoading extends RoomsState {}

final class RoomsError extends RoomsState {
  final String message;
  RoomsError(this.message);
}

final class RoomsLoaded extends RoomsState {
  final List<RoomAggregate> rooms;

  RoomsLoaded({required this.rooms});

  RoomsLoaded withRoomUpdate(
    bool Function(RoomAggregate friend) which,
    RoomAggregate Function(RoomAggregate friend) update,
  ) {
    final newRooms = [...rooms];
    final index = newRooms.indexWhere(which);
    if (index < 0) this;
    newRooms[index] = update(newRooms[index]);
    newRooms.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    return RoomsLoaded(rooms: newRooms);
  }
}

class RoomAggregate {
  final String roomId;
  final String profileId;
  final DateTime timestamp;
  final Message? lastMessage;
  final Profile? profile;

  RoomAggregate({
    required this.roomId,
    required this.profileId,
    required this.timestamp,
    this.lastMessage,
    this.profile,
  });

  RoomAggregate copyWith({Message? lastMessage, Profile? profile}) =>
      RoomAggregate(
        roomId: roomId,
        profileId: profileId,
        timestamp: lastMessage?.createdAt ?? timestamp,
        lastMessage: lastMessage ?? this.lastMessage,
        profile: profile ?? this.profile,
      );
}
```

To build a nice UI we need information across multiple tables.
We use `RoomAggregate` to hold all this information.

The `RoomLoaded` state has a helper method which will make a copy of the state,
but with a change to a `RoomAggregate`.
It just makes it slightly more convent when we get around to write the code to
handle adding, removing and updating rooms.
More on that later.

### Rooms cubit

Then for the cubit.

`lib/rooms/rooms_cubit.dart`

```dart
import 'dart:async';

import 'package:chat/common/chat_service.dart';
import 'package:chat/common/widgets.dart';
import 'package:chat/models/message.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../models/room_participant.dart';
import 'rooms_state.dart';

class RoomsCubit extends Cubit<RoomsState> {
  final ChatService _service;

  late StreamSubscription<List<RoomParticipant>> _participantSubcription;
  final Map<String, StreamSubscription<Message?>> _lastMessageSubscription = {};

  RoomsCubit(this._service) : super(RoomsLoading());

  Future<void> initialize() async {
    _participantSubcription = _service.participantStream().listen(
      (participants) {
        final rooms =
            participants
                .where(
                  (participant) => participant.profileId != _service.userId,
                )
                .map(
                  (participant) => RoomAggregate(
                    roomId: participant.roomId,
                    profileId: participant.profileId,
                    timestamp: participant.createdAt,
                  ),
                )
                .toList();
        emit(RoomsLoaded(rooms: rooms));
        for (final room in rooms) {
          _getLastMessage(room.roomId);
          _getProfile(room.profileId);
        }
      },
      onError: (_) {
        emit(RoomsError(unexpectedErrorMessage));
      },
    );
  }

  @override
  Future<void> close() async {
    Future.wait([
      _participantSubcription.cancel(),
      ..._lastMessageSubscription.values.map((sub) => sub.cancel()),
    ]);
    return super.close();
  }

  Future<void> startConversation(String otherUserId) async {
    await _service.startConversation(otherUserId);
  }

  void _getLastMessage(String roomId) {
    _lastMessageSubscription[roomId] = _service
        .lastMessageStream(roomId)
        .listen((message) {
          if (state is! RoomsLoaded) return;
          final newState = (state as RoomsLoaded).withRoomUpdate(
            (room) => room.roomId == roomId,
            (room) => room.copyWith(lastMessage: message),
          );
          emit(newState);
        });
  }

  Future<void> _getProfile(String profileId) async {
    final profile = await _service.fetchProfile(profileId);
    if (state is! RoomsLoaded) return;
    final newState = (state as RoomsLoaded).withRoomUpdate(
      (room) => room.profileId == room.profileId,
      (room) => room.copyWith(profile: profile),
    );
    emit(newState);
  }
}
```

The `initialize()` method will listen for changes for rooms in real-time.
For each room it will fetch the last message and profile (username) of the
other user.
Notice how the `.withRoomUpdate()` helper method is being used.

Whenever working with subscriptions its very important that the cancel the
subscription again when no longer needed.
Otherwise, your application will have memory leaks.
Here we cancel the subscription when the cubit is closed, which will happen
when the `BlocProvider` for it is no longer part of the widget tree.

### Rooms page

`lib/rooms/rooms_page.dart`

```dart
import 'package:chat/common/chat_service.dart';
import 'package:chat/common/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:timeago/timeago.dart';

import '../chat/chat_page.dart';
import 'rooms_cubit.dart';
import 'rooms_state.dart';

class RoomsPage extends StatelessWidget {
  const RoomsPage({super.key});

  static Route<void> route() {
    return MaterialPageRoute(
      builder:
          (context) => BlocProvider<RoomsCubit>(
            create:
                (context) =>
                    RoomsCubit(context.read<ChatService>())..initialize(),
            child: const RoomsPage(),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Rooms')),
      body: BlocBuilder<RoomsCubit, RoomsState>(
        builder: (context, state) {
          if (state is RoomsLoading) {
            return Spinner();
          } else if (state is RoomsError) {
            return Center(child: Text(state.message));
          } else if (state is RoomsLoaded && state.rooms.isEmpty) {
            return Column(
              children: [
                const Expanded(
                  child: Center(
                    child: Text('Start a chat by tapping on available users'),
                  ),
                ),
              ],
            );
          } else if (state is RoomsLoaded && state.rooms.isNotEmpty) {
            return ListView.builder(
              itemCount: state.rooms.length,
              itemBuilder: (context, index) {
                final room = state.rooms[index];
                final name = room.profile?.username;
                final lastMessage = room.lastMessage;
                return ListTile(
                  onTap:
                      () => Navigator.of(
                        context,
                      ).push(ChatPage.route(roomId: room.roomId)),
                  leading: CircleAvatar(
                    child:
                        name == null ? Spinner() : Text(name.substring(0, 2)),
                  ),
                  title: Text(name ?? 'Loading...'),
                  subtitle: Text(
                    lastMessage?.content ?? 'Room created',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: Text(format(room.timestamp, locale: 'en_short')),
                );
              },
            );
          }
          throw UnimplementedError("$state");
        },
      ),
    );
  }
}
```

For the `RoomsLoaded` state it builds a `ListView` of rooms.
To make it nice and user-friendly it shows an avatar for the username from
profile table and the last messages for messages table.
That's why we needed the `RoomAggregate` class.

### Logout

I think it is fitting to place a logout button on the `RoomsPage` instead of
having it on `ChatPage`.

Create the file `lib/rooms/logout_button.dart` with:

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../account/register/register_page.dart';
import '../common/chat_service.dart';

class LogoutButton extends StatelessWidget {
  const LogoutButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () {
        context.read<ChatService>().logout();
        Navigator.of(
          context,
        ).pushAndRemoveUntil(RegisterPage.route(), (route) => false);
      },
      icon: Icon(Icons.logout),
    );
  }
}
```

Then add `actions: [LogoutButton()]` as parameter to the `AppBar` in
`lib/rooms/rooms_page.dart`.

Finally, remove the existing logout button from the `AppBar` in
`lib/chat/chat_page.dart`.

## Room specific chat

When tapping on a room we want to show the chat messages for only that
particular room.

![Screenshot of ChatPage](../images/chat-chat-page.png)

We therefore have to make some changes to the ChatPage and related classes.

Open `lib/chat/chat_page.dart` and change the beginning of the class to:

```dart
class ChatPage extends StatelessWidget {
  final String roomId;
  const ChatPage({super.key, required this.roomId});

  static Route<void> route({required String roomId}) {
    return MaterialPageRoute(builder: (context) => ChatPage(roomId: roomId));
  }
```

We need to pass the `roomId` to the cubit, so it can listen to messages for only
that room.
Find the code `ChatCubit(context.read<ChatService>())..listenForMessage()` and
change it to `ChatCubit(context.read<ChatService>(), roomId:
roomId)..listenForMessage()` so the `roomId` gets passed along.

In `ChatCubit` change the constructor to:

```dart
  ChatCubit(this.service, {required this.roomId}) : super(ChatState.empty());
```

Then add a field for `roomId`:

```dart
  final String roomId;
```

And change `listenForMessage()` to:

```dart
  void listenForMessage() {
    service.messageStream(roomId).listen((messages) {
      emit(state.copyWith(messages: messages));
      for (var message in messages) {
        _loadProfileCache(message.profileId);
      }
    }, onError: (e) => state.copyWith(error: e.toString()));
  }
```

We also need to adapt `ChatService` to only stream messages for a single room.
So open `lib/common/chat_service.dart` and change the method signature for
`messageStream()` in `ChatService` abstract class to:

```dart
  Stream<List<Message>> messageStream(String roomId);
```

Replace the implementation of `messageStream()` in `SupabaseChatService` with:

```dart
  @override
  Stream<List<Message>> messageStream(String roomId) {
    return _supabase
        .from('messages')
        .stream(primaryKey: ['id'])
        .eq('room_id', roomId)
        .order('created_at')
        .map((maps) => maps.map((map) => MessageMapper.fromMap(map)).toList());
  }
```

Go back to `lib/rooms/rooms_page.dart`.
In the `ListTil` change `onTap` to:

```dart
onTap: () => Navigator.of(context).push(ChatPage.route(roomId: room.roomId)),
```

That leaves us with some navigation errors for `ChatPage` which we will fix
next.
Instead of going directly to the `ChatPage` when user is logged in, we will
show the `RoomsPage`.
For the files `login_page.dart` and `register_page.dart` we should
change `ChatPage.route()` to `RoomsPage.route()`.
Remember to change the imports also.

Then in `main.dart`, change `session == null ? RegisterPage() : ChatPage()` to
`session == null ? RegisterPage() : RoomsPage()`.

## Start a conversation

The app needs a way to connect with another user in a room to start a
conversation.

We will simply provide a way for the user to search for other users by their
username, then connect with them to start a conversation.
At the database level, starting a conversation means creating a room with the
two users as participants.

![Screenshot of ConnectPage](../images/chat-connect-page.png)

To implement this functionality we'll create yet another page using cubit
pattern.

### Connect state

Just like with `RoomsPage` we'll start by defining the possible state for it.

Create `lib/connect/connect_page.dart` with:

```dart
import 'package:chat/models/profile.dart';

sealed class ConnectState {}

final class ConnectInitial extends ConnectState {}

final class ConnectSearching extends ConnectState {}

final class ConnectResults extends ConnectState {
  final List<Profile> results;

  ConnectResults({required this.results});
}
```

### Connect cubit

Now for the cubit.

`lib/connect/connect_cubit.dart`

```dart
import 'dart:async';

import 'package:chat/common/chat_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'connect_state.dart';

class ConnectCubit extends Cubit<ConnectState> {
  static final Duration delay = Duration(milliseconds: 500);
  Timer? _debounceTimer;
  Future? _searchFuture;
  final ChatService _service;

  ConnectCubit(this._service) : super(ConnectInitial());

  search(String text) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(delay, () {
      emit(ConnectSearching());
      _searchFuture?.ignore();
      _searchFuture = _service.searchProfile(text);
      _searchFuture!.then(
        (profiles) => emit(ConnectResults(results: profiles)),
      );
    });
  }

  @override
  Future<void> close() {
    _debounceTimer?.cancel();
    _searchFuture?.ignore();
    return super.close();
  }
}
```

The reason for all the timer stuff, is because we want the app to search for
users as we type their username without running a query for each keystroke.

{{< hint info >}}
Debouncing is a throttling technique where you delay the execution of a
function until after a certain amount of time has passed.
It is a way to avoid triggering an action too many times in rapid succession.

The term **debounce** comes from hardware engineering.
When a button is pressed it will sometimes physically bounce a bit of the
contact plate, thereby registering a multiple presses.
Debouncing is simply setting a short delay before another press can be
registered.
{{< /hint >}}

When `search()` is invoked it will wait 500 ms before actually hitting the
database.
If the method is called several times over a very short timespan then it will
cancel the previous delays, such that it only emits a new state with the result
for the last invocation.

If the user wants to find "Alice" then we don't want the app to make a new
query for each letter that the user types.
Instead, we will way for a pause of 500 ms before making a query, which would
hopefully mean that the user has finished typing.

There are other ways to implement debouncing.
If you want to be really fancy you could use something like
[RxDart](https://pub.dev/packages/rxdart).
However, I've found it to be excessive to add another library just for this
small piece of functionality, so we use a
[Timer](https://api.flutter.dev/flutter/dart-async/Timer-class.html) instead.

### Connect page

Time to implement the connect page itself.

`lib/connect/connect_page.dart`

```dart

import 'package:chat/common/chat_service.dart';
import 'package:chat/common/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../chat/chat_page.dart';
import 'connect_cubit.dart';
import 'connect_state.dart';

class ConnectPage extends StatelessWidget {
  const ConnectPage({super.key});

  static Route<void> route() {
    return MaterialPageRoute(
      builder:
          (context) => BlocProvider<ConnectCubit>(
            create: (context) => ConnectCubit(context.read()),
            child: const ConnectPage(),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Connect")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(hintText: "Username"),
              onChanged: (text) => context.read<ConnectCubit>().search(text),
            ),
          ),
          Expanded(
            child: BlocBuilder<ConnectCubit, ConnectState>(
              builder: (context, state) {
                return switch (state) {
                  ConnectInitial() => Center(
                    child: Text(
                      "Who do you want to start a conversation with?",
                    ),
                  ),
                  ConnectSearching() => Center(child: Spinner()),
                  ConnectResults() => ListView.builder(
                    itemCount: state.results.length,
                    itemBuilder: (context, index) {
                      final profile = state.results[index];
                      return ListTile(
                        onTap: () async {
                          final roomId = await context
                              .read<ChatService>()
                              .startConversation(profile.id);
                          if (!context.mounted) return;
                          Navigator.of(
                            context,
                          ).pushReplacement(ChatPage.route(roomId: roomId));
                        },
                        leading: CircleAvatar(
                          child: Text(profile.username.substring(0, 2)),
                        ),
                        title: Text(profile.username),
                      );
                    },
                  ),
                };
              },
            ),
          ),
        ],
      ),
    );
  }
}
```

At the top of the page there will be a `TextField` where the user can enter the
username they want to search for.
Under there will be a list of search results.
As we are waiting for results will show a spinner.

When the user taps on another user the want to chat with then we call
`.startConversation()` method the provided `ChatService` then navigate to
`ChatPage` for the room that gets created.

How do you get to the `ConnectPage`?
Well, maybe we should add button for it on `RoomsPage`.

Open `lib/rooms/rooms_page.dart` and add a floating action button inside the
`Scaffold` as indicated below.

```dart
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Rooms'), actions: [LogoutButton()]),
      // --- Start of new part ---
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(ConnectPage.route());
        },
        child: Icon(Icons.person_add),
      ),
      // --- End of new part ---
      body: BlocBuilder<RoomsCubit, RoomsState>(
      // ...
      )
    );
  }
```
