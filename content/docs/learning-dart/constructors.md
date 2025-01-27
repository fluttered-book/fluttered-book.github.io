---
title: Constructors
weight: 6
---

{{< classic-dartpad >}}

## Constructors in Dart

This section is aimed at teaching you the basics of OOP in Dart.

We will look at how to specify constructors, methods and inheritance.
You will also learn a bit about how Dart deals with nullability.

Let's jump right into it.

### Nullability

We can declare a class with positional parameters like this:

```dart
class Point {
  num? x;
  num? y;

  Point(num x, num y) {
    this.x = x;
    this.y = y;
  }
}
```

Notice the question mark after num?
It means the field is nullable.

If we remove the assignment `this.x = x` then after the class has been
instantiated, the value of `x` would be null.

Dart forces us to check for null each time we try to do something with the value
of a nullable variable.
This is called [sound null safety](https://dart.dev/null-safety), and it's there
to protect us from null reference exceptions.

The `Point` class doesn't accurately represent a point, unless it has a value
for both an _x_ and _y_.

Let's fix it by rewriting the class, such that the instance fields are no longer
nullable.

```dart
class Point {
  num x;
  num y;

  Point(num x, num y)
      : this.x = x,
        this.y = y;
}
```

Notice the curly brackets are gone. Instead, we have a `:` followed by a comma
separated list of assignments.
This is called an [initializer list](https://dart.dev/language/constructors#use-an-initializer-list).

If we want the variables to be non-nullable, we have to use an initialize list
instead of assigning the variables in a code block (within curly brackets).
That is because within a block, you have the ability to make conditional
assignments.

Here is a silly example of conditional assignment.

```dart
class Point {
  num? x;
  num? y;

  Point(num x, num y) {
    if (x > y) {
        this.x = x;
        this.y = y;
    }
  }
}
```

With an initializer list, you are always going to assign a value.
Therefore, in order to make the instance-variables non-nullable, we have to use
an initializer list for the assignments.

### Immutability

Immutability is just a fancy way to say that values can't change after
instantiation.
It can protect us from unexpected side effects in our apps.

![Simple class diagram](../images/simple-class-diagram.drawio.png)

_Both `B` and `C` reference `A`.
They both make changes to `A` each expecting they are the only part of the code that changes `A`.
This leads to bug that can be hard to track down._

If we don't want the values of _x_ and _y_ to change, we can declare them as
final.

```dart
class Point {
  final num x;
  final num y;

  Point(num x, num y)
      : this.x = x,
        this.y = y;
}
```

Assigning parameters directly to instance fields is so common that the Dart
designers made a nice shorthand for us.

```dart
class Point {
  final num x;
  final num y;

  const Point(this.x, this.y);
}
```

Notice I've also added the `const` keyword in-front of the constructor.
Which allows the compiler to do some optimizations.
I'm allowed to do that because all the instance variables are `final`.

An immutable class can be instantiated as a compile-time constant.
Thereby saving some CPU cycles at runtime.

```dart
const origin = Point(0, 0);
```

Here, `origin` is created when the code compiles, not when the application runs.
It simplifies how _x_ and _y_ are accessed, thereby making it more efficient.

If you want to make a constant instance, but you are not assigning directly to
a variable, then you can place a `const` keyword right in front of the
constructor.

```dart
final pointsOfInterest = {
  "origin": const Point(0, 0),
  "unit": const Point(1, 1)
};
pointsOfInterest["normal"] = const Point(0, 1);
```

You will see this way of using `const` a lot when you start making UI with
Flutter.

### Named parameters

Previously we used positional parameters.
It means that we have to pass values for parameters in the same order as they
are defined in the method signature.

Named parameters can be specified in any order.
They also make the meaning of the parameter more explicit.
This style is preferred when there is no logical order for the parameters.

Named parameters are wrapped in curly brackets.

```dart
class Line {
  Point? a;
  Point? b;
  Line({this.a, this.b});
}
```

In this example, we have a line from point _a_ to point _b_.
We use named parameters to signal the direction of the line (from a to b).
Notice that the instance variables are nullable again.
That is because named parameters are optional by default.
We can make them required with the `required` keyword.

```dart
class Line {
  Point a;
  Point b;
  Line({required this.a, required this.b});
}
```

## Methods

Defining methods are pretty straight forward.

```dart
class Line {
  Point a;
  Point b;
  Line({required this.a, required this.b});

  double calculateLength() {
    return math.sqrt(math.pow(b.x - a.x, 2) + math.pow(b.y - a.y, 2));
  }
}
```

Arrow syntax can be used for one-liners, which saves us from typing `return`.

```dart
class Line {
  Point a;
  Point b;
  Line({required this.a, required this.b});

  double calculateLength() => math.sqrt(math.pow(b.x - a.x, 2) + math.pow(b.y - a.y, 2));
}
```

### Modifiers

Maybe you have noticed that there are no _public_ or _private_ keywords
anywhere.
That is because everything in Dart is public by default.
To make something private you just prefix it with a `_` underscore.

```dart
class Nonsense {
    String _foo = "bar";
}
```

It is a common convention in other languages (like C#, TypeScript and Python)
to prefix private instance-variables with an underscore.
In Dart this convention is enforced by the compiler, so there is no need for a
private keyword.

The same is true for methods.
To make a method private you just prefix the name with an underscore.

```dart
class Nonsense {
  String _secretGreeting(String name) => "Pssst, hello " + name;
}
```

The keyword `static` behaves just as you would expect.

```dart
class Greeter {
  static String greeting(String name) => "Hello " + name;
}

Greeter.greeting("bob");
```

By the way, variables can be interpolated into strings.
So the above could also be written as:

```dart
class Greeter {
  static String greeting(String name) => "Hello $name!";
}
```

Here `$name` is substituted with the value of the variable `name`.

For comparison, this is what it looks like in some other languages:

{{% tabs %}}
{{% tab "C#" %}}

```csharp
$"Hello {name}!"
```

{{% /tab %}}
{{% tab "TypeScript" %}}

```typescript
`Hello ${name}!`;
```

{{% /tab %}}
{{% /tabs %}}

### Extension methods

Maybe you have heard of extension methods?
They can be used to extend an existing class from somewhere else.

```dart
extension PointExtensions on Point {
  Line to(Point other) {
    return Line(a: this, b: other);
  }
}

final Point origin = Point(0, 0);
final Line normal = origin.to(Point(0, 1));
```

You likely won't be writing that many extension methods yourself.
However, they are super useful for people writing libraries, as it allows them to
extend existing types.
You will be calling extension methods a lot.

## Inheritance

Like other object-oriented programming languages, Dart (of course) supports
inheritance.
You can declare a class that extends another.

```dart
class Shape {}

class Circle extends Shape {}
```

We can make it abstract by using the `abstract` modifier.

```dart
import 'dart:math' as math;

abstract class Shape {
  double area();
}

class Circle extends Shape {
  num radius;
  Circle(this.radius);

  @override
  area() {
    return math.pow(radius, 2) * math.pi;
  }
}
```

The subclass needs to implement the abstract method `area`, unless we make the
subclass abstract as well.

Notice that we don't need to specify a return type for `area` in the subclass.
That is because the compiler can tell from base class.

The `@override` isn't strictly required.
It is just an indicator to whoever reads the code that the methods override a
method in a base class.

You can use the above like this:

```dart
Circle(5).area()
```

The trailing parentheses are kinda ugly.
Writing it as a getter looks a bit nicer.

```dart
abstract class Shape {
  double get area;
}

class Circle extends Shape {
  num radius;
  Circle(this.radius);

  @override
  get area => math.pow(radius, 2) * math.pi;
}

// Invoke the getter
Circle(5).area
```

### Implementing interfaces

They way you make interfaces in Dart might seem very strange in the beginning,
but once you get used to it then it's actually pretty clever.

There is no interface types or keyword in Dart.
What you can do is to have a class implement the public interface of another
class without any of its behavior.

**In Dart, a class can be used as an interface!**

```run-dartpad:theme-dark:mode-dart:width-100%:height-500px
class Greeter {
  void greet(String name) {
    print("Hello $name");
  }
}

class PoliteGreeter implements Greeter {
  void greet(String name) {
    print("Good day to you, dear $name");
  }
}

void main() {
  Greeter greeter = Greeter();
  greeter.greet("Bob");

  greeter = PoliteGreeter();
  greeter.greet("Bob");
}
```

Here `PoliteGreeter` implements the interface of `Greeter`, meaning it will
need to implement the `greet()` method.
You use `extends` keyword for normal class inheritance.
You use `implements` to implement the interface of another class.

If you want an interface like you know from TypeScript, Java or C# in Dart, you
just make an abstract class.

Why doesn't Dart have a `interface` keyword like other <abbr title="Object
  Oriented Programming">OOP</abbr> languages?

#### Reason 1

Both
[C#](https://learn.microsoft.com/en-us/dotnet/csharp/language-reference/proposals/csharp-8.0/default-interface-methods)
and
[Java](https://docs.oracle.com/javase/tutorial/java/IandI/defaultmethods.html)
has support for defining interfaces with behavior.
They call it _default interface methods_.
Though pretty niche, there are some good use cases for it.
Although of the top of my head, I can't name any.

Anyway, _default interface methods_ has blurred the conceptual lines between
abstract classes and interfaces.

#### Reason 2

How many times have you written interfaces that only have a single concrete
implementation?
You have done that countless times, right?
You do it because potentially some time in the future you might need a
different implementation, and it will be a hassle refactoring everything
without an interface to depend on.

In Dart, you just write the concrete class.
If for any reason you need a different implementation in the future, you just
write another class implementing the interface of the first class.

```dart
class Person {
  final String firstName;
  final String lastName;
  Person(this.firstName, this.lastName);
}

// We for sure only need to be able to serialize a person as JSON.
class PersonSerializer {
  String serialize(Person person) {
    return """{
      "firstName": "${person.firstName}",
      "lastName": "${person.lastName}"
    }""";
  }
}

// Oh wait, we also need to be able to serialize as Comma-separated values (CSV).
class CsvPersonSerializer implements PersonSerializer {
  String serialize(Person person) {
    return """firstName, lastName
${person.firstName},${person.lastName}
""";
  }
}

void main() {
  final PersonSerializer serializer = CsvPersonSerializer();
  print(serializer.serialize(Person("Joe", "Doe")));
}
```

{{% hint danger %}}
Never implement serialization like this, as it is both fragile and insecure.
You will learn the correct way to work with JSON in Dart later on.
{{% /hint %}}

See, you can just swap between the two implementations, without having to write
an interface.

In C# you will need both an interface and two concrete implementations.

```csharp
public interface IPersonSerializer {
  public String serialize(Person person);
}

public class PersonSerializer : IPersonSerializer {
  public String serialize(Person person) {
    return "Pretend this returns JSON";
  }
}

public class CsvPersonSerializer : IPersonSerializer {
  public String serialize(Person person) {
    return "Pretend this returns CSV";
  }
}
```

## Combined

Here is an example of most if the stuff I've written about in this section put
together.

{{< codedemo path="/content/docs/learning-dart/codelab/lib/objects/" height="720px" >}}
