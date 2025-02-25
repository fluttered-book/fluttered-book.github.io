---
title: "Challenge: Unit test Quiz app"
weight: 3
---

# Challenge: Unit test Quiz app

## Introduction

This challenge is based on a modified version of the Quiz app from
[here](../../interactivity/quiz/).

In this version I've extract the logic from UI, such that unit tests can be
written for the logic.

The logic have been extracted from `QuizScreen` and moved to `QuizModel` class
which extends
[ChangeNotifier](https://api.flutter.dev/flutter/foundation/ChangeNotifier-class.html).
A `ChangeNotifier` is an implementation of the classic [observer
pattern](https://en.wikipedia.org/wiki/Observer_pattern).

Here is a short YouTube video I've found that shows how `ChangeNotifier` can be
used.

<iframe width="560" height="315" src="https://www.youtube.com/embed/uQuxrZE2dqA?si=_vaJM46hqY8CdMBa" title="YouTube video player" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share" referrerpolicy="strict-origin-when-cross-origin" allowfullscreen></iframe>

_Provider 📱 Simple State Management • Flutter Tutorial_

## Getting started

Clone the **separate-logic** branch of quiz app repository.

```sh
git clone -b separate-logic https://github.com/fluttered-book/quiz.git
```

**Run application**

```sh
dart run
```

**Run tests**

```sh
dart test
```

## What to do

Write unit-tests for `QuizModel` found in `lib/quiz_model.dart`.
Your tests should be written in `test/quiz_model_test.dart`.

`QuizModel` has side effects.
In fact its methods are void.

- How can you write tests, so that a change in the logic will make a test fail?
- What would be a good description for each of the test you come up with?
