---
title: "Challenge: Widget test Calculator"
weight: 5
---

# Challenge: Widget test Calculator

<iframe src="https://fluttered-book.github.io/calculator_gui/" width="375" height="667px"></iframe>

Can you guess what this challenge is about?
Yes, write widget test for a Calculator app.

## Getting started

Clone the [calculator_gui](https://github.com/fluttered-book/calculator_gui)
repository.

```sh
git clone https://github.com/fluttered-book/calculator_gui.git
```

## What to do?

Write widget test for the app.
Create the file `test/calculator_app_test.dart` with your test code.
You can use the following snippet as a starting point:

```dart
void main() {
  testWidgets('Description of the test', (WidgetTester tester) async {
    await tester.pumpWidget(CalculatorApp());

    await tester.tap(find.widgetWithText(CalculatorButton, '1'));
    await tester.pump();

    expect(find.widgetWithText(CalculatorDisplay, '1'), findsOne);
  });
}
```

It is not feasible to cover all the possible calculations you can do with the
app.
So what do you need to test to be confident you've covered enough functionality?

I suggest you write a list of test cases for the app in plain English before
you start to write test code.

The `CalculatorDisplay` got two `Text` widgets.
One for the number that is currently being entered.
Another for the stack.
How do you distinguish between them in your tests code?

## Hints

### Keys

If you have the following widget tree:

```dart
Column(
  children: [
    Text("Foo"),
    Text("Bar"),
  ]
)
```

Then you can add keys.

```dart
Column(
  children: [
    Text(key: ValueKey("foo"), "Foo"),
    Text(key: ValueKey("bar"), "Bar"),
  ],
)
```

And use the key to find the widget.

```dart
find.byKey(ValueKey('foo'))
```

### Extension methods

You mind find that you are repeating the same code over and over again to find
a button or text widget.

You could get rid of some of the duplication by writing a couple of [extension
methods](https://dart.dev/language/extension-methods) for `CommonFinders`.
Think of it as augmenting the existing finders with finders specific to your
app.

Here is a somewhat silly example:

```dart
extension on CommonFinders {
  Finder foo() {
    find.byKey(ValueKey('foo'));
  }
}
```

Then in your test, you could write `find.foo()` instead of
`find.byKey(ValueKey('foo'))`.
