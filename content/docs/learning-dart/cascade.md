---
title: Cascade notation
weight: 10
---

# Cascade Notation

Here is a neat bit of syntax in Dart that can save some typing.
If you access a field or method on an object with `..` instead of `.` then it
will return the object instead of the value from the field/method.
The `..` is known as cascade notation, and it allows you to chain multiple operations on the same object.

It is best illustrated with an example.
Say you have a counter class, and you want to create an instance, increment the
value 3 times then print the result.

{{% tabs %}}

{{% tab "Dart" %}}

```dart
class Counter {
  var _value = 0;
  get count => _value;

  int increment() => _value++;
}

main() {
  var counter = Counter();
  counter.increment();
  counter.increment();
  counter.increment();
  print(counter.count);
}
```

{{% /tab %}}

{{% tab "JavaScript" %}}

```javascript
class Counter {
  #value = 0;
  get count() {
    return this.#value;
  }
  increment() {
    this.#value++;
  }
}

var counter = new Counter();
counter.increment();
counter.increment();
counter.increment();
console.log(counter.count);
```

{{% /tab %}}

{{% tab "TypeScript" %}}

```typescript
class Counter {
  private _value: number = 0;
  get count(): number {
    return this._value;
  }
  increment(): void {
    this._value++;
  }
}

var counter = new Counter();
counter.increment();
counter.increment();
counter.increment();
console.log(counter.count);
```

{{% /tab %}}

{{% tab "C#" %}}

```cs
public class Counter {
  public int Count { get; private set; } = 0;
  public void Increment() {
    Count++;
  }
}

var counter = new Counter();
counter.Increment();
counter.Increment();
counter.Increment();

Console.WriteLine(counter.Count);
```

{{% /tab %}}

{{% tab "Java" %}}

```java
public class Test {
  public static class Counter {
    private int _count = 0;
    public int getCount() {
      return _count;
    }
    public void increment() {
      _count++;
    }
  }

  public static void main(String[] args) {
    var counter = new Counter();
    counter.increment();
    counter.increment();
    counter.increment();

    System.out.println(counter.getCount());
  }
}
```

{{% /tab %}}

{{% /tabs %}}

For the increment and print part, you would probably do this (or write a loop):

```dart
var counter = Counter();
counter.increment();
counter.increment();
counter.increment();
print(counter.value);
```

Using cascade notation, you don't have to keep repeating `counter`.
You can just write it like:

```dart
print(
  Counter()
    ..increment()
    ..increment()
    ..increment()
);
```

The `..` can also be used to set values for fields.

{{% tabs %}}

{{% tab "Dart" %}}

```dart
class Contact {
    String? name;
    String? email;
    String? phone;
}

var contact = Contact()
    ..name = "Joe Doe"
    ..email = "joe@example.com"
    ..phone = "12345678";
```

{{% /tab %}}

{{% tab "C#" %}}

```csharp
public class Contact {
    public string Name { get; set; }
    public string Email { get; set; }
    public string Phone { get; set; }
}

var contact = new Contact() {
    Name = "Joe Doe",
    Email = "joe@example.com",
    Phone = "12345678",
};
```

{{% hint "warning" %}}
Property initialization in C# can only be used when instantiating the class.
If you want to update the fields on an existing instance then you would have to
do something like the TypeScript example.
{{% /hint %}}

{{% /tab %}}

{{% tab "TypeScript" %}}

```typescript
class Contact {
  public name?: string;
  public email?: string;
  public phone?: string;
}

var contact = new Contact();
contact.name = "Joe Doe";
contact.email = "joe@example.com";
contact.phone = "12345678";
```

{{% /tab %}}

{{% /tabs %}}

However, making all fields final and using named parameters should be preferred
when possible.

{{% tabs %}}
{{% tab "Dart" %}}

```dart
class Contact {
    final String name;
    final String email;
    final String phone;

    Contact({
        required this.name,
        required this.email,
        required this.phone,
    });
}

var contact = Contact(
    name: "Joe Doe",
    email: "joe@example.com",
    phone: "12345678",
);
```

{{% /tab %}}
{{% /tabs %}}

[Official documentation](https://dart.dev/language/operators#cascade-notation)
