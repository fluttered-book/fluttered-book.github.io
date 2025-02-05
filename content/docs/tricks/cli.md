---
title: CLI
weight: 1
---

# Flutter / Dart CLI

This is a distilled version of the most useful command line options for Flutter
and Dart command-line tool.
Here are links for the full documentation for [Flutter
CLI](https://docs.flutter.dev/reference/flutter-cli) and [Dart
CLI](https://dart.dev/tools/dart-tool).

## Create a project

```sh
flutter create <project_name>
cd <project_name>
```

Replace `<project_name>` with the name of the project you want to create.

{{% hint "info" %}}
Use `_` as separator between words in the project names.

Avoid spaces and weird characters in path names for your projects as it can
cause strange issues when attempting to run the app.
{{% /hint %}}

Just running `flutter create <project_name>` will make a project that can run
on all platforms supported by Flutter.
You can create a project only for specific platforms with the `--platform`
parameter.
Possible platforms are `ios, android, windows, linux, macos, web`.
Here are a couple of examples.

### Flutter project for Android, Web and Windows

```sh
flutter create --platforms=android,web,windows <project_name>
```

### Flutter project for iOS/iPhone, Web and macOS

```sh
flutter create --platforms=ios,web,macos <project_name>
```

### Adding support for platforms to existing project

Do you already have a project, but you need it to support additional platforms?
Navigate to the root of your project folder in a terminal, then do:

```sh
flutter create --platforms=andoid,ios,web .
```

You can modify the list of as needed.
It will simply recreate the project files with support for the specified
platforms.

{{% hint warning %}}
Recreating the project won't make any changes to the application code.
But, it could override any modifications you might have made to any of the
platform specific files.
For instance if you added permissions to use location service to Android
manifest or iOS plist files.
{{% /hint %}}

## Managing dependencies

Package for Flutter and Dart can be found at **[pub.dev](https://pub.dev/)**.
The site is similar to [npm](https://www.npmjs.com/) and
[nuget](https://www.nuget.org/).

### Install dependencies

When you clone a new project you need to install its dependencies.
This can be done with:

```sh
flutter pub get
```

The command is similar to `npm install`.

### Adding dependencies

You can add a new dependency with:

```sh
flutter pub add <pacakge_name>
```

Where package name can be found on [pub.dev](https://pub.dev/).
Screenshot an example of a package.

![flutter_bloc on pub.dev](../images/flutter_bloc-pubdev.png)

The package name for this package is `flutter_bloc`.
So, to install it you would run `flutter pub add flutter_bloc`.

Pay attention to the likes, points and downloads as popularity can indicate
that the package is of decent quality.

Dependencies you add will be added to the `pubspec.yaml` file.
It is also possible to install dependencies by adding them manually to
`pubspec.yaml` then run `flutter pub get` to download the packages.

### Upgrading dependencies

To upgrade dependencies to the newest version that match version constraints,
run:

```sh
flutter pub upgrade
```

## Running the app

To run the app simply type:

```sh
flutter run
```

It might ask you what platform you want to run on.
You can then hot reload by pressing `r`.

### Run on specific device

You can run the app on a specific device with the `-d` option.
Here are some examples:

**Run on chrome**

```sh
flutter run -d chrome
```

**Run on emulator**

```sh
flutter run -d emulator
```

### View a list of devices

```sh
flutter devices
```

Example output:

```
Found 4 connected devices:
  ASUS AI2202 (mobile)         • NAXXXXXXXXXXXXX • android-arm64  • Android 14 (API 34)
  sdk gphone64 x86 64 (mobile) • emulator-5554   • android-x64    • Android 15 (API 35) (emulator)
  Linux (desktop)              • linux           • linux-x64      • Arch Linux 6.13.1-arch1-1
  Chrome (web)                 • chrome          • web-javascript • Chromium 133.0.6943.35 Arch Linux
```

The 2nd column contains the device ID you would use in commands above.

You don't have to remember and out the entire device ID.
You only need the first couple of letters.
Just enough to make it unique.

Above I showed you could run on emulator by typing `flutter run -d emulator`
even though the full device ID is something like "emulator-5554".

## Emulators

You can launch an emulator with:

```sh
flutter emulators --launch <ID>
```

Where `<ID>` is the ID of an emulator, or virtual device.
To run on an emulator with ID `Resizable_Experimental_API_35`, do:

```sh
flutter emulators --launch Resizable_Experimental_API_35
```

You can see a list of the emulators you have with:

```sh
flutter emulators
```

## Building

| Platform | Command             |
| -------- | ------------------- |
| Web      | `flutter build web` |
| Android  | `flutter build apk` |
| iOS      | `flutter build ios` |

The output will show you where it created the files.
You can add the `--release` flag to get a smaller more optimized bundle that
doesn't allow debugging.

The output for **web** can be uploaded to any static web hosting such as GitHub pages or Firebase.
See [Deploy to web](../web).

For **Android** you can just copy the APK file to you device and install it by
opening the file.
It will give you some warnings because you are side-loading it.

With **iOS** it gets complicated.
As far as I know, there is no simply way to just install from a file.
You will need an Apple developer account and jump through a bunch of hoops to
either get it on TestFlight or App Store.

## Debug

### Correctly installed Flutter environment

You can check whether the tools Flutter use are correctly installed by running:

```sh
flutter doctor
```

### Fix cache

Sometimes the packages or build cache becomes inconsistent.
I can't tell you what the exact symptoms of this issue are as it can vary.
If you are getting strange compilation errors pointing to something deep inside a package, you might want to try:

```sh
flutter pub clean
```
