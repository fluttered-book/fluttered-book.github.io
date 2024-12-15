---
title: The basics
weight: 1
---

# The basics

{{< classic-dartpad >}}

Dart is in many ways very similar to programming languages you already know.

## Types

Here is a list of the basic type in Dart

- **String**
- **bool**
- **List**
- **Set** like `HashSet` in C#
- **Map** like `Dictionary` in C#
- **int**
- **double**
- **num** can be either `int` or `double`. So, it is like `Number` in JavaScript/TypeScript
- **dynamic** which is like `dynamic` in C# or `any` in TypeScript

You can add `?` after a type to make it nullable, similar to TypeScript.
Example: valid values for variable of type `int?` are `1`, `-1234` and `null`.

## Functions

In Dart you can define functions outside a class, similar to TypeScript.

```dart
num add(num a, num b) {
    return a + b;
}
```

Notice, that the type comes before the variable/function name like Java and C#.

### Main function

The entry point for a program in Dart is the `main` function.

```run-dartpad:theme-dark:mode-dart:width-100%:height-200px
void main() {
    print("This prints");
}

void anotherFunction() {
    print("This doesn't, since it isn't being called");
}
```

<small>Hint click the "Run" button on the code snippets to execute the code.</small>

### Dynamic types

You required to specify types in Dart.
If you don't and the compiler can't work out a specific type, then the type is
inferred to be `dynamic`, meaning any value can be assigned to it.

It might seem tempting to leave out the types because it requires less typing.
However, it is a bad idea since you will end up with errors at runtime that the
compiler could otherwise have caught for you.

To better illustrate, here are some examples.

The following code will give you an error when you run the code because you
can't divide a number by a string.

```run-dartpad:theme-dark:mode-dart:width-100%:height-200px
divide(a, b) {
    return a / b;
}

main(){
  divide(1, "foobar");
}
```

The same (almost) code again.
But this time it is explicitly stated that the `divide` function works with type `num`.
The compiler will now tell us that we have an error, allowing us to catch
mistakes as we are writing the code.

```run-dartpad:theme-dark:mode-dart:width-100%:height-200px
num divide(num a, num b) {
    return a / b;
}

void main(){
  divide(1, "foobar");
}
```

I advise you to always explicitly define types for parameters and return
values.

## Control flow

### Loops & if-else

They work exactly as you would expect.

**For-each** loops are similar to JavaScript.

```dart
var numbers = [1, 2, 3, 4];
for (var i in numbers) {
    print(i);
}
```

### Switch

**switch** can be used in similar ways as in C# or TypeScript.
But with the exception that each-empty `case` clause jumps to the end of the
`switch` statement.
Meaning there is no need for `break` statement in `case`-clauses.
You could say that it auto-breaks.

```run-dartpad:theme-dark:mode-dart:width-100%:height-300px
void main(){
  bool? answer = null;
  switch (answer) {
      case true:
          print("Correct");
      case false:
          print("Wrong");
      default:
          print("No valid answer was given");
  }
}
```

_Try different values for the `answer` variable to see how it works in
practice._

Dart also supports something called **switch expressions**.

```dart
String message = switch (answer) {
  true => "Correct",
  false => "Wrong",
  _ => "No valid answer was given",
};
print(message)
```

Note that `_` functions as a default.

> Expressions evaluate to a value that can either be assigned to a value or returned.
> Statements do not evaluate to a value.

Solve the following exercises with either a switch-statement.

Imagine you have an API that returns day of week as an `int`.
The numeric values follows
[DayOfWeek](https://docs.oracle.com/javase/8/docs/api/java/time/DayOfWeek.html)
definition in Java.
Write a simple function that takes a day of the week as input and returns
whether it's a weekday or a weekend.
On invalid input it should `throw ArgumentError('Invalid day')`.

```run-dartpad:theme-dark:mode-dart:width-100%
{{ include exercise path="codelab/lib/switch_statement/" }}
```

Solve this one with a switch-expression.

Write a simple function that converts Denmark's 7-step-scale to ECTS grading scale.
See [Academic grading in Denmark](https://en.wikipedia.org/wiki/Academic_grading_in_Denmark).

```run-dartpad:theme-dark:mode-dart:width-100%
{% include exercise path="codelab/lib/switch_expression/" %}
```

## Variables

The official documentation explains it better than I can.

**[Dart - Variables](https://dart.dev/language/variables)**

**Note** `const` in TypeScript are the same as `final` in Dart.
In Dart you can only declare a variable as `const` when the value can be
determined during compilation and will never change at runtime.

## Error handling

In Dart you can throw any arbitrary object (just like TypeScript).

```dart
throw "Party!!!";
```

However you pretty much always want to throw types that implement
[Error](https://api.dart.dev/stable/3.2.6/dart-core/Error-class.html) or
[Exception](https://api.dart.dev/stable/3.2.6/dart-core/Exception-class.html).

Try-catch can look very similar to TypeScript:

```dart
void coolFunction() => throw new UnimplementedError();

void main() {
  try {
      coolFunction();
  } catch (error) {
      print("Oh no, oh no, oh no no no");
  }
}
```

As indicated, having `new` before invoking a constructor is not necessary.

```dart
void coolFunction() => throw UnimplementedError();
```

If you want to catch some specific type, you can do:

```dart
void coolFunction() => throw UnimplementedError();

void main() {
    try {
        coolFunction();
    } on UnimplementedError {
        print("Bro need to implement that function!");
    }
}
```

In case you want to do something with the catch object.

```dart
class ValidationError extends ArgumentError {
    ValidationError(super.message);
}

void validateAge(int age) {
    if (age < 0) {
        throw ValidationError("Age can be less than 0");
    }
}

void main() {
    try {
        validateAge(-1);
    } on ArgumentError catch (e) {
        print(e.message);
    }
}
```
