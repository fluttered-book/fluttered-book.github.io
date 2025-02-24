---
title: Introduction
weight: 1
---

{{< classic-dartpad >}}

# Introduction to testing

## Background

Thorough testing is an important part of software development.
Manually testing each part of your application can work for tiny projects.
But as the size of the project grows it becomes tedious to test every
piece of functionality each time a change is made.
Not testing can lead to bugs being introduced without developers noticing.
The last thing you want is to learn about bugs from bad reviews on App Store.

<script src="https://unpkg.com/@dotlottie/player-component@2.7.12/dist/dotlottie-player.mjs" type="module"></script><dotlottie-player src="https://lottie.host/b3cfed52-1978-447c-a620-cca17590b5c8/WhfOde4csu.lottie" background="transparent" speed="1" style="width: 300px; height: 300px" direction="1" playMode="normal" loop controls autoplay></dotlottie-player>

The solution is to write test in code, that the computer can be executed
automatically with just a single command.

Writing a good and reliable suite of tests requires that some effort is
invested throughout the project.
I call it an investment, because it requires some extra effort upfront.
But, you will benefit greatly as the project grows.

It is important to consider your testing strategy early in a project.
Because how you write your code dictate how easily it can be tested.
When a development team don't have tests early on, it tends to become difficult
or impossible to add tests later on.
This is especially true for new/inexperienced developers.

The problem with testing, is that your app provides value to your users
by interacting with things outside the app itself.
Whether it be users or APIs.
Users can be unpredictable.
And external APIs can also act in ways you didn't expect.
In order for your tests to be reliable you need to be able to isolate them
from these external entities.
If the app code isn't written in a way that allows substituting external
entities then you can't write good tests for it.
Simple as that.

> _"If you find a bug in your code, it means you have made a mistake. If your
> tests didn't reveal the bug, it means you have made two mistakes."_

## How to write tests

In Dart and Flutter you use the [test](https://pub.dev/packages/test) package
for writing your tests.

Your tests live in `test/` folder in your project.
Say you have a file named `lib/commands.dart` that you want to write tests for.
You will then write your tests in a file named `test/commands_test.dart`.
Here is an example of a test.
Just imagine that it is split up into separate files as indicated.

```run-dartpad:theme-dark:mode-dart:run-false:width-100%:height-500px
import 'package:test/test.dart';

// lib/commands.dart
class AddCommand {
  List<num> apply(List<num> stack) {
    if (stack.length < 2) return stack;
    final operand2 = stack.last;
    final operand1 = stack.elementAt(stack.length - 2);
    return [...stack.take(stack.length - 2), operand1 + operand2];
  }
}

// test/commands_test.dart
void main() {
  test('AddCommand.apply() returns a new list with the last two values added', () {
    final origStack = [1, 2];
    final newStack = AddCommand().apply(origStack);

    expect(newStack, equals([3]));
    expect(newStack, isNot(equals(origStack)));
  });
}
```

_When I embed tests on the page it gives some warnings.
Click the "hide" button to make it go away._

Each test file have a `main()` function, wherein one or more tests can be
defined.
A test is defined with a call to `test()` function from the test package.
It takes two arguments.
First, a string describing what is tested.
Second, the test code as a function.

You can use the `expect()` function to specify assertions for the test.
Assertions are conditions that should be true for the test to pass.

### Grouping

It's common to have several tests for the same class.
Even sometimes multiple tests for the same method.
You can use the `group()` function to group tests together, as shown below.

```run-dartpad:theme-dark:mode-dart:run-false:width-100%:height-720px
import 'package:test/test.dart';

// lib/commands.dart
class AddCommand {
  late num operand1;
  late num operand2;

  List<num> apply(List<num> stack) {
    if (stack.length < 2) return stack;
    operand2 = stack.last;
    operand1 = stack.elementAt(stack.length - 2);
    return [...stack.take(stack.length - 2), operand1 + operand2];
  }

  @override
  List<num> unapply(List<num> stack) {
    return [...stack.take(stack.length - 1), operand1, operand2];
  }
}

// test/commands_test.dart
void main() {
  group("AddCommand", () {
    group("apply()", () {
      test('adds the last two values', () {
        // Arrange
        final origStack = [1, 2];

        // Act
        final newStack = AddCommand().apply(origStack);

        // Assert
        expect(newStack, isNot(equals(origStack)));
        expect(newStack, equals([3]));
      });

      test("does nothing when length of stack is less than 2", () {
        // Arrange
        final origStack = [1];

        // Act
        final newStack = AddCommand().apply(origStack);

        // Assert
        expect(newStack, equals(origStack));
      });
    });

    group("unapply", () {
      test("replaces result with operands and removes itself from the history",
          () {
        // Arrange
        final command = AddCommand();
        final origStack = command.apply([1, 2]);

        // Act
        final newStack = command.unapply(origStack);

        // Assert
        expect(newStack, isNot(equals(origStack)));
        expect(newStack, equals([1, 2]));
      });
    });
  });
}
```

If you are familiar with testing frameworks in the JavaScript/Node ecosystem,
such as [Jasmine](https://jasmine.github.io/) and [Jest](https://jestjs.io/),
then you can use the following table to help you convert your existing
knowledge.

| JavaScript                                                    | Dart                                                                           |
| ------------------------------------------------------------- | ------------------------------------------------------------------------------ |
| [describe](https://jestjs.io/docs/api#describename-fn)        | [group](https://pub.dev/documentation/test/latest/test/group.html)             |
| [test/it](https://jestjs.io/docs/api#testname-fn-timeout)     | [test](https://pub.dev/documentation/test/latest/test/test.html)               |
| [beforeEach](https://jestjs.io/docs/api#beforeeachfn-timeout) | [setUp](https://pub.dev/documentation/test/latest/test/setUp.html)             |
| [beforeAll](https://jestjs.io/docs/api#beforeallfn-timeout)   | [setUpAll](https://pub.dev/documentation/test/latest/test/setUpAll.html)       |
| [afterEach](https://jestjs.io/docs/api#aftereachfn-timeout)   | [tearDown](https://pub.dev/documentation/test/latest/test/tearDown.html)       |
| [afterAll](https://jestjs.io/docs/api#afterallfn-timeout)     | [tearDownAll](https://pub.dev/documentation/test/latest/test/tearDownAll.html) |

### Matchers

They are functions that help you specify assertions.

The first parameter to `expect()` function is the actual value.
The second is a matcher specifying some condition you expect to be true.

Have you noticed that `isNot()` and `equals()` are both used as arguments for
the second parameter?
They are both matchers.
You can find more here: [**list of matchers**](https://pub.dev/documentation/matcher/latest/matcher/).

As said, matchers help you describe conditions that must be true for the test
to pass.

## Types of tests

You can test your code at several levels of granularity.
The examples shown so far are called **unit tests**.
That is because they test at the smallest level of granularity (class, method
or function level).

It is also common to write tests that verify that multiple parts of a system
work together as expected.
These are called **integration tests**.

You can also write tests that cover the entire system.
Often this means everything from simulated user interaction to talking to API
or database.
These kinds of tests are called system or **end-to-end (e2e) tests**.

With Flutter, we also have **widget tests**.
As the name implies they test widgets.
Meaning, they simulate user interaction with widgets and can verify that the
widget update as expected.

Tests that simulates user interaction requires a bit more tooling than what is
shown here.
They deserve their own section, which you will get to in a bit.
