---
title: Building object trees
weight: 7
---

# Building object trees

Constructing object trees is very important in Flutter (framework).

Dart (language) has a couple of tricks you can use to write constructors for
classes, so that they are both clear and concise.

## Constructors

**Constructor in C#**

This is how you are used to writing constructors in C#.

```csharp
class Task
{
    string name;
    bool done;
    Task(string name, bool done)
    {
        this.name = name;
        this.done = done;
    }
}
```

**Constructor in Dart**

In Dart we need to assign fields/instance-variables a bit different.

```dart
class Task {
  String name;
  bool done;
  Task(String name, bool done):
    this.name = name,
    this.done = done;
}
```

Notice that colon is used followed by a list of assignments.

**Shorthand parameters**

Because assigning parameters to fields/instance-variables is so common, there is
a shorthand for it.

```dart
class Task {
  String name;
  bool done;
  Task(this.name, this.done);
}

Task("Learn Dart", false);
```

**Optional parameters**

We can make a parameter optional wrapping it in `[]` and making the field nullable.

```dart
class Task {
  String name;
  bool? done;
  Task(this.name, [this.done]);
}

Task("Learn Dart"); // `done` is null
Task("Learn Dart", false);
```

**Optional with default value**

Instead of having the field nullable, you could specify a default value.

```dart
class Task {
  String name;
  bool done;
  Task(this.name, [this.done = false]);
}

Task("Learn Dart"); // `done` is true
Task("Learn Dart", true);
```

**Named parameter**

With positional parameters, it is not always obvious from looking at the
invocation what the purpose of the parameter is.

Named parameters can be used to make the purpose of a parameter more explicit.

```dart
class Task {
  String name;
  bool? done;
  Task(this.name, {this.done});
}

Task("Learn Dart", done: true);
```

**Named with default value**

```dart
class Task {
  String name;
  bool? done;
  Task(this.name, {this.done = false});
}

Task("Learn Dart"); // `done` is false
```

**Required named parameter**

It can also be useful to require that a named parameter be specified.

```dart
class Task {
  String name;
  bool done;
  Task(this.name, {required this.done});
}
```
