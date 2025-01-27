---
title: Patterns
weight: 4
---

{{< classic-dartpad >}}

# Patterns

{{< hint warning >}}
Patterns in this context is about pattern matching and should not to be
confused with design patterns or regular expressions.
{{< /hint >}}

Many modern object-oriented programming languages (including Dart) are
increasingly adopting features previously associated with the paradigm of
functional programming.

You likely already know about lambda expressions (aka anonymous functions).

Another functional programming concept that have found its way into many OOP
languages are pattern matching.
The exact functionality and syntax can vary a bit between languages, but
the overall idea is the same.
A variation of pattern matching can be found in
[C#](https://learn.microsoft.com/en-us/dotnet/csharp/fundamentals/functional/pattern-matching)
and
[Java](https://docs.oracle.com/en/java/javase/21/language/pattern-matching.html).
There is also a [proposal for ECMAScript
(JavaScript)](https://tc39.es/proposal-pattern-matching/).

In short, pattern matching can be used to destructure objects and in many ways
provide an elegant alternative to express conditions when compared to boolean
logic.

Patterns provide a compact syntax to express conditionals based on the "shape"
of a value and extract values from objects.

![Pattern sorter](../images/pexels-towfiqu-barbhuiya-3440682-11030155.jpg "Towfiqu barbhuiyaPattern sorter toy. Picture by Towfiqu barbhuiya")

## Records

To support pattern matching, many languages have added support for a type
called record.
Records are immutable aggregate types.
In layman terms, immutable means that they can't change after instantiation.
And aggregate means that they are types that can combine values of other types.

You can think of records as a shorthand for classes where all fields are
declared as final.

Here is a record in Dart.

```dart
(int, {String firstName, String lastName}) record = (1, firstName: "Joe", lastName: "Doe");
```

Where `(int, {String firstName, String lastName})` is the type and `(1, firstName: "Joe", lastName: "Doe")` is the value.

{{< hint info >}}
Notice the syntax for declaring record type is similar to how you declare
parameters for functions.
And the syntax for declaring a record value is similar to have you pass
arguments to a function.
{{< /hint >}}

You can give a name (or alias) to the type.

```dart
typedef Person = (int, {String firstName, String lastName});
```

It can save you some typing if you use the same record type several places.

```dart
Person person1 = (1, firstName: "Joe", lastName: "Doe");
Person person2 = (2, firstName: "Alice", lastName: "Smith");
```

You can also leave out the type declaration and let the compiler infer the
type from its value.

```run-dartpad:theme-dark:mode-dart:width-100%
var record = (1, firstName: "Joe", lastName: "Doe");

void main() {
  print(record.runtimeType);
}
```

You can destructure (extract nested values) from a record.

```run-dartpad:theme-dark:mode-dart:width-100%:height-210px
typedef Person = (int, {String firstName, String lastName});

void main() {
  final person = (1, firstName: "Joe", lastName: "Doe");
  final Person(:firstName, :lastName) = person;
  print("$firstName's last name is $lastName");
}
```

Where `final Person(:firstName, :lastName) = person` creates a variable named
`firstName` with the value of `person.firstName` and a variable named
`lastName` with the value of `person.lastName`.

Traditionally (without destructuring) it would be written like this:

```dart
final person = (1, firstName: "Joe", lastName: "Doe");
final firstName = person.firstName;
final lastName = person.lastName;
print("$firstName's last name is $lastName");
```

Imagine that a person had many more fields you wanted to extract.
Then using destructuring will save you a lot of typing.

## Pattern matching

The `is` keyword can be used to check if a value matches a certain type.

```run-dartpad:theme-dark:mode-dart:width-100%:height-230px
typedef Person = (int, {String firstName, String lastName});

void main() {
  dynamic joe = (1, firstName: "Joe", lastName: "Doe");
  if (joe is Person) {
    print("It's a person");
  }
}
```

More interesting, the `case` construct can be used to match on destructured
values.

```run-dartpad:theme-dark:mode-dart:width-100%:height-230px
typedef Person = (int, {String firstName, String lastName});

void main() {
  final person = (1, firstName: "Morticia", lastName: "Addams");
  if (person case Person(lastName: "Addams")) {
    print("You found a member of the Addams family");
  }
}
```

To learn about how patterns work in Dart, check out the links below.

- [Patterns #DecodingFlutter](https://www.youtube.com/watch?v=aLvlqD4QS7Y).
- [Records](https://dart.dev/language/records)
- [Patterns](https://dart.dev/language/patterns)

## Challenge

Write an algorithm to determine if someone is allowed to buy alcohol, using a
[switch expression](https://dart.dev/language/branches#switch-expressions) and
pattern matching.

Here are the rules:

- Beverages with 1.2 percent alcohol or more may not be sold to persons under the age of 16
- When selling beverages with 1.2 to 16.5 percent alcohol, the retailer must verify that the customer are 16 years of age
- Beverages with 16.5 percent alcohol or more may not be sold to persons under the age of 18

{{< exercise path="/content/docs/learning-dart/codelab/lib/patterns/" height="720px" >}}
