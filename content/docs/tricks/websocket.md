---
title: WebSocket
description: >-
  Example of using WebSocket with BLoC pattern.
weight: 11
---

# WebSocket

Example of using WebSocket with BLoC pattern.

![Screenshot of example app](../images/websocket_demo_screenshot.png)

## Project

**[Link](https://github.com/rpede/MiniProjectSolution/)**

The project is based on an example project provided by my colleague Alex.
You can find his original [here](https://github.com/uldahlalex/MiniProjectSolution).

I've reimplemented the frontend in Flutter using
[BLoC](https://bloclibrary.dev/) to manage state changes based on events send
from the backend.

## Flutter frontend

Code is found in `flutter_frontend`.

[dart_mappable](https://pub.dev/packages/dart_mappable) is used to enhance
model classes through code generation. It helps create immutable classes,
combining features from [equatable](https://pub.dev/packages/equatable) and
[json_serializable](https://pub.dev/packages/json_serializable) with a
`copyWith` method added.

Code generation can be run with:

```sh
dart run build_runner build
```

## Getting started

If you have docker then you can start a database by running `sh setup.sh`.
Otherwise, adjust `PG_CONN` in `Api/appsettings.Development.json`.

Start backend:

```sh
dotnet watch --project Api
```

Start Flutter frontend:

```sh
cd flutter_frontend
flutter pub get
flutter run -d chrome
```

Start Angular frontend:

```sh
cd frontend
npm install
npm start
```

### Emulator

To connect to the websocket running on your own machine from Android emulator,
you will need to change the address to `10.0.2.2`.
That is because the emulator is running a full OS, therefore _localhost_
inside the emulator is different from _localhost_ on you host OS.

See [Set up Android Emulator networking](https://developer.android.com/studio/run/emulator-networking).

## How it works

### Websocket

The [web_socket_channel](https://pub.dev/packages/web_socket_channel) package
is used to connect to the backend.

You connect to a WebSocket with the WebSocketChannel class.
It provides an interface that resembles a StreamController.
Messages added to the **sink** will be sent to the connected server.
Messages sent from the server can be observed from the **stream**.
A message here is just a String.

![WebSocketChannel](../images/websocket.drawio.svg)

Read more on how to [Communicate with WebSockets](https://docs.flutter.dev/cookbook/networking/web-sockets).

The WebSocket protocol for the chat app is based on JSON events.
Each event has a `eventType`.
Events send from client start with `"ClientWants"`
Events from server starts with `"Server"`.
All events are defined in `flutter_frontend/lib/models/events.dart`.

When sending events to the server we need the serialized events to have
`eventType`.
When deserializing events from server, the `eventType` is used to determine
which class to user.

We can achieve this by adding a `discriminatorKey` to a shared base class for
all events.

```dart
@MappableClass(discriminatorKey: 'eventType')
abstract class BaseEvent with BaseEventMappable {}
```

Each event type is a subclass with a `discriminatorValue`.

```dart
@MappableClass(discriminatorValue: ClientWantsToSignIn.name)
class ClientWantsToSignIn extends BaseEvent with ClientWantsToSignInMappable {
  static const String name = "ClientWantsToSignIn";
  // ...
}
```

It allows the generated mapper to be able to deserialize to the correct
subclass based on the value of `eventType`.

If we have the following:

```dart
final event = BaseEventMapper.fromJson('{"eventType": "ClientWantsToSignIn"}');
```

Then `event` will have the runtime type `ClientWantsToSignIn`.

### BLoC

The protocol and state changes are implemented in
`flutter_frontend/lib/bloc/chat_bloc.dart`.

Bloc was chosen over Cubit.
Because we are dealing with events.

See [Cubit vs. Bloc](https://bloclibrary.dev/bloc-concepts/#cubit-vs-bloc).

### Client events

**ChatBloc** exposes methods to add events based on user interactions.
Here is an example:

```dart
  /// Sends ClientWantsToSignIn event to server
  void signIn({required String password, required String email}) {
    add(ClientWantsToSignIn(
      eventType: ClientWantsToSignIn.name,
      email: email,
      password: password,
    ));
  }
```

Adding events triggers the handler for the corresponding event type.

```dart
    on<ClientWantsToSignIn>(_onClientEvent);
```

When the BLoC receives `ClientWantsToSignIn` event then `_onClientEvent` will
be invoked to handle the event.

The handler method serializes events to JSON, before they are sent to the
server.
Sending to server is done by adding messages to the channels sink.

```dart
  FutureOr<void> _onClientEvent(ClientEvent event, Emitter<ChatState> emit) {
    _channel.sink.add(event.toJson());
  }
```

### Server events

The constructor listens to messages from server.
It deserializes messages to the correct subclass based on `eventType`.
Then trigger the corresponding event handler, by passing the event to `add`.

```dart
    // Feed deserialized events from server into this bloc
    _channelSubscription = _channel.stream
        .map((event) => ServerEvent.fromJson(event))
        .listen(add, onError: addError);
```

Each event is handled by an event handler.

```dart
    // Handlers for server events
    on<ServerAddsClientToRoom>(_onServerAddsClientToRoom);
    on<ServerAuthenticatesUser>(_onServerAuthenticatesUser);
    on<ServerBroadcastsMessageToClientsInRoom>(
        _onServerBroadcastsMessageToClientsInRoom);
    on<ServerNotifiesClientsInRoomSomeoneHasJoinedRoom>(
        _onServerNotifiesClientsInRoomSomeoneHasJoinedRoom);
    on<ServerSendsErrorMessageToClient>(_onServerSendsErrorMessageToClient);
```

Event handlers emit a new state.
This new state is copy of previous state with new information added from the
event.
Here is an example for when client has authenticated:

```dart
  FutureOr<void> _onServerAuthenticatesUser(
      ServerAuthenticatesUser event, Emitter<ChatState> emit) {
    _jwt = event.jwt;
    emit(state.copyWith(
      authenticated: true,
      headsUp: 'Authentication successful!',
    ));
  }
```

_Note: The JWT is in ChatState because it is a secret value that shouldn't be
shown in UI._

### Models

[dart_mappable](https://pub.dev/packages/dart_mappable) is used to enhance the model
classes.

Here is an example:

```dart
// This file is "model.dart"
import 'package:dart_mappable/dart_mappable.dart';

// Will be generated by dart_mappable
part 'model.mapper.dart';

@MappableClass()
class MyClass with MyClassMappable {
  final int myValue;

  MyClass(this.myValue);
}
```

{{% hint warning %}}

When using **dart_mappable**, make sure you have `part 'model.mapper.dart'`,
`@MappableClass()` and `with MyClassMappable` in your code.
The code generation won't work correctly without it and you will get errors
that can be difficult to figure out.

It needs to follow the naming of the code you are writing.
So if your file is named `x.dart` then you need `part 'x.mapper.dart`.
Likewise, if your class is named `X` then you need `with XMappable`.

**Note** `XMappable` won't exist before you have executed the code generation.
You can run code generation with:

```sh
dart run build_runner build
```

{{% /hint %}}
