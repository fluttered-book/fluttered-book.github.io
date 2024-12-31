---
title: Introduction
weight: 1
---

{{< classic-dartpad >}}

# Introduction to testing

## Background

Thorough testing is an important part of software development.
Manually testing each part of your application can work for tiny projects, but
as the size of the project grows then it becomes tidies to test every piece of functionality each time a change is made.

<script src="https://unpkg.com/@dotlottie/player-component@2.7.12/dist/dotlottie-player.mjs" type="module"></script><dotlottie-player src="https://lottie.host/b3cfed52-1978-447c-a620-cca17590b5c8/WhfOde4csu.lottie" background="transparent" speed="1" style="width: 300px; height: 300px" direction="1" playMode="normal" loop controls autoplay></dotlottie-player>

The solution is to write test in code that the computer can be executed
automatically with just a single command.

Writing a good and reliable suite of tests requires that some effort is
invested throughout the project.

I call it an investment because it requires some extra effort upfront.
But, you will benefit greatly as the project grows.

It is important to consider your testing strategy early in a project.
Because how you write your code dictate how easily it can be tested.
When a development team don't have tests early on, it tends to become difficult
or impossible to add later on.
This is especially true for new/inexperienced developers.

The problem with testing is that your application provides value by interacting
with things outside the application itself.
Whether it be users or APIs.
In order for your tests to be reliable your need to be able to isolate it from
these external entities.
If the application code isn't written in a way that allows substituting
anything external, then you can't write tests for it.
Simple as that.

> _"If you find a bug in your code, it means you have made a mistake. If your
> tests didn't reveal the bug, it means you have made two mistakes."_

## How to write test

In Dart and Flutter you use the [test](https://pub.dev/packages/test) package
for writing your tests.

Your tests lives in `test/` folder in your project.
Say you have a file name `lib/commands.dart` you want to tests for.
Then you will write your tests in a file named `test/commands_test.dart`.

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

Each test file have a `main()` function where within you can define one or more
tests.
A test is defined with a call to `test()` function from the test package.
It takes two parameters.
First, a string describing what is tested.
Second, a function containing the test code.

You use `expect()` function to specify assertions that should be true for the
test to pass.

### Grouping

It's common to have several tests for the same class.
Even sometimes multiple for the same method.
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
        final origStack = [1, 2];
        final newStack = AddCommand().apply(origStack);

        expect(newStack, isNot(equals(origStack)));
        expect(newStack, equals([3]));
      });

      test("does nothing when length of stack is less than 2", () {
        final origStack = [1];
        final newStack = AddCommand().apply(origStack);
        expect(newStack, equals(origStack));
      });
    });

    group("unapply", () {
      test("replaces result with operands and removes itself from the history",
          () {
        final command = AddCommand();
        final origStack = [1, 2];
        final newStack = command.unapply(origStack);

        expect(newStack, isNot(equals(origStack)));
        expect(newStack, equals([1, 2]));
      });
    });
  });
}
```

If you are familiar with testing frameworks in JavaScript/Node ecosystem such
as [Jasmine](https://jasmine.github.io/) and [Jest](https://jestjs.io/) then
you can translate `describe` to `group` in Dart.
And `it` to `test` in Dart.

### Matchers

The first parameter to `expect()` function is the actual value.
The second is some condition you expect to be true.
Have you noticed that `isNot()` and `equals()` are both used as arguments for
the second parameter?

These functions are called matchers.
And there are actually [a bunch of
them](https://pub.dev/documentation/matcher/latest/matcher/).
They all help you describe conditions that must be true for the test to pass.

## Types of tests

You can test your code at several levels of granularity.
The examples shown so far are called unit tests, because the test at the
smallest level of granularity, that is class and method level.

It is also common to write tests to verify that multiple parts of a system work
together as expected.
These are called integration tests.

One can also write tests that cover the entire system.
Often this means from simulated user interaction to database.
These are called system or end-to-end (e2e) tests.

With Flutter we also have widget tests.
As the name implies they test widgets.
Meaning they simulate user interaction with widgets and can verify they update
as expected.

Tests that simulates user interaction requires a bit more tooling than shown in
here.
So, they deserve their own section, which you will get to in a bit.
