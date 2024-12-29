---
title: Widgets
description: >-
  This is an introduction to widgets in Flutter.
weight: 1
---

{{< classic-dartpad >}}

# Widgets

In Flutter, the entire UI is built from widgets.
A widget serves a similar purpose as a component in React, Angular or Vue.

## Run app

The entry point for Flutter is a call to the [runApp function](https://api.flutter.dev/flutter/widgets/runApp.html).
It takes a tree of widgets as argument and puts the widgets on the screen.

```run-dartpad:theme-dark:mode-flutter:run-false:width-100%:height-360px
import 'package:flutter/material.dart';

void main() {
  runApp(
    const Center(
      child: Text(
        'Hello, world!',
        textDirection: TextDirection.ltr,
        style: TextStyle(color: Colors.blue),
      ),
    ),
  );
}
```

This is what the widget tree from the example above looks like:

![Simple widget tree](images/simple_app.drawio.svg "Widget tree from the example above")

The [Center widget](https://api.flutter.dev/flutter/widgets/Center-class.html)
simply places its content in the center of the available space.
The [Text widget](https://api.flutter.dev/flutter/widgets/Text-class.html) renders some text.

`TextDirection.ltr` tells the `Text` widget that it needs to layout its text
from left-to-right (ltr).

Many widgets has an optional `style` parameter that can be used to change the
appearance of the widget.
In this case, it's used to change the text color to blue.

## App widget

The root for most Flutter apps is either going to be [MaterialApp](https://api.flutter.dev/flutter/material/MaterialApp-class.html) or [CupertinoApp](https://api.flutter.dev/flutter/cupertino/CupertinoApp-class.html).
They both set up defaults for theming, text direction, navigation among other things.
You will learn about navigation at a later point in time.
The difference between the two app widgets is that: **MaterialApp** is for the
[Material design](https://m3.material.io/) language which is the standard on
Android.
And **CupertinoApp** is for [Human Interface
Guidelines](https://developer.apple.com/design/human-interface-guidelines/)
design language, which is default for iOS.

The design language is quite different between Material (android) and Cupertino
(iOS).
So, there are a set of widgets for each style.

These lists can be an excellent resource when looking for the right widget to
use.

- [Material (Android)](https://docs.flutter.dev/ui/widgets/material)
- [Cupertino (iOS)](https://docs.flutter.dev/ui/widgets/cupertino)
- [List of widgets](https://docs.flutter.dev/reference/widgets)

{{< hint >}}
You might want to consider making a bookmark folder for your Flutter journey.
I suggest you start your collection by adding the links above.
{{< /hint >}}

Here is a small demonstration of widgets from each style (Android &
iOS).

### Cupertino demo

```run-dartpad:theme-dark:mode-flutter:run-false:width-100%:height-600px
import 'package:flutter/cupertino.dart';

void main() {
  runApp(
    CupertinoApp(
      title: 'Flutter Demo',
      home: CupertinoPageScaffold(
        navigationBar: const CupertinoNavigationBar(
            middle: Text("Flutter Cupertino Demo")),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Text('Showcase some widgets:'),
              CupertinoButton.filled(child: const Text("Button"), onPressed: () {}),
              CupertinoSwitch(value: true, onChanged: (_) {}),
              CupertinoSlider(value: 0.5, onChanged: (_) {}),
            ],
          ),
        ),
      ),
    ),
  );
}
```

### Android demo

```run-dartpad:theme-dark:mode-flutter:run-false:width-100%:height-600px
import 'package:flutter/material.dart';

void main() {
  runApp(
    MaterialApp(
      title: 'Flutter Demo',
      darkTheme: ThemeData.dark(),
      home: Scaffold(
        appBar: AppBar(title: const Text("Flutter Android Demo")),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Text('Showcasing some widgets:'),
              FilledButton(child: const Text("Button"), onPressed: () {}),
              Switch(value: true, onChanged: (_) {}),
              Slider(value: 0.5, onChanged: (_) {}),
            ],
          ),
        ),
      ),
    ),
  );
}
```

**Notice**: for iOS style widgets we import `flutter/cupertino.dart` and for
Android style we import `flutter/material.dart`.

Some of the widgets that have a direct equivalent on both iOS and Android.
For those you can use a variant that automatically adapts.

[List of widgets that adapts](https://docs.flutter.dev/platform-integration/platform-adaptations#widgets-with-adaptive-constructors)

```run-dartpad:theme-dark:mode-flutter:run-false:width-100%:height-380px
import 'package:flutter/material.dart';

void main() {
  runApp(
    MaterialApp(
      theme: ThemeData(platform: TargetPlatform.iOS),
      home: AlertDialog.adaptive(
        title: Text("Adaptive dialog"),
        content: Text("The of this dialog adapts to the platform."),
      ),
    ),
  );
}
```

_Try to change `TargetPlatform.iOS` to `TargetPlatform.android`._

{{< hint warning >}}
You normally don't specify "TargetPlatform" directly.
It's just a quick way to demo.
{{< /hint >}}


The rest of the exercises will mostly focus on Android style widgets.
As it would be a lot of extra work to providing all examples twice.
However, you are encouraged to experiment with both styles.

## Buttons

If you've looked at the list of widgets that adapt, you might have noticed that
there are no buttons.
That is because Material uses different flavors of buttons.
Here are some examples:

```run-dartpad:theme-dark:mode-flutter:run-false:width-100%:height-550px
import 'package:flutter/material.dart';

void main() {
  runApp(
    MaterialApp(
      home: Scaffold(
        body: Column(
          children: [
            const Text('Different kinds of buttons:'),
            TextButton(child: const Text("TextButton"), onPressed: () {}),
            ElevatedButton(
                child: const Text("ElevatedButton"), onPressed: () {}),
            OutlinedButton(
                child: const Text("OutlinedButton"), onPressed: () {}),
            FilledButton(child: const Text("FilledButton"), onPressed: () {}),
            IconButton(icon: const Icon(Icons.settings), onPressed: () {})
          ],
        ),
      ),
    ),
  );
}
```

The parameter `onPressed` takes a function as an argument that gets invoked
when the button is pressed.
Here an empty function `() {}` is being used.
The button will be disabled if you set `onPressed` to `null`.

You can find a list of icons [here](https://fonts.google.com/icons?icon.platform=flutter).

## Widget trees

Back to widget trees.
Here is the widget tree for the Material demo show previously.

![Material app widget tree](images/material_demo.drawio.svg "Widget tree for Material demo")

A couple of things to note.
[Scaffold](https://api.flutter.dev/flutter/material/Scaffold-class.html) is
used to create the basic layout for a page (or screen) in your app.
`Scaffold` can have a multiple child widgets for different commonly used layout elements.
They include:

- [AppBar](https://api.flutter.dev/flutter/material/AppBar-class.html)
- [BottomAppBar](https://api.flutter.dev/flutter/material/BottomAppBar-class.html)
- [FloatingActionButton](https://api.flutter.dev/flutter/material/FloatingActionButton-class.html)
- [Drawer](https://api.flutter.dev/flutter/material/Drawer-class.html)

Open the links to see examples of what they look like.

Some widgets have multiple child widgets.
In the case of `Scaffold`, it can have distinct child widgets serving different
purposes (AppBar, Drawer etc).
Other widgets like `Column` (described in next section) have a list of child
widgets.
