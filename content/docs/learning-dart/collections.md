---
title: Collections
weight: 2
---

{{< classic-dartpad >}}

# Collection

## Introduction

Almost all applications deals with collections of things in some way, making
collections an important building block.

## Lists

A `List` in Dart is similar to lists or arrays of other languages.
It is simply an ordered group of objects.

```dart
List<int> list = [1, 2, 3];
```

**Notice**: elements are encapsulated within square brackets.

If we leave out the type `List<int>` then it will be inferred by the compiler
since all elements are `int`.

```dart
var list = [1, 2, 3];
```

If we instead define the list as `[1, 2, 3.0]` then it will be inferred as type
`List<num>`, since `num` is the closet common subclass of both `int` and
`double`.

There are two ways to define an empty list of some type.

```dart
List<int> list1 = [];
var list2 = <int>[];
```

Remember, if you leave out the type then it will be inferred as `dynamic`.

```run-dartpad:theme-dark:mode-dart:width-100%:height-300px
void main() {
  List<int> list1 = [1, 2, 3];
  print("list1 is ${list1.runtimeType}");

  var list2 = [1, 2, 3];
  print("list2 is also ${list2.runtimeType}");

  var list3 = [1, 2, 3.0];
  print("list3 is ${list3.runtimeType} since all elements are num");
}
```

## Set

A set is an unordered collection of unique items.

```dart
Set<int> set = {1, 2, 3};
```

**Notice**: elements are encapsulated within curly-brackets.

Here is a silly example of what is meant by a collection unique items.
If you do:

```dart
var set = {1, 2, 3, 3};
```

You will only get a set with 3 values because `3` and `3` are the same.

An example use case for sets are tags on a block post.
This article could have the tags:

```dart
final tags = {"programming", "oop", "dart", "collections"};
```

We could find related posts by taking the intersection (overlap) between the
two set of tags.

```dart
final otherTags = {"Python", "collections"};
final tagsInCommon = tags.intersection(otherTags);
```

The variable `tagsInCommon` will be `{"collections"}` since that is the only
element contained in both sets.

There are of cause many other use cases for sets.
Just remember they don't maintain order.
Meaning you can't rely on the order of elements when looping over a set being
the same as they were added.

## Maps

A map is a collection of key/value pairs.

```dart
Map<String, dynamic> map = {
  "name": "Joe",
  "age": 21
};
```

**Notice**: syntax is similar to objects in JSON.

In the example above I've specified the value to be of type `dynamic`.
If I had left out the type then it would be inferred as type `Object` since
that is the common base class of both `String` and `int`.

You will work with maps when retrieving data from a web-API.

## Iterables

The collection types in Dart such as `List`, `Set` and `Map` are `Iterable`,
which provides you with a bunch of convenient methods for operating across
their elements.
These methods can be chained together making them really powerful.
Learning to utilize them allows you to express transformations more elegantly
than with explicit loops.

The concepts you will learn about in the section applies to many other
mainstream programming languages as well, though semantics varies slightly.

### Language comparison

These kinds of methods exist in many programming languages, though naming
might be different.
So, there is a good chance that you can recognize having seen something similar
in another language already.

| Description                                       | Dart                                                                               | C#                                                                                           | JavaScript                                                                                                        |
| ------------------------------------------------- | ---------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------- |
| Filter (keep) elements that match given predicate | [where](https://api.dart.dev/stable/dart-core/Iterable/where.html)                 | [Where](https://learn.microsoft.com/en-us/dotnet/api/system.linq.enumerable.where)           | [filter](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array/filter)           |
| Map (convert) each element to another type        | [map](https://api.dart.dev/stable/dart-core/Iterable/map.html)                     | [Select](https://learn.microsoft.com/en-us/dotnet/api/system.linq.enumerable.select)         | [map](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array/map)                 |
| Flatten nested collections                        | [expand](https://api.dart.dev/stable/dart-core/Iterable/expand.html)               | [SelectMany](https://learn.microsoft.com/en-us/dotnet/api/system.linq.enumerable.selectmany) | [flatMap](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array/flatMap)         |
| Group elements by a common value                  | [groupBy](https://pub.dev/documentation/collection/latest/collection/groupBy.html) | [GroupBy](https://learn.microsoft.com/en-us/dotnet/api/system.linq.enumerable.groupby)       | [Object.groupBy](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Object/groupBy) |

### Visualization

Here are some examples to make it a bit easier to wrap your head around.

| Input                          | Operation                  | Output                                     |
| ------------------------------ | -------------------------- | ------------------------------------------ |
| [🍔, 🍕, 🍔]                   | .where((x) => x == 🍔)     | (🍔, 🍔)                                   |
| [🍔, 🍔, 🍔]                   | .map((x) => 🍕)            | (🍕, 🍕, 🍕)                               |
| [[🍕, 🍕], [🍔, 🍔]]           | .expand((x) => x)          | (🍕, 🍕, 🍔, 🍔)                           |
| [[🍲, 🌶️], [🍲, 🍅], [🍞, 🧈]] | groupBy(list, (x) => x[0]) | {🍲: [[🍲, 🌶️], [🍲, 🍅]], 🍞: [[🍞, 🧈]]} |

_Lists are represented with `[]`, maps in the form `{"key": "value"}` and iterables with `()`._

### Example usage

Run the code an observe the result.
You can play around with it if you want.

```run-dartpad:theme-dark:mode-dart:width-100%:height-460px
import "package:collection/collection.dart";

const movies = [
  (title: "Alien", year: 1979),
  (title: "Let the Right One In", year: 2008),
  (title: "Aliens", year: 1986),
  (title: "Jaws", year: 1975),
  (title: "The Silence of the Lambs", year: 1991),
];

void main() {
  print("\n[Newer than 1990]");
  print(movies.where((m) => m.year > 1990));

  print("\n[Decades movies where released in]");
  print(movies.map((m) => "${m.year - (m.year % 10)}s"));

  print('\n[Group by first letter of title]');
  print(groupBy(movies, (m) => m.title[0]));
}
```

## Exercise

Implement each function so that the test pass.

Can you solve them without writing any loops?

Help:

- [Iterables](https://dart.dev/codelabs/iterables)
- [Collection library](https://pub.dev/documentation/collection/latest/collection/collection-library.html)

### Data

```dart
const List<Person> people = [
  (id: 1, name: "Guillaume Strasse", language: "Danish", age: 41),
  (id: 2, name: "Anestassia Echallie", language: "English", age: 47),
  (id: 3, name: "Laura Ringsell", language: "Swedish", age: 14),
  (id: 4, name: "Huey Ragsdall", language: "Latvian", age: 78),
  (id: 5, name: "Winny Pouton", language: "Danish", age: 72),
  (id: 6, name: "Franzen Fahy", language: "Swedish", age: 86),
  (id: 7, name: "Killie Spatoni", language: "English", age: 16),
  (id: 8, name: "Damaris Grebner", language: "Swedish", age: 39),
  (id: 9, name: "Haleigh Rheubottom", language: "Georgian", age: 99),
  (id: 10, name: "Anabel Bariball", language: "English", age: 13),
  (id: 11, name: "Lettie Toon", language: "Danish", age: 55),
  (id: 12, name: "Ginger Alsopp", language: "Danish", age: 75),
  (id: 13, name: "Lee Gazey", language: "English", age: 30),
  (id: 14, name: "Timotheus Gosnall", language: "English", age: 82),
  (id: 15, name: "Elsworth Huntly", language: "Korean", age: 9)
];
```

### Age groups

| Age        | Category   |
| ---------- | ---------- |
| < 18       | adults     |
| < 18       | minors     |
| < 13       | kids       |
| > 13, < 18 | youngsters |

### Code

{{< exercise path="/content/docs/learning-dart/codelab/lib/iterables/" height="720px" >}}
