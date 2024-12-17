---
title: The basics
weight: 1
---

# The basics

{{< classic-dartpad >}}

Dart is in many ways very similar to programming languages you already know.

In this chapter I'll draw comparisons to C#, Java, JavaScript and TypeScript where relevant.
If you are familiar with any of those languages you can map your existing knowledge over to Dart.

## Types

Here is a list of the basic type in Dart.

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

Example: valid values for the type `num?` are `1`, `1.23`, `-1234` and `null`.

## Variables

Variables can be defined as shown below.
Notice that the is `<type> <name> = <value>`.
This is similar to Java and C#.

```dart
String name = 'Joe Doe';
```

In the rare cases where you need to be able to assign values of different types
to a variable, you can declare the type as `Object` or `dynamic`.

```dart
Object name = 'Joe Doe';
name = 1;
```

```dart
dynamic name = 'Joe Doe';
name = 1;
```

### var

When using `var` instead of declaring a type, the compiler will infer the type.
Meaning it will have the same type as the value right-hand side of the
equal-sign.

```dart
var name = 'Joe Doe';
```

Here, the `name` variable is a type `String` because that is what is being assigned to it.

This is similar to how `var` works in C#.

### final

Variables that aren't supposed to be reassigned should be prefixed it with the
`final` keyword.

```dart
final String name = 'Joe Doe';
```

Or with the type being inferred:

```dart
final name = 'Joe Doe';
```

`final` in Dart is similar to `const` in JavaScript/TypeScript, to `final` in
Java and to some extent `readonly` in C#.

Using `final` allows the compiler to do some optimizations, so it should be
preferred whenever possible.

### const

It works a bit differently from `final`.
When a variable is `const` it means that the values is computed during
compilation.
It can not be changed when the application is running.

```
const version = '1.0';
```

This is similar to `const` in C#.

**Note:** `const` in Dart is not the same as `const` in JavaScript/TypeScript.
See [final](#final).

You can read more about variables in the [official docs](https://dart.dev/language/variables).

### var, final or const?

As a general rule, you should pick the most restrictive declaration for any
variable, in the order:

- `const`
- `final`
- `var`

Don't jump through hoops in order to force a variable declaration to be more
strict than it has to.
You should quickly pick up on which to use in what situation.

## Functions

In Dart you can define functions without a class (similar to JavaScript/TypeScript).

```dart
num add(num a, num b) {
    return a + b;
}
```

Notice, that the type is written before the variable/function name like in Java
and C#.

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

You are not required to specify types in Dart.
If you don't specify a type then the compiler will infer one from the context.
If the compiler can't infer a more specific type then it will be treated as
`dynamic`, meaning any value can be assigned to it and the compiler won't check
how it is being used.

It might be tempting to just always leave out the types as it requires
less typing.
Doing so is fine whenever a declaration includes an assignment.
That is because in such cases the compiler can determine the specific type from
the value assigned to it.
If you don't have an assignment (`=` sign) in the same line as the declaration
you will regret leaving out the type.
That because then the type will be treated as `dynamic`, meaning the compiler
won't check any invocations/operations on the value.
Which leads to errors at runtime that the compiler could have caught for you.

To better illustrate, here are some examples.

<span style="color: red;">Bad</span>

```
var name;
name = "Joe Doe";
```

<span style="color: green;">Good</span>

```
var name = "Joe Doe";
```

<span style="color: red;">Bad</span>

```run-dartpad:theme-dark:mode-dart:width-100%:height-200px
divide(a, b) {
    return a / b;
}

main(){
  divide(1, "foobar");
}
```

_Will give you a runtime error when you run the code because you can't divide a
number by a string._

<span style="color: green;">Good</span>

The same (almost) code again.
But this time it is explicitly stated that the `divide` function works with type `num`.

```run-dartpad:theme-dark:mode-dart:width-100%:height-200px
num divide(num a, num b) {
    return a / b;
}

void main(){
  divide(1, "foobar");
}
```

_The compiler will now tell us that we have an error, allowing us to catch
mistakes as we are writing the code._

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

### switch statement

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

More details can be found in the [official
docs](https://dart.dev/language/branches#switch-statements).

### switch expression

Dart also supports something called **switch expressions**.
The block in a switch-expression returns a value that can be assigned to a
variable.

> Expressions evaluate to a value that can either be assigned to a value or returned.
> Statements do not evaluate to a value.

Anyway, here is an example of a switch-expression.

```dart
String message = switch (answer) {
  true => "Correct",
  false => "Wrong",
  _ => "No valid answer was given",
};
print(message)
```

Note that `_` indicates we don't care about the value.
Effectively `_ => ...` serves as the default case.

#### switch mini-exercise

See if you can solve the following small exercise with either a
switch-statement or expression.

Imagine you have an API that returns day of week as a `int`.
The numeric values follow
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
