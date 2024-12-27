---
title: Patterns
weight: 7
---

{{< classic-dartpad >}}

# Patterns

_Patterns, not to be confused with design patterns._

Many modern object-oriented programming languages (including Dart) are
increasingly adopting features previously associated with paradigm of
functional programming.

You likely already know about lambda expressions (aka anonymous functions).

Another functional programming concept that have found its way into many OOP
languages are pattern matching.
Functionality and syntax can vary a bit, but the overall idea is the same.
A variation of pattern matching can be found in [C#](https://learn.microsoft.com/en-us/dotnet/csharp/fundamentals/functional/pattern-matching) and
[Java](https://docs.oracle.com/en/java/javase/21/language/pattern-matching.html).
There is also a [proposal for ECMAScript
(JavaScript)](https://tc39.es/proposal-pattern-matching/).

In short, pattern matching can be used to destructure objects and in many ways
provide an elegant alternative to express conditions compared to boolean logic.

It gives compact syntax to express conditionals based on the "shape" of a value
and extract values from objects.

To support pattern matching, many languages have added support for a type
called record.
Records are immutable, aggregate types.
In layman terms it means that, they can't change and are types that can combine
values of other types.

If you are familiar with patterns already, it should be easy enough to convert
your knowledge to Dart.

To learn about how patterns work in Dart, check out the links below.

- [Patterns #DecodingFlutter](https://www.youtube.com/watch?v=aLvlqD4QS7Y).
- [Records](https://dart.dev/language/records)
- [Patterns](https://dart.dev/language/patterns)

## Challenge

Rewrite the algorithm to determine if someone is allowed to buy alcohol, to a
[switch expression](https://dart.dev/language/branches#switch-expressions).

Here are the rules:

- Beverages with 1.2 percent alcohol or more may not be sold to persons under the age of 16
- When selling beverages with 1.2 to 16.5 percent alcohol, the retailer must verify that the customer are 16 years of age
- Beverages with 16.5 percent alcohol or more may not be sold to persons under the age of 18

{{< codedemo path="/content/docs/learning-dart/codelab/lib/patterns/" height="720px" >}}
