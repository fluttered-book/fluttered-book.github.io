---
title: Generators
weight: 9
---

{{< classic-dartpad >}}

# Generators

## Introduction

Generators are functions that lazily produce a sequence of values.
A generators return value can either be
[Iterable](https://api.dart.dev/dart-core/Iterable-class.html) for functions
that produce values synchronously, or
[Stream](https://api.dart.dev/dart-async/Stream-class.html) for functions that
produce values asynchronously.
More on asynchronous programming in Dart in a later chapter.

### Synchronous generator

```run-dartpad:theme-dark:mode-dart:width-100%:height-300px
Iterable<int> countdown(int start) sync* {
  for (var i = start; i >= 0; i--) {
    yield i;
  }
}

void main() {
  for (var value in countdown(10)) {
    print(value);
  }
}
```

**Notice**: the `sync*` in the function definition, which indicates it is a
synchronous generator.

A generator **yield** values instead of returning a single value like a normal
function.
The generator in the example yield a finite sequence of values, but a generator could also yield an infinite amount of values.
For example, you could have a random number generator that yields an endless
sequence of random numbers.

### Asynchronous generator

Here it is again, rewritten as an asynchronous function.

```run-dartpad:theme-dark:mode-dart:width-100%:height-300px
Stream<int> countdown(int start) async* {
  for (var i = start; i >= 0; i--) {
    yield i;
  }
}

main() async {
  await for (var value in countdown(10)) {
    print(value);
  }
}
```

**Notice**: the `async*` in the function definition.
And that the return type has changed to `Stream<int>`.

To iterate over the values of an async generator with a for-loop, we need to
add `async` to the method, and `await` to the for-loop.

A use case for an async generator could be to implement an infinite scrolling
page, like the feed on Instagram.

```dart
Stream<List<Post>> feed() async* {
  var pageNumber = 1;
  while (true) {
    yield await fetchPage(pageNumber);
    pageNumber++;
  }
}
```

More on async/await later.
If you can't wait then you can read more about it
[here](https://dart.dev/libraries/async/async-await).

## Challenge

Write an synchronous generator implementation of fizz buzz.

> Fizz buzz is a group word game for children to teach them about division.
> Players take turns to count incrementally, replacing any number divisible by
> three with the word "Fizz", and any number divisible by five with the word
> "Buzz", and any number divisible by both 3 and 5 with the word "Fizz Buzz".

- [Wikipedia](https://en.wikipedia.org/wiki/Fizz_buzz)

## Example

`1, 2, Fizz, 4, Buzz, Fizz, 7, 8, Fizz, Buzz, 11, Fizz, 13, 14, Fizz Buzz, 16, 17, Fizz, 19, Buzz, Fizz, 22, 23, Fizz, Buzz, 26, Fizz, 28, 29, Fizz Buzz`

# Code

Implement a fizz buzz generator using
[streams](https://dart.dev/articles/libraries/creating-streams).

{{< exercise path="/content/docs/learning-dart/codelab/lib/fizzbuzz/" height="720px" >}}
