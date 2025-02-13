---
title: Widget tests
weight: 3
---

# Widgets tests

You've seen how you can test functions and methods.
This section will build on that to show you how to test widgets.

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
`tester.pumpWidget()` instead.
We can make it build/render another frame by calling `tester.pump()`.

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
