---
title: Widget tests
weight: 3
---

# Widgets tests

You've seen how you can test functions and methods.
This section will build on that to show you how to test widgets.

## Headless UI

When you write widgets tests you are programmatically interacting with your
apps UI or part of it, in a headless manner.
Headless in computing means something configured to operate without a direct
display and input (keyboard, mouse or touch).

With widget testing you write code to interact with widgets and to observe the
result.
It can feel a bit like being blindfolded.
I find that most automated UI testing is like that.
There will be some pointers on how to debug your tests towards the end of the chapter.

## Dependency

To write widget tests you will need to have the `flutter_test` package
specified as developer dependency.
It contains all the needed functions etc.
Since any real app should have tests, the Flutter team have been kind enough
to add it to the project template used when running `flutter create app`.

Open up `pubspec.yaml` for any of the projects and see if you can find the following lines:

```yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
```

So, you don't have to do anything to include the dependency.
It's just already there.
I guess it is nice enough to know how it is set up.

## Render widgets

Instead of `test()` you need to use the `testWidgets()` method.

<iframe width="100%" height="720px" src="https://dartpad.dev/?id=75421dd3466b326eab5a336ea3eee015?theme=light"></iframe>

{{% hint info %}}
The example might not function correctly.
I'm reaching the limit of what can be done with these embedded code examples.

If you are unable to run it here, try pasting the code into Android Studio.
{{% /hint %}}

The first argument is a description, just like `test()` method.
The second argument is a bit different.
For `test()` it is `dynamic Function()`.
And for `testWidgets()` it is `Future<void> Function(WidgetTester widgetTester)`.
The difference is that `testWidgets()` is takes an async function with a single
parameter as an argument.
We can use the parameter (WidgetTester) to interact with a widget tree.
But remember, always `await` on each interaction.

Before we can interact with the widget tree though, we need to inflate it.
Remember that there are 3 trees in Flutter (widgets, elements and
render-objects).
We need the trees to be instantiated somehow.
That process is called inflating the widget.
Normally you would do that with `runApp()`, but for tests we use
[WidgetTester.pumpWidget()](https://api.flutter.dev/flutter/flutter_test/WidgetTester/pumpWidget.html)
instead.
We can make it build/render another frame by calling
[WidgetTester.pump()](https://api.flutter.dev/flutter/flutter_test/WidgetTester/pump.html).
There is also
[WidgetTester.pumpAndSettle()](https://api.flutter.dev/flutter/flutter_test/WidgetTester/pumpAndSettle.html)
which rebuilds until there are no more changes, making it useful for when you
need to wait for animations to finish.

## Finder

To write widget tests we need to be able to programmatically interact with
widgets then verify the interaction had the desired effect.
To accomplish this we first need a way to match specific widgets.

We can do that with `find` which is a constant instance of
[CommonFinders](https://api.flutter.dev/flutter/flutter_test/CommonFinders-class.html).
It has a bunch of methods to help us navigate the widget tree to look for and
interact with specific widgets.

| Method                                                                                        | Description                           |
| --------------------------------------------------------------------------------------------- | ------------------------------------- |
| [find.text](https://api.flutter.dev/flutter/flutter_test/CommonFinders/text.html)             | Finds text widgets with given string. |
| [find.byType](https://api.flutter.dev/flutter/flutter_test/CommonFinders/byType.html)         | Find widgets of the given type.       |
| [find.byIcon](https://api.flutter.dev/flutter/flutter_test/CommonFinders/byIcon.html)         | Find widgets with the given icon.     |
| [find.descendant](https://api.flutter.dev/flutter/flutter_test/CommonFinders/descendant.html) | Find descendant/child widgets.        |
| [find.ancestor](https://api.flutter.dev/flutter/flutter_test/CommonFinders/ancestor.html)     | Find ancestor/parent widgets.         |
| [find.byKey](https://api.flutter.dev/flutter/flutter_test/CommonFinders/ancestor.html)        | Find widget with the given key.       |

{{% hint info %}}
Click on the links to see example usage.
{{% /hint %}}

That was just some of the finder methods.
A full list can be found
[here](https://api.flutter.dev/flutter/flutter_test/CommonFinders-class.html).

The **find.byKey** method needs a bit more explanation.
You have probably noticed that Android Studio warns you that constructors
should have a key parameter.

![Missing key warning](../images/missing-key.png)

Widgets can be given a key.
We can then use the key reference a specific widget in the widget tree.

{{% hint info %}}
Keys also have another use.
They can be used to maintain state when a rebuild cause a certain widget to be
placed a different place in the widget tree.

[Learn more about keys](https://www.youtube.com/watch?v=kn0EOS-ZiIc)
{{% /hint %}}

Some of the find methods can be combined with others.
Here is an example:

```dart
find.descendant(
  of: find.byType(CalculatorDisplay),
  matching: find.byKey(
    ValueKey('input'),
  ),
)
```

## Debugging

### Printing

You can of course use the good old `print()` function for outputting messages
to help you debug.
The problem is that it will also print when you release the app.
If used extensively it has a slight performance overhead.
Another issue is that you could end up having the app unintentionally output sensitive information such as API keys, or other secret.
Also on some platforms excessive calls to `print()` might be truncated.

To avoid the aforementioned issues it is better to use the following:

```dart
if (kDebugMode) debugPrint("Old state: $internalState}");
```

### Debugger

Having `if (kDebugMode) debugPrint("It worked!")` sprinkled all over the
application is pretty ugly.
It is much cleaner and even more useful to use the debugger build into Android
Studio instead.

Just click on the line number for where you want to pause execution of the app.
A 🔴 will appear.

![Line with breakpoint](../images/breakpoint.png)

Now, right-click on a test and choose debug.

![Debug test](../images/debug-test.png)

Or if you want to interact directly with the app then you can run it using the
🪲 button.

![Run debug](../images/run-debug.png)

#### Conditional debugger

It is sometimes really useful to only pause for debugging when a certain
condition in the app is met.

```dart
// At the top of the file
import 'dart:developer' as developer;

// Where you want to Conditionally debug
developer.debugger(when: <some condition>);
```

Here is an example.

![Conditional debug example](../images/conditional-debug.png)

{{% hint warning %}}
Remember to remove `developer.debugger()` when you are done.
Otherwise, it will seem like the app just hangs.
{{% /hint %}}

## Hints

```dart
import 'package:calculator_gui/main.dart';
import 'package:calculator_gui/widgets/calculator_display.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Enter a number', (WidgetTester tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = Size(412, 915);
    // Build our app and trigger a frame.
    await tester.pumpWidget(CalculatorApp());

    await tester.tapKey('5');
    await tester.pump();
    expect(find.inputText().data, equals('5'));
    await tester.tapKey('↲');
    await tester.pump();

    expect(find.stackText().data, equals('5.0'));
    expect(find.inputText().data, equals(''));
  });
}

extension on CommonFinders {
  Text inputText() {
    return find
        .descendant(
          of: find.byType(CalculatorDisplay),
          matching: find.byKey(
            ValueKey('input'),
          ),
        )
        .evaluate()
        .single
        .widget as Text;
  }

  Text stackText() {
    return find
        .descendant(
          of: find.byType(CalculatorDisplay),
          matching: find.byKey(
            ValueKey('stack'),
          ),
        )
        .evaluate()
        .single
        .widget as Text;
  }
}

extension on WidgetTester {
  Future<void> tapKey(String key) async {
    await tap(find.byKey(Key(key)));
  }
}
```
