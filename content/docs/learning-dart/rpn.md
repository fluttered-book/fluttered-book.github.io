---
title: "Challenge: Reverse Polish notation"
weight: 9
---

# Calculating with Reverse Polish notation (RPN)

Watch the video for an introduction to the concepts.

<figure>
<iframe width="720" height="400" src="https://www.youtube.com/embed/7ha78yWRDlE?si=M21W2n2Sq_0yp9bM" title="YouTube video player" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share" referrerpolicy="strict-origin-when-cross-origin" allowfullscreen></iframe>
  <figcaption><i>Reverse Polish Notation and The Stack - Computerphile</i></figcaption>
</figure>

Reverse polish notation doesn't have anything to do Flutter.
Here we are just using it to practice some writing Dart.
And learning about stack, because that becomes important later for navigation
in apps.

## Description

Implement a simple calculator based on Reverse Polish Notation (RPN).
RPN is also known as postfix notation.

We are used to what is called infix notation where the operator is between the
operands.
With postfix notation, the operator follows the operands.
RPN has the advantage of not using parentheses.
Values entered are stored in a stack.

**Picture a stack of cards**

![Stack of cards](../images/pexels-zauro-58562.jpg)

- You put a card in the stack by placing it on top of other cards.
- You can remove a card by taking the topmost card.
- You can also peek at the card in the top of the stack.

## Create a project

Open a terminal.
Use `cd` to navigate to the folder where you want to store your project.
Then create a new Dart project with:

```dart
dart create rpn_calculator
```

It will create a sub-folder called `rpn_calculator/`.
Open it in Android Studio.

In the project you will see the following files:

```
├── analysis_options.yaml
├── bin
│   └── rpn_calculator.dart
├── CHANGELOG.md
├── lib
│   └── rpn_calculator.dart
├── pubspec.lock
├── pubspec.yaml
├── README.md
└── test
    └── rpn_calculator_test.dart
```

The `main()` function (entry point for the program) is defined in
`/bin/rpn_calculator.dart`.
All your logic (command implementations) should be added to files in the `lib/`
folder.
You can ignore all other files and folders for now.

## Implementation

Base your stack on the [List class](https://api.dart.dev/stable/2.19.0/dart-core/List-class.html).
The end of the list, should represent the top of the stack.

Stacks support 3 operations.

| Description                   | Stack operation | List operation                                                                  |
| ----------------------------- | --------------- | ------------------------------------------------------------------------------- |
| Retrieve the top-most element | peek            | [last](https://api.dart.dev/stable/2.19.0/dart-core/List/last.html)             |
| Remove the top-most element   | pop             | [removeLast](https://api.dart.dev/stable/2.19.0/dart-core/List/removeLast.html) |
| Add a new element to the top  | push            | [add](https://api.dart.dev/stable/2.19.0/dart-core/List/add.html)               |

An operation (+, -, \*, / etc) replaces values in the stack with the result.
You can support more operations if you want.

You will also need an operation to push a value to the stack.

Operations should implement using the [Command
pattern](https://refactoring.guru/design-patterns/command), or variation
thereof.

Make a class for each operation.
They should all implement the same `Command` interface.

_Remember: in Dart we can use an abstract class when we need just an
interface._

```dart
abstract class Command {
  void execute(List<num> stack);
}
```

You should implement `Command` in a subclass for each operation.

```dart
class AddCommand implements Command {
  @override
  void execute(List<num> stack) {
    // implementation goes here
  }
}
```

Can you find a way to implement undo functionality?
Maybe you need another stack for it?

## What about UI?

So you have a bunch of classes.
That's not really useful.
You might be thinking "how do I make a GUI for it".
I will show you that in an upcoming chapter.
For now, you could try to make a CLI for it.

Here is an example of how you can read input and print output in a CLI app.

```dart
import 'dart:io';

void main()
{
    print("Enter your name?");
    String? name = stdin.readLineSync();
    print("Hello, $name!");
}
```

Importing `'dart:io'` allows you to get line of text input using
`stdin.readLineSync()`.

## What about infix notation?

Implementing a calculator based on infix notations requires that the input gets
converted into a tree structure that then gets recursively evaluated to
calculate a result.

Here is a video from Computerphile YouTube channel showing how to implement it
in Python.

<figure>
<iframe width="720" height="400" src="https://www.youtube.com/embed/7tCNu4CnjVc?si=PlAKIduwBftt5eBX" title="YouTube video player" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share" referrerpolicy="strict-origin-when-cross-origin" allowfullscreen></iframe>
<figcaption><i> Coding Trees in Python - Computerphile</i></figcaption>
</figure>
