---
title: Working with JSON
weight: 1
---

{{< classic-dartpad >}}

# Working with JSON

## Manual serialization

### Decoding

In Dart we can deserialize JSON using
[jsonDecode](https://api.dart.dev/stable/3.3.0/dart-convert/jsonDecode.html)
function from the `dart:convert` library.

The function has a return type of `dynamic`, which means that Dart can't tell
what type it is before running the application.

It is important to know how types a treated when working with JSON.
Here are some examples you can play around with:

```run-dartpad:theme-dark:run-true:width-100%:height-610px
import 'dart:convert';

final json = '''{
    "id": 35,
    "categories": ["Programming","Geeky"],
    "joke": "There are only 10 kinds of people in this world: those who know binary and those who don't.",
    "flags": {
        "explicit": false
    }
}''';

void main() {
  final data1 = jsonDecode(json);
  print(data1.toString());
  print("\nRuntime type: ${data1.runtimeType}");
  print("Can I use it as a Map? ${data1 is Map}");

  print("Can I use it as a Map<String, dynamic>? ${data1 is Map<String, dynamic>}");
  print("Can I use it as a Map<String, Object>? ${data1 is Map<String, Object>}");
  print("\n");

  final categories = data1['categories'];
  print('The field "categories": $categories');
  print('Runtime type: ${categories.runtimeType}');
  print('Is it a List<dynamic>? ${categories is List<dynamic>}');
  print('Is it a List<String>? ${categories is List<String>}');
  print('Is first element a String? ${categories[0] is String}');
}
```

---

### Encoding

For serialization to JSON we can use [jsonEncode](https://api.dart.dev/stable/3.3.0/dart-convert/jsonEncode.html).

It works fine for the following types:

- num, int, double
- bool
- String
- List
- Map

```run-dartpad:theme-dark:run-true:width-100%:height-350px
import 'dart:convert';

void main() {
    final data = {
        "id": 35,
        "categories": ["Programming","Geeky"],
        "joke": "There are only 10 kinds of people in this world: those who know binary and those who don't.",
        "flags": {
            "explicit": false
        }
    };
    final json = jsonEncode(data);
    print(json);
}
```

Notice how similar Dart literals are to JSON.

You can make the JSON more readable to humans with
`JsonEncoder.withIndent('\t').convert`.

```run-dartpad:theme-dark:run-true:width-100%:height-350px
import 'dart:convert';

void main() {
    final data = { "id": 35, "categories": ["Programming","Geeky"], "joke": "There are only 10 kinds of people in this world: those who know binary and those who don't.", "flags": { "explicit": false } };
    final json = JsonEncoder.withIndent('\t').convert(data);
    print(json);
}
```

### Data transfer objects

What if we want to work with classes?
We don't get classes back when deserializing.
And we can **not** serialize classes directly.

Attempting to do so, gives us a nasty error.

```run-dartpad:theme-dark:run-true:width-100%:height-500px
import 'dart:convert';

class JokeDto {
  int? id;
  List<String>? categories;
  String? setup;
  String? delivery;

  JokeDto({this.id, this.categories, this.setup, this.delivery});
}

void main() {
  final joke = JokeDto(
    id: 1,
    categories: ["Programming"],
    setup: ".NET developers are picky when it comes to food.",
    delivery: "They only like chicken NuGet.",
  );
  jsonEncode(joke);
}
```

Instead, we need some methods to convert between `Map<String, dynamic>` and our
**DTO**.

It is common to put those conversion methods in the DTO class.

```run-dartpad:theme-dark:run-true:width-100%:height-800px
import 'dart:convert';

const json = '''{
    "id": 49,
    "categories": [
        "Programming"
    ],
    "setup": ".NET developers are picky when it comes to food.",
    "delivery": "They only like chicken NuGet."
}''';

class JokeDto {
  int? id;
  List<String>? categories;
  String? setup;
  String? delivery;

  JokeDto({this.id, this.categories, this.setup, this.delivery});

  JokeDto.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    categories = json['categories']?.cast<String>();
    setup = json['setup'];
    delivery = json['delivery'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['categories'] = this.categories;
    data['setup'] = this.setup;
    data['delivery'] = this.delivery;
    return data;
  }
}

void main() {
  final dto = JokeDto.fromJson(jsonDecode(json));
  print(dto);

  print(jsonEncode(dto.toJson()));
}
```

Wondering why the methods are called `fromJson` and `toJson` when they work with `Map` type?
It is just a convention that people in the Dart community use.

The convention implies that `fromJson` is compatible with `jsonDecode` and
`toJson` with `jsonEncode`.

# Code generation

That's a lot of code to write just to support JSON serialization for a class.
This is an area where Dart falls short a bit (in my opinion).
It's a well known problem within Dart/Flutter community, so several solutions
exist in the form of code generation.

Code generation is tooling that can generate code for you.
You define a simple class and have the tool generate all the boilerplate code
to support JSON generation for you.
Here is where the ecosystem gets a bit fragmented as several packages exist that solved the problem of JSON serialization.
However, they all use [build_runner](https://dart.dev/tools/build_runner) under
the hood to generate the code.

Here are some options:

- [json_serializable](https://pub.dev/packages/json_serializable)
- [built_value](https://pub.dev/packages/built_value)
- [freezed](https://pub.dev/packages/freezed)
- [dart_mappable](https://pub.dev/packages/dart_mappable)

The package `json_serializable` only gives you JSON serialization.
It is often used in combination with the
[equatable](https://pub.dev/packages/equatable) that you've seen previously.

The other options do the same as the `json_serializable` + `equatable` combo,
but also provides additional helper methods for working with immutable classes.

Tho not the most popular option, I think `dart_mappable` is perhaps the easiest
to grasp, so that is what we will go with.

{{% hint info %}}
Many examples online use a combination of `freezed` and `flutter_bloc`.
It might be more popular simply because it has existed for longer.
{{% /hint %}}

## dart_mappable

To use `dart_mappable` we need to add a couple of dependencies, as described in the package docs.

```sh
flutter pub add dart_mappable
flutter pub add build_runner --dev
flutter pub add dart_mappable_builder --dev
```

Say you have a file named `joke_dto.dart`.
Now, instead of this:

```dart
class JokeDto extends Equatable {
  String? setup;
  String? delivery;
  int? id;

  JokeDto({this.setup, this.delivery, this.id});

  JokeDto.fromJson(Map<String, dynamic> json) {
    setup = json["setup"];
    delivery = json["delivery"];
    id = json["id"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    _data["setup"] = setup;
    _data["delivery"] = delivery;
    _data["id"] = id;
    return _data;
  }

  JokeDto copyWith({
    String? setup,
    String? delivery,
    int? id,
  }) => JokeDto(
    setup: setup ?? this.setup,
    delivery: delivery ?? this.delivery,
    id: id ?? this.id,
  );

  @override
  List<Object> get props => [setup, delivery, id];
}
```

You can write this:

```dart
part 'joke_dto.mapper.dart';

@MappableClass()
class JokeDto with JokeDtoMappable {
  String? setup;
  String? delivery;
  int? id;

  JokeDto({this.setup, this.delivery, this.id });
}
```

The catch it that you need to run the following command each time you change the class:

```sh
dart pub run build_runner build
```

{{% hint warning %}}
If your mappable class is defined in a file called `your_class.dart` then you
need to put `part 'your_class.mapper.dart';` at the top of the file.
It won't work without it.
{{% /hint %}}
