---
title: Unit tests
weight: 2
---

{{< classic-dartpad >}}

# Unit tests

## Introduction

Let's practice writing some unit tests.
I've prepared a repository with some code for you to test.

We are writing a calculator app.
It's going to start out as a simple <abbr title="Command-line interface">CLI</abbr> app.
In the next section we will expand it to a full-blown Flutter app.
But for now, we'll just leave it as CLI app, because it makes it simpler.

## The concept

The calculator is based on <abbr title="Reverse Polish Notation">RPN</abbr>, so
we avoid having to deal with complicated operator precedence rules.

RPN was introduced in a [previous exercise](../../learning-dart/rpn).
If you skipped the exercise, you should watch the video below for an
explanation.

<figure>
<iframe width="720" height="400" src="https://www.youtube.com/embed/7ha78yWRDlE?si=M21W2n2Sq_0yp9bM" title="YouTube video player" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share" referrerpolicy="strict-origin-when-cross-origin" allowfullscreen></iframe>
  <figcaption><i>Reverse Polish Notation and The Stack - Computerphile</i></figcaption>
</figure>

If you've done the previous exercise on RPN, you should know that we are
changing the rules a bit this time, so that the stack is immutable.

Immutable data types are types that don't change.
For classes, it means that all fields are final.
For lists, it means that instead of modifying the existing list we create a new
list with values from the previous list with our modification.

### Mutating a list

Here is what modifying a list looks like.

```run-dartpad:theme-dark:mode-dart:run-false:width-100%:height-200px
void main() {
  final list = [1,2,3];
  print(list);
  list.add(4);
  print(list);
}
```

Line 4 adds the number `4` to the end of the list.

### Creating a list without mutating

Dart has a special syntax for creating a new list that includes all elements
from an existing list.

```run-dartpad:theme-dark:mode-dart:run-false:width-100%:height-200px
void main() {
  final list1 = [1,2,3];
  final list2 = [...list1, 4];
  print(list1);
  print(list2);
}
```

Notice the `...` part and how we get a new list with all elements from the
previous and an additional element without changing the original list.

You might be familiar with `...` already from JavaScript.

### State

The state of our calculator will be represented by an instance of this class.

```dart
class CalculatorState {
  CalculatorState({
    required this.stack,
    required this.history,
  });

  final List<num> stack;
  final List<List<num>> history;

  static CalculatorState empty() => CalculatorState(stack: [], history: []);

  @override
  String toString() {
    return "{stack: $stack, history: $history}";
  }
}
```

It has a stack of numbers as described in the video.
The `List<List<num>> history` gives us a simple way to undo operations.
By just keeping a copy of the previous stack.

### Commands

All operations on the stack is will be done with an implementation of this
interface:

```dart
abstract class Command {
  InternalState apply(InternalState state);
}
```

_In Dart we use abstract classes as interfaces since there isn't any "interface" keyword._

To push/enter a number to the stack we have this implementation:

```dart
class Enter implements Command {
  const Enter(this.number);

  final num number;

  @override
  InternalState apply(InternalState state) {
    return InternalState(
      stack: [...state.stack, number],
      history: [...state.history, state.stack],
    );
  }
}
```

A new stack is created with all numbers from the previous stack plus the new
number.
The history becomes the previous history plus the previous stack.
That way, an undo command can be implemented as:

```dart
class Undo extends Command {
  @override
  InternalState apply(InternalState state) {
    if (state.history.isEmpty) return state;
    return InternalState(
      stack: state.history.last,
      history: [...state.history.take(state.history.length - 1)],
    );
  }
}
```

Where `[...state.history.take(state.history.length - 1)]` just creates a new
list with all elements from `state.history` except the last.

## Exercise

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

Your job is now to write unit-tests for all the commands.

You should write tests to verify that `apply()` for each command returns:

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

Reflect over the following questions.

- Can you write test for [bin/calculator_cli.dart](https://github.com/fluttered-book/calculator_cli/blob/main/bin/calculator_cli.dart)?
- How would your rewrite `bin/calculator_cli.dart` to be more testable?
