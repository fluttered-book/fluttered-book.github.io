---
title: "Challenge: Unit test Calculator"
weight: 3
---

# Challenge: Unit test Calculator

## Introduction

This exercise is based on the familiar RPN calculator concept that you have
seen in previous exercises
([her](http://localhost:1080/docs/flutter-basics/challenge-calculator/) and
[her](http://localhost:1080/docs/flutter-basics/challenge-calculator/)).

The implementation you will be writing unit tests for has been altered to make
all commands pure, meaning they don't have any observable effect other than the
return value.
In other words; they are pure since they are free from side effects.

The abstract base-class for all commands looks like this:

```dart
abstract class Command {
  CalculatorState execute(CalculatorState state);
}
```

Where `CalculatorState` is:

```dart
class CalculatorState {
  CalculatorState({required this.stack, required this.history});

  final List<num> stack;
  final List<List<num>> history;
}
```

It means that a `Command` takes `CalculatorState` as parameter.
A `CalculatorState` consist of stack of numbers and history of previous stack
to facilitate undo.

The `execute()` returns a new `CalculatorState` instead of modifying the
argument.

## Getting started

Clone or download the repository
[calculator_cli](https://github.com/fluttered-book/calculator_cli).

**Run application**

```sh
dart run
```

**Run tests**

```sh
dart test
```

## What to do

Your job is now to write unit-tests for all the commands.

You should write tests to verify that `execute()` for each command returns:

- Enter
  - a new stack with given value at the end and old stack in history
- Clear
  - an empty state
- Undo
  - previous state restored from history
- Add
  - stack with the last two values added, and history so that the old state can be restored
  - does nothing when stack length is less than 2
- Subtract
  - stack with the last two values subtracted, and history so that old state
    can be restored
  - does nothing when stack length is less than 2
- Multiply
  - stack with the last two values multiplied, and history so that old state
  - does nothing when stack length is less than 2
- Divide
  - stack with the last two values divided, and history so that old state
  - does nothing when stack length is less than 2

Compare your solution to the [solution
branch](https://github.com/fluttered-book/calculator_cli/tree/solution).

## Reflection

[Side effects](<https://en.wikipedia.org/wiki/Side_effect_(computer_science)>) is
the enemy of testability.
A function or method is free from side effects (aka pure) if the only
observable effect from invoking it is returning a value that is based solely on
its arguments.
Code without side effect is a lot easier to write tests for.
Because you can just write assertions for return value without having to
consider internal state changes in objects.
The reason why `CalculatorState` is immutable is so the commands needs to be
implemented without side effects.

The `main()` method in `bin/calculator_cli.dart` contains some logic in form of
a switch statement.
It also reads input and writes output to the console, which is a kind of side
effect.

Reflect over the following questions.

- Can you write test for [bin/calculator_cli.dart](https://github.com/fluttered-book/calculator_cli/blob/main/bin/calculator_cli.dart)?
- How would your rewrite `bin/calculator_cli.dart` to be more testable?
