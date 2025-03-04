---
title: Jokes app
weight: 2
---

# Jokes app

## Introduction

This will be a fun one.
Today we are going to kill the boredom by writing an app that tells jokes.

First you need to create a new Flutter project.

```sh
flutter create jokes
```

You can use a different project name if you want.

## Data

You could write a long list of jokes yourself for the app.
However, that sounds like a lot of work for something supposed to be fun.

Instead, let's use jokes other people have written.
Luckily there is a nice free API we can use to fetch random jokes.

Head over to [jokeapi](https://jokeapi.dev/#try-it).

I suggest that you select _Programming_ as the category.
It is also recommended that you select everything under **Select flags to
blacklist** as some of the jokes will be otherwise be really offensive.

_Feel free to explore different options at your own risk._

![Recommended jokeapi settings](../images/jokeapi.png)

The URL should look something like this:

```
https://v2.jokeapi.dev/joke/Programming?blacklistFlags=nsfw,religious,political,racist,sexist,explicit
```

Feel free to hit the _Send Request_ button a couple of times to see how the API
responds.

Remember the URL because you will need it later.

There are two types of jokes `single` and `twopart`.
You can tell which type you get from the `type` field in the response.

For the next step you'll need to merge a response of both types.
So, you get something like:

```json
{
  "error": false,
  "category": "Programming",
  "type": "twopart",
  "setup": "Why do programmers confuse Halloween and Christmas?",
  "delivery": "Because Oct 31 = Dec 25",
  "joke": "Java is like Alzheimer's, it starts off slow, but eventually, your memory is gone.",
  "flags": {
    "nsfw": false,
    "religious": false,
    "political": false,
    "racist": false,
    "sexist": false,
    "explicit": false
  },
  "id": 11,
  "safe": true,
  "lang": "en"
}
```

It should have both `setup`, `delivery` and `joke` fields.

Copy the merged JSON.
Head over to [JSON to Dart](https://jsontodart.zariman.dev/) and paste
it in.
In the "Class Name" input, type `JokeDto` and hit the _Generate_ button.

Copy all the generated Dart code and paste it into a new file named
`joke_dto.dart` inside your project.

It generated a DTO class for us, with convince methods to help convert to and
from JSON.

Now that we have a class for the data, we need some code to fetch it from the
API.
For that we need to add a package.

```sh
flutter pub add http
```

{{% hint info %}}
There is an HTTP client build into Dart but the [http
package](https://pub.dev/packages/http) is a lot nicer to work with.
{{% /hint %}}

{{% hint warning %}}
On Android we need to specify that the app requires permission to access the internet.
To do that, open up `android/app/src/main/AndroidManifest.xml` then add a
couple of lines:

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">

    <!-- These two lines -->
    <uses-permission android:name="android.permission.INTERNET" />
    <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />

    ...
```

{{% /hint %}}

Add a new file called `data_source.dart` to your project with the following content:

```dart
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'joke_dto.dart';

class DataSource {
  Future<JokeDto> getJoke() async {
    // Your URL from goes here...
    const url = "https://v2.jokeapi.dev/joke/Programming?blacklistFlags=nsfw,religious,political,racist,sexist,explicit";
    final response = await http.get(Uri.parse(url));
    final map = json.decode(response.body);
    return JokeDto.fromJson(map);
  }
}
```

And since we just learned about Cubit, let's write a Cubit to keep track of the
state.

We need to add _flutter_bloc_ library to the project.

```sh
flutter pub add flutter_bloc
```

Here is a quick refresher of how cubits work.

1. The cubit is made available to widgets by placing a `BlocProvider` high in
   the widget tree.
2. User interacts with a widget.
3. The widget invokes a method on the cubit.
4. Cubit does some stuff and emits one or more states.
5. `BlocBuilder` (or similar) rebuild part of widget tree when a new state is
   emitted.

A state is just an instance of an object.
It can be anything really.

Here I'll show a different way of writings states than what you've seen
previous.

```dart
import 'package:flutter/widgets.dart';
import 'package:jokes/joke_dto.dart';

@immutable
sealed class JokeState {}

final class JokeInitial extends JokeState {}

final class JokeLoading extends JokeState {}

final class JokeLoaded extends JokeState {
  final JokeDto joke;
  JokeLoaded({required this.joke});
}

final class JokeError extends JokeState {
  final String message;
  JokeError({required this.message});
}
```

All different states of the app will be represented by a subclass of `JokeState`.

A `sealed` class is similar to an abstract class but can't be extended outside
the file itself (aka library).

A `final` class can't be extended anywhere.

You can read more about [class modifiers
here](https://dart.dev/language/class-modifiers).

The cubit is going to be really simple.

```
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jokes/data_source.dart';

import 'joke_state.dart';

class JokeCubit extends Cubit<JokeState> {
  final DataSource dataSource;

  JokeCubit({required this.dataSource}) : super(JokeInitial());

  Future<void> loadNewJoke() async {
    emit(JokeLoading());
    try {
      final joke = await dataSource.getJoke();
      emit(JokeLoaded(joke));
    } catch (e) {
      emit(JokeError(e.toString()));
    }
  }
}
```

You can probably figure out what it does on your own.

Here we are taking advantage of the fact that a Cubit can emit several states
from the same method.

## UI

In `main.dart`, wrap `MaterialApp` with a provider for `DataSource`:

```dart
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Provider(
      create: (context) => DataSource(),
      child: MaterialApp(
        // ...
      ),
    );
  }
}
```

Now, replace `MyHomePage` with:

```dart
class JokesPage extends StatelessWidget {
  const JokesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Jokes")),
      body: BlocBuilder<JokeCubit, JokeState>(
        builder: (context, state) {
          return Column(
            children: [
              switch (state) {
                JokeInitial() => Text("Wan't to hear a joke?"),
                JokeLoading() => CircularProgressIndicator(),
                JokeLoaded() => JokeWidget(state.joke),
                JokeError() => Text(
                    state.message,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
              },
              TextButton(
                onPressed: () => context.read<JokeCubit>().loadNewJoke(),
                child: Text(state is JokeInitial ? "Yes" : "Another"),
              ),
            ],
          );
        },
      ),
    );
  }
}

class JokeWidget extends StatelessWidget {
  final JokeDto joke;
  const JokeWidget(this.joke, {super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (joke.joke != null) Text(joke.joke!),
        if (joke.setup != null) Text(joke.setup!),
        if (joke.delivery != null) Text(joke.delivery!)
      ],
    );
  }
}
```

You should have a working app by now.
Try it out!

It looks really boring, doesn't it?
Spend some time to make it pretty, before you head to the challenges.

## Challenges

The following challenges can be completed independent of each other.

You are not required to complete them all, but you should at least read the
text.

### Challenge 1 - Add some graphics

Without graphics the app looks pretty boring.
So, let's fix it!

{{% hint info %}}
You are not required to follow the steps in this section.
You can get creative and add some other graphics instead.
{{% /hint %}}

With the [Image
widget](https://api.flutter.dev/flutter/widgets/Image-class.html) you can easily
add images.

I thought it would be cool if it looks like there are different cartoon
characters telling jokes.

I've found an avatar library/service called
[DiceBear](https://www.dicebear.com/how-to-use/http-api/), that have an HTTP API.

Find an [avatar style](https://www.dicebear.com/styles/) you like.

You can get a new avatar for each joke with:

```dart
"https://api.dicebear.com/7.x/pixel-art/svg?seed=${joke.id}"
```

Where `joke.id` is the id field from the DTO.

Replace `pixel-art` with your preferred style.

SVG is a nice format since it looks crisp no matter the size.
However, Flutter doesn't easily allow you to draw SVGs out-of-the-box.
But that can easily be fixed just by adding another package.

```sh
flutter pub add flutter_svg
```

You can now show an avatar with the following widget:

```dart
SvgPicture.network("https://api.dicebear.com/7.x/adventurer/svg?seed=${joke?.id}")
```

Mine ended up looking like this:

![My version of the app](images/my_app.jpg)

### Challenge 2 - Settings

Remember, there were a lot of settings you could change on the [jokeapi
website](https://jokeapi.dev/)?

Wouldn't it be cool if your users could change the settings themselves?

For that you need a couple of things.

1. Some way to manage the settings state
2. another page to change the settings
3. (optionally) persistent storage of the settings
4. update `DataSource` to use the settings

#### 1. Object to hold settings

You can solve the first, by simply adding a `Settings` class with fields for the
settings you want the user to be able to change.

You can make the `Settings` class accessible across your application with a
provider (just like DataSource).
I suggest using a
[MultiProvider](https://pub.dev/packages/provider#multiprovider) to cleanly
provide both `DataSource` and your new settings object.

#### 2. Persistence (optional)

You can use the [localstorage](https://pub.dev/packages/localstorage) package to
persist simple data in your app.

One caveat, is that whatever data you try to persist, needs to be JSON
serializable.
Meaning, you can only use types like: int, double, bool, String List & Map.
Also, you will have to cast the value you get back to the appropriate type.

Add `load` and `save` methods to `Settings` and use `LocalStorage` to persist
settings.

**Important:** You need to wait for `LocalStorage` to be ready before you can use it:

```dart
final LocalStorage storage = LocalStorage('settings');
await storage.ready
```

#### 3. Settings page

Create a new `StatefulWidget` for the settings page.

You can navigate to it with:

```dart
Navigator.of(context).push(MaterialPageRoute(builder: (context) => const SettingsPage()));
```

Which can be invoked from `onPressed` on a button.

You can use the [settings_ui](https://pub.dev/packages/settings_ui) package to
easily create a UI with toggles for various settings such as categories.

Remember to call `setState(() {})` when you want the UI to update.

You can use [PopScope](https://api.flutter.dev/flutter/widgets/PopScope-class.html)
to save the settings before the widget is popped from the navigation stack.

```dart
Widget build(BuildContext context) {
  return PopScope(
    canPop: false,
    onPopInvoked: (didPop) async {
      final navigator = Navigator.of(context);
      await settings.save(settings);
      if (navigator.canPop()) navigator.pop();
    },
    child: Scaffold(
      appBar: AppBar(title: const Text("Settings")),
      body: SettingsList(sections: [
        // your settings here
      ]),
    ),
  );
}
```

#### 4. Use settings in DataSource

Update `DataSource` to use the settings:

```dart
class DataSource {
  Future<JokeDto> getJoke(Settings settings) async {
    final categories = settings.categories.isEmpty ? "Any" : settings.categories.map((e) => e.name).join(",");
    final url = "https://v2.jokeapi.dev/joke/$categories";
    final response = await http.get(Uri.parse(url));
    final map = json.decode(response.body);
    return JokeDto.fromJson(map);
  }
}
```

You can get the settings from within your widget using
`context.read<Settings>()`.

### Challenge 3 - Read it out loud

Wouldn't it be cool if your app could read the jokes out loud?

What you need is some text-to-speech (aka speech synthesis) functionality.

The [Cloud Text-To-Speech](https://pub.dev/packages/cloud_text_to_speech)
package allows you to easily use cloud services from major providers to convert
text to sound.

You will also need another package such as
[audioplayers](https://pub.dev/packages/audioplayers) to play the sound.

Third, your app will need secrets to access the speech cloud service.
As you know, one should never commit secrets to source repository.
You can store the secrets in a `.env` file and read them using
[flutter_dotenv](https://pub.dev/packages/flutter_dotenv).

Add the packages:

```sh
flutter pub add cloud_text_to_speech
flutter pub add audioplayers
flutter pub add flutter_dotenv
```

1. Add `.env` to `.gitignore`
2. Go to [Azure Portal](https://portal.azure.com/).
3. Create a new **Speech Services** resource in the region of North Europe.
4. Copy one of the two keys on the resource overview page under **Keys and endpoint** section.

Create a `.env` file with your key at the root of your Flutter project:

```sh
TTS_SUBSCRIPTION_KEY=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
TTS_REGION=northeurope
```

**IMPORTANT** verify that `.env` file isn't included before you commit and push.

Change main method in `main.dart`:

```dart
void main() async {
  await dotenv.load(fileName: ".env");
  TtsMicrosoft.init(
    subscriptionKey: dotenv.env["TTS_SUBSCRIPTION_KEY"]!,
    region: dotenv.env["TTS_REGION"]!,
    withLogs: true,
  );
  runApp(const MyApp());
}
```

Add the following to one of your widget state objects:

```dart
final player = AudioPlayer();

@override
void dispose() {
  player.stop().then((value) => player.dispose());
  super.dispose();
}
```

You can now have the text converted to sound and play it with the following
code.

```dart
final voicesResponse = await TtsMicrosoft.getVoices();
final voices = voicesResponse.voices;

TtsParamsMicrosoft ttsParams = TtsParamsMicrosoft(
    voice:
        voices.firstWhere((element) => element.locale.code.startsWith("en-")),
    audioFormat: AudioOutputFormatMicrosoft.audio48Khz192kBitrateMonoMp3,
    text: textYouWantToBeSpoken,
);

final ttsResponse = await TtsMicrosoft.convertTts(ttsParams);

player.play(BytesSource(ttsResponse.audio.buffer.asUint8List()));
```

Be mindful not to make excessive amounts of request to the service, as you will
likely hit a limit at some point.
