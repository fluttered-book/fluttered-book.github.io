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
