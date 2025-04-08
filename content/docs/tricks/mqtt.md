---
title: MQTT
description: >-
  Example of controlling a IoT device over MQTT v3
weight: 12
---

# MQTT

{{< hint warning >}}
<b>Supports: MQTT v3(3.1 and 3.1.1)</b>
<br>
Doesn't work with MQTT v5
{{< /hint >}}

Here is how to control a device over MQTT from Flutter.
It can be used as a starting point for creating apps to control [IoT
devices](https://en.wikipedia.org/wiki/Internet_of_things).

**"Smart" light simulator written in Dart**

<video width="100%" controls>
  <source src="../images/mqtt_dart_demo.webm" type="video/webm">
</video>

**Controlling ESP32 board**

<video controls>
  <source src="../images/mqtt_esp32_demo.mp4" type="video/webm">
</video>

## Project

### [Link](https://github.com/fluttered-book/flutter_mqtt)

There are 4 projects in the repository.

**smart_light_dart**

Simulates a IoT "smart" light that can be turned on and off.
It prints an ASCII art representation of the light each time its power state
changes.

Program exits when you hit <kdb>Enter</kdb>.

**smart_light_esp32**

Arduino sketch for IoT "smart" light allowing you to turn a LED on and off from
the controller app.

**light_controller**

Is a Flutter app that can control (send on/off commands to) the IoT light.
It also displays an indication of the power status using emojis.

- 🤔 = Unknown (haven't received status for the light yet)
- 💡 = Lights on
- 🌃 = Light off

_Emojis might look different depending on the font_

**light_protocol**

Contains protocol code shared between **smart_light_dart** and **light_controller**.

---

## Getting started

The setup requires that you run a broker, light_controller and then either
smart_light_dart or smart_light_esp32 at the same time.

### MQTT broker

First you need a MQTT broker.
If you want to try the Flutter app in a web-browser then you need a broker that
supports MQTT over WebSocket.

I have only tested with [Mosquitto](https://mosquitto.org/) as broker.
Repository contains a configuration file for it.

```sh
mosquitto -c mosquitto.conf
```

### Smart Light (Dart)

If you use a different broker you need to adjust server, port and credentials in
`smart_light_dart/bin/iot_light.dart`.

```sh
cd smart_light_dart
dart pub get
dart run
```

### Smart Light ESP32

[Instructions](https://github.com/fluttered-book/flutter_mqtt/blob/main/smart_light_esp32/README.md)

### Light controller

Works on Chrome and Android.
Additional work might be needed for iOS.

If you use a different broker then you will need to adjust server, port and
credentials in `light_controller/lib/main.dart`.

#### Browser

Running the app in a browser requires a broker that supports MQTT over
WebSocket.

```sh
cd light_controller
flutter pub get
flutter run -d chrome
```

#### Android

The Android emulator got its own IP stack.
So, `localhost` inside the emulator won't be the same as your host OS (mac,
win).
Connecting to `10.0.2.2` will allow it to connect to a broker as on your host
OS.
[See more](https://developer.android.com/studio/run/emulator-networking.html)

Start the Android emulator (or connect a real device), then do:

```sh
cd light_controller
flutter pub get
flutter run
```

## How it works

### Protocol

With MQTT, you can publish and subscribe to topics.
It doesn't care about how messages are structured.
In this project we are using JSON to structure messages.

The controller sends commands to the Light on one topic.
IoT light responds to commands with a status on another topic.

![MQTT protocol for controlling light](../images/mqtt_light_protocol.drawio.svg)

The messages are defined
[here](https://github.com/fluttered-book/flutter_mqtt/blob/main/light_protocol/lib/src/messages.dart)
and the application protocol is defined
[here](https://github.com/fluttered-book/flutter_mqtt/blob/main/light_protocol/lib/src/protocol.dart).

### MQTT library

It uses the [mqtt_client](https://pub.dev/packages/mqtt_client) package.
It ships with two MQTT client implementations.

- **MqttServerClient** for normal MQTT
- **MqttBrowserClient** for MQTT over WebSocket (needed in browser)

They share the same
[MqttClient](https://pub.dev/documentation/mqtt_client/latest/mqtt_client/MqttClient-class.html)
interface/base-class.

Instantiate it:

```dart
MqttClient mqttClient = MqttServerClient.withPort(server, clientIdentifier, port)
```

In web-browser you need to do this instead:

```dart
MqttClient mqttClient = MqttBrowserClient.withPort("ws://$server/", clientIdentifier, wsPort);
```

_"ws" is short for WebSocket_

Enabling logging can be useful for debugging:

```dart
mqttClient.logging(on: true);
```

Auto-reconnect can be enabled with:

```dart
mqttClient.autoReconnect = true;
```

You need to connect before subscribing to topics.

```dart
await mqttClient.connect();
```

Or if your broker requires credentials.

```dart
await mqttClient.connect(username, password);
```

You subscribe with:

```dart
mqttClient.subscribe("topic", qos);
```

Where `qos` is
[MqttQos](https://pub.dev/documentation/mqtt_client/latest/mqtt_client/MqttQos.html)

### JSON

The `toJson` and `fromJson` for the messages are implemented by hand.
For more complex scenarios you might want to consider using
[json_serializable](https://pub.dev/packages/json_serializable) to generate the
code.

To work with JSON over MQTT you need to serialize when publishing and
deserialize updates from subscribed topics.
I wrote some [extension methods](https://dart.dev/language/extension-methods)
that might help.

```dart
import 'dart:async';
import 'dart:convert';

import 'package:mqtt_client/mqtt_client.dart';

extension JsonMqttClientExtension on MqttClient {
  /// The stream on which all subscribed topic updates are published to,
  /// deserialized from JSON.
  ///
  /// **Important** `fromJson` must be compatible with messages on all
  /// subscribed topics.
  Stream<JsonMessage<T>> jsonUpdates<T>(
      {required T Function(Map<String, dynamic> json) fromJson}) {
    return updates!.expand((updates) sync* {
      for (final update in updates) {
        // Get payload from update
        final mqttMessage = update.payload as MqttPublishMessage;
        final topic = update.topic;
        final payload = MqttPublishPayload.bytesToStringAsString(
            mqttMessage.payload.message);

        // Deserialize JSON
        print("Update payload: $payload");
        final json = jsonDecode(payload);
        final message = fromJson(json);

        // Forward protocol
        yield (topic: topic, message: message);
      }
    });
  }

  /// Publish JSON message
  int publishJsonMessage<T>(String topic, Map<String, dynamic> json) {
    // Serialize message json
    final payload = jsonEncode(json);
    final builder = MqttClientPayloadBuilder()..addString(payload);
    // Publish serialized message to topic
    return publishMessage(topic, MqttQos.atLeastOnce, builder.payload!);
  }
}

typedef JsonMessage<T> = ({String topic, T message});
```

Drop the code above into you project.
Import the file where you are working with `MqttClient`.
It will add `publishJsonMessage` and `jsonUpdates` to `MqttClient`.

The `jsonUpdates` method will
[expand](https://api.flutter.dev/flutter/dart-async/Stream/expand.html) the
stream of updates from MqttClient.
It is implemented as a
[generator](https://dart.dev/language/functions#generators).

You might need to adapt the code if you got different topics with messages types
that don't share a common base class.

[More on JSON
serialization](https://docs.flutter.dev/data-and-backend/serialization/json)
