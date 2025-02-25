---
title: Widget test
weight: 4
---

# Widgets tests

You've seen how you can test functions and methods.
This section will build on that to show you how to test widgets.

## Headless UI

When you write widget tests, you are programmatically interacting with your
apps UI (or part of it), in a headless manner.
Headless in computing means something configured to operate without a direct
display and input (screen and keyboard, mouse or touch).

With widget testing, you write code to interact with widgets and to observe the
result.
It can feel a bit like being blindfolded, in that you can't directly observe
what the app looks like at each statement of your test code.
I find that most automated UI testing is like that, and it can be a bit
frustrating at times.
So there are some pointers on how to debug your tests towards the end of the
chapter.

## Dependency

To write widget tests you will need to have the `flutter_test` package
specified as a development dependency.
Since any real app should have tests, the Flutter team have been kind enough to
add it to the project template used when running `flutter create app`.

Open up `pubspec.yaml` for any of the previous projects and see if you can find
the following lines:

```yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
```

So, you don't have to do anything to include the dependency.
It's just already there.
I guess it is nice enough to know how it is set up.

## Render widgets

For widget tests, instead of `test()` you need to use the `testWidgets()`
method.

<iframe width="100%" height="720px" src="https://dartpad.dev/?id=75421dd3466b326eab5a336ea3eee015?theme=light"></iframe>

{{% hint warning %}}
The example might not function correctly.
I'm reaching the limit of what can be done with these embedded code examples.

If you are unable to run it here, try pasting the code into Android Studio.
{{% /hint %}}

The first argument is a description, just like `test()` method.
The second argument is a bit different.
For `test()` it is `dynamic Function()`.
And for `testWidgets()` it is `Future<void> Function(WidgetTester widgetTester)`.
The difference is that `testWidgets()` takes an async function with a single
parameter (WidgetTester) as 2nd argument.
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

To write widget tests, we need to be able to programmatically interact with
widgets, so that we can verify the interaction had the desired effect.
To accomplish this we need a way to locate/find specific widgets.

We can do that with `find` which is a constant instance of
[CommonFinders](https://api.flutter.dev/flutter/flutter_test/CommonFinders-class.html).
It has a bunch of methods to help us navigate the widget tree, so we can find
and interact with specific widgets.

| Method                                                                                          | Description                                                        |
| ----------------------------------------------------------------------------------------------- | ------------------------------------------------------------------ |
| [find.text](https://api.flutter.dev/flutter/flutter_test/CommonFinders/text.html)               | Finds text widgets with given string.                              |
| [find.byType](https://api.flutter.dev/flutter/flutter_test/CommonFinders/byType.html)           | Find widgets of the given type.                                    |
| [find.withText](https://api.flutter.dev/flutter/flutter_test/CommonFinders/widgetWithText.html) | Find a widget of given type that contains a child with given text. |
| [find.byIcon](https://api.flutter.dev/flutter/flutter_test/CommonFinders/byIcon.html)           | Find widgets with the given icon.                                  |
| [find.descendant](https://api.flutter.dev/flutter/flutter_test/CommonFinders/descendant.html)   | Find descendant/child widgets.                                     |
| [find.ancestor](https://api.flutter.dev/flutter/flutter_test/CommonFinders/ancestor.html)       | Find ancestor/parent widgets.                                      |
| [find.byKey](https://api.flutter.dev/flutter/flutter_test/CommonFinders/ancestor.html)          | Find widget with the given key.                                    |

{{% hint info %}}
Click on the links to see example usage.
{{% /hint %}}

That is just some of the finder methods.
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
They can be used to ensure that a StatefulWidget maintain state when the widget
is placed at different branch in the widget tree across a rebuild.

[Learn more about keys](https://www.youtube.com/watch?v=kn0EOS-ZiIc)
{{% /hint %}}

Some of the _find_ methods can be combined with others.
Here is an example:

```dart
find.descendant(
  of: find.byType(CalculatorDisplay),
  matching: find.byKey(
    ValueKey('input'),
  ),
)
```

You can both use finders to find widgets in the widget tree, to interact with
and to locate widgets for your tests assertions.
Test assertion meaning what you **expect** the app to do based on the
interaction.

## Interactions

To write any meaningful widget test, we need to simulate interactions with the
app.
Common interactions for mobile apps are:

1. **Tap** on something
2. **Scroll** around
3. **Drag**/swipe
4. **Enter text** in a field

We can use `WidgetTester` to simulate these interactions.

### Tap

Tapping is pretty simple.
You just call
[tap](https://api.flutter.dev/flutter/flutter_test/WidgetController/tap.html)
method on `WidgetTester` with a finder for the widget you want to tap on as
argument.

Say you have an app that change the text shown when a button is tapped.

<iframe width="100%" height="200px" src="https://fluttered-book.github.io/widget_testing_examples/#tap"></iframe>

[Code](https://github.com/fluttered-book/widget_testing_examples/blob/main/lib/tap_widget.dart)

Here is how you could write a test for it.

```dart
testWidgets('Tapping "OK" provides feedback', (tester) async {
  // Inflate the widget tree
  await tester.pumpWidget(const MaterialApp(home: TapWidget()));

  // Tap the button.
  await tester.tap(find.widgetWithText(FloatingActionButton, "OK"));

  // Rebuild the widget after the state has changed.
  await tester.pump();

  // Expect to find the item on screen.
  expect(find.text('Button was tapped'), findsOneWidget);
});
```

[Code](https://github.com/fluttered-book/widget_testing_examples/blob/main/test/tap_widget_test.dart)

There are also a couple of variations of
[tap](https://api.flutter.dev/flutter/flutter_test/WidgetController/tap.html) that you can explore for yourself.
These are
[tapAt](https://api.flutter.dev/flutter/flutter_test/WidgetController/tapAt.html)
and
[tapOnText](https://api.flutter.dev/flutter/flutter_test/WidgetController/tapOnText.html).

### Scroll

Scrolling is also just a method on `WidgetTester`.
We don't need to calculate how much to scroll to find a particular item, we can
just use
[scrollUntilVisible](https://api.flutter.dev/flutter/flutter_test/WidgetController/scrollUntilVisible.html).

Say you have an app with a ListView widget containing 1000 items.

<iframe width="100%" height="200px" src="https://fluttered-book.github.io/widget_testing_examples/#scroll"></iframe>

[Code](https://github.com/fluttered-book/widget_testing_examples/blob/main/lib/scroll_widget.dart)

You could write a test that scroll until some item is visible like this:

```dart
testWidgets('Scrolling reveals additional tiles', (tester) async {
  // Inflate the widget tree
  await tester.pumpWidget(const MaterialApp(home: ScrollWidget()));

  final listFinder = find.byType(Scrollable);
  final itemFinder = find.text("No 50");

  // Scroll until the item to be found appears.
  await tester.scrollUntilVisible(itemFinder, 200.0, scrollable: listFinder);

  // Verify that the item contains the correct text.
  expect(itemFinder, findsOneWidget);
});
```

However, looking for certain text is not always the best.
Your app could have multiple widgets with the text "No 50".

In many cases it is better to give the widget a
[Key](https://api.flutter.dev/flutter/foundation/Key-class.html), so you can
find it based on the key instead.

```dart
testWidgets('Scrolling reveals additional tiles (by key)', (tester) async {
  // Inflate the widget tree
  await tester.pumpWidget(const MaterialApp(home: ScrollWidget()));

  final listFinder = find.byType(Scrollable);
  final itemFinder = find.byKey(const ValueKey('key_for_item_50'));

  // Scroll until the item to be found appears.
  await tester.scrollUntilVisible(itemFinder, 200.0, scrollable: listFinder);

  // Verify that the item contains the correct text.
  expect(itemFinder, findsOneWidget);
});
```

[Code](https://github.com/fluttered-book/widget_testing_examples/blob/main/test/scroll_widget_test.dart)

### Drag

Dragging/swiping gestures can be used for several things.
One example is swipe to dismiss.

Say you have an app with a to-do list.

<iframe width="100%" height="200px" src="https://fluttered-book.github.io/widget_testing_examples/#drag"></iframe>

[Source](https://github.com/fluttered-book/widget_testing_examples/blob/main/lib/drag_widget.dart)

You can write a test to dismiss an item like this:

```dart
testWidgets('Remove a todo', (tester) async {
  // Inflate the widget tree
  await tester.pumpWidget(const MaterialApp(home: DragWidget()));

  const todoText = "Clean room";

  // Swipe the item to dismiss it.
  await tester.drag(
    find.widgetWithText(Dismissible, todoText),
    const Offset(500, 0),
  );

  // Build the widget until the dismiss animation ends.
  await tester.pumpAndSettle();

  // Ensure that the item is no longer on screen.
  expect(find.text(todoText), findsNothing);
});
```

[Code](https://github.com/fluttered-book/widget_testing_examples/blob/main/test/drag_widget_test.dart)

### Text

Many apps got text fields.
They are used in forms, for search etc.

Say you have an app where you can enter a name to make it show a greeting.

<iframe width="100%" height="200px" src="https://fluttered-book.github.io/widget_testing_examples/#text"></iframe>

[Code](https://github.com/fluttered-book/widget_testing_examples/blob/main/lib/text_widget.dart)

You could write a test for it like this:

```dart
testWidgets("Entering a name shows a greeting", (tester) async {
  // Inflate the widget tree
  await tester.pumpWidget(MaterialApp(home: TextExampleWidget()));

  // Enter "Bob" into the TextField
  await tester.enterText(find.byType(TextField), "Bob");

  // Trigger a rebuild
  await tester.pump();

  // Expect to find a greeting for Bob.
  expect(find.text("Hello Bob"), findsOneWidget);
});
```

[Code](https://github.com/fluttered-book/widget_testing_examples/blob/main/test/text_widget_test.dart)

## Debugging

### Printing

You can of course use the good old `print()` function for outputting messages
to help you debug.
The problem is that it will also print when you release the app.
If used extensively it has a slight performance overhead.
Another issue is that you could end up having the app unintentionally output
sensitive information such as API keys, or other secret.
Also, on some platforms excessive calls to `print()` might be truncated.

To avoid the aforementioned issues it is better to use the following:

```dart
if (kDebugMode) debugPrint("Your message");
```

### Debugger

Having `if (kDebugMode) debugPrint("It worked!")` sprinkled all over the
application is pretty ugly.
It is much cleaner and even more useful to use the debugger that is build into
Android Studio instead.

Just click on the line number for where you want to pause execution of the app.
A 🔴 will appear.

![Line with breakpoint](../images/breakpoint.png)

Now, right-click on a test and choose debug.

![Debug test](../images/debug-test.png)

Or if you want to interact directly with the app then you can just run it using
the 🪲 button.

![Run debug](../images/run-debug.png)

#### Conditional debugger

It is sometimes really useful to only pause for debugging when a certain
condition is met.

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
