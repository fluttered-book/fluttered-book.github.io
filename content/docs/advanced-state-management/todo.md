---
title: To-do app
description: >-
  A simple to-do app demonstrating the use of Cubit
weight: 3
---

# To-do app

<iframe src="https://fluttered-book.github.io/todo/" width="375" height="667px"></iframe>

## Create project

```sh
flutter create todo
cd todo
flutter pub add flutter_bloc dev:bloc_test
```

This project will work on all platforms supported by Flutter.
But you are free to only create it for the platforms you actually care about.

We've also added a couple of dependencies that will be needed later.

## Prototype layout

The app is going to display a list of items that can be checked off when done.
We also need a button to add new items and add a swipe gesture to remove.

Before jumping into code, it can be a good idea to start with a mockup of what
the app should look like.
Here's a quick mockup made with [draw.io](https://draw.io).

![Mockup of ToDo app](../images/todo-mockup.drawio.png)

Now that we know roughly what we are aiming for, let's turn it into code.

Open `lib/main.dart` and replace the content.

```dart
import 'package:flutter/material.dart';

void main() {
  runApp(const TodoApp());
}

final todos = [
  "Prepare for class",
  "Pretend to be awake during lecture",
  "Work extra shift so I can pay rent",
  "Do homework instead of playing video games",
];

class TodoApp extends StatelessWidget {
  const TodoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text("ToDo")),
        body: ListView.separated(
          itemBuilder: (context, index) => Dismissible(
            key: Key('$index'),
            background: Container(color: Colors.redAccent),
            child: ListTile(
              title: Text(todos[index]),
              trailing: Checkbox(value: false, onChanged: (value) {}),
            ),
            onDismissed: (_) {
              todos.removeAt(index);
            },
          ),
          separatorBuilder: (context, index) => const Divider(),
          itemCount: todos.length,
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {},
          child: Icon(Icons.add),
        ),
      ),
    );
  }
}
```

{{% hint info %}}
It doesn't exactly match our mockup, and it doesn't need to.
{{% /hint %}}

`ListView.separated()` just places a small line to indicate the separation of
items.

[Dismissible](https://api.flutter.dev/flutter/widgets/Dismissible-class.html) allows you to trigger an action when dragging/flinging it to the side.
You can check out the docs if you want to learn more.

## Data model

Now that we have a dumb-skeleton of our app, we need to make it do stuff when
interacting with it.

Before implementing the "logic" of our app, we should probably define some data
models.

To make our life a bit easier we'll add a couple of additional dependencies.

```sh
flutter pub add equatable
flutter pub add uuid
```

| Package   | Description                                                                     |
| --------- | ------------------------------------------------------------------------------- |
| equatable | Helps make data-classes that support equality comparison, hashCode and toString |
| uuid      | Generate UUID/GUIDs that we can use as ID                                       |

### Equatable

When writing tests it is going to be super useful if we can compare to
instances of our model with `==` operator.

The default behavior you get in Dart, is that two object are equal if they are
the same instance.
It can, however, be changed by overriding the [operator
==](https://api.dart.dev/stable/3.3.1/dart-core/Object/operator_equals.html).
When overriding it, one should also override the `hashCode` method.
It can be super annoying to do manually.
So, we will use the [equatable](https://pub.dev/packages/equatable) package to
help us.
Equatable also implements `toString` which can be handy when debugging.

### Writing models

`lib/data/model.dart`

```dart
import 'package:equatable/equatable.dart';

class Todo extends Equatable {
  final String id;
  final String title;
  final String description;
  final bool done;

  const Todo({
    required this.id,
    required this.title,
    required this.description,
    required this.done,
  });

  const Todo.create({
    required this.id,
    this.title = '',
    this.description = '',
    this.done = false,
  });

  Todo copyWith({
    String? title,
    String? description,
    bool? done,
  }) {
    return Todo(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      done: done ?? this.done,
    );
  }

  Todo toggleDone() => copyWith(done: !done);

  @override
  List<Object?> get props => [id, title, description, done];
}
```

The `props` property is required by `Equatable` base class.
And that is what gives us an implementation of `==` (equality comparison),
`hashCode` and `toString()`.

Our model class is immutable, so we added a couple of helper methods to make it
easier to make new instances.

`Todo.create()` is a factory method for creating a new instance.
Only required parameter is `id` (which is what we are going to use the uuid
package for), the rest can have "empty" defaults.

The `copyWith()` method allows us to create a clone where some fields have a
different value.

## Managing state with a Cubit

Now for the fun part, where we implement the actual logic of the app.
The app is pretty simple, so our logic will also be.

### State

When using the BLoC pattern, our UI is the result of a stream of changing
state.

We therefore need an object to represent the state of our application.

Add `lib/core/todo_state.dart` with:

```dart
import 'package:equatable/equatable.dart';
import 'package:todo/data/model.dart';

enum TodoStatus {
  loading,
  saving,
  ready,
}

class TodoState extends Equatable {
  final TodoStatus status;
  final List<Todo> todos;

  const TodoState({required this.status, required this.todos});

  const TodoState.create({
    this.status = TodoStatus.ready,
    this.todos = const [],
  });

  TodoState copyWith({TodoStatus? status, List<Todo>? todos}) {
    return TodoState(
      status: status ?? this.status,
      todos: todos ?? this.todos,
    );
  }

  @override
  List<Object?> get props => [status, todos];
}
```

The `TodoStatus` enum doesn't have much purpose at the moments.
As the app you will build in this guide simply stores the items in memory.
However, a real app would persist it somewhere, either locally on the device or
on some server.
In both cases there will be a delay while it saves or loads the data.
The enum is simply, so we can account for this in the UI and give the user some
sort of feedback.

### Cubit

Our to-do app needs <abbr title="Create, read, update and delete">CRUD</abbr>
like functionality.

We don't have to do anything about _read_ here since that is just our UI
responding to new states.

The `create`, `update` and `delete` are implemented in the cubit.

Add `lib/core/todo_cubit.dart` with:

```dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo/core/todo_state.dart';
import 'package:uuid/uuid.dart';

import '../data/model.dart';

class TodoCubit extends Cubit<TodoState> {
  TodoCubit() : super(TodoState.create());

  Todo create({String? id}) {
    final todo = Todo.create(id: id ?? Uuid().v4());
    final newState = state.copyWith(todos: [todo, ...state.todos]);
    emit(newState);
    return todo;
  }

  void update(Todo todo) {
    final index = state.todos.indexWhere((x) => x.id == todo.id);
    final newState = state.copyWith(
      todos: [
        ...state.todos.take(index),
        todo,
        ...state.todos.skip(index + 1),
      ]
    );
    emit(newState);
  }

  void delete(String id) {
    final index = state.todos.indexWhere((x) => x.id == id);
    final newState = state.copyWith(
      todos: [
        ...state.todos.take(index),
        ...state.todos.skip(index + 1),
      ]
    );
    emit(newState);
  }

  void toggle(String id) {
    final todo = state.todos.singleWhere((x) => x.id == id);
    update(todo.toggleDone());
  }
}
```

### Tests

Off by one error are very common when working with indexes.
Better add some tests!

```sh
flutter pub add bloc_test
```

Create `test/core/todo_cubit_test.dart`, with:

```dart
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:todo/core/todo_cubit.dart';
import 'package:todo/core/todo_state.dart';
import 'package:todo/data/model.dart';

void main() {
  group("TodoCubit", () {
    blocTest(
      'create() add a new todo',
      build: () => TodoCubit(),
      act: (cubit) => cubit.create(id: "id"),
      expect: () => [
        TodoState(
          status: TodoStatus.ready,
          todos: [Todo.create(id: "id")],
        )
      ],
    );

    blocTest(
      'update() replaces existing todo',
      build: () => TodoCubit(),
      seed: () => TodoState.create(todos: [
        Todo.create(id: "1", title: "first"),
        Todo.create(id: "2", title: "second"),
        Todo.create(id: "3", title: "third"),
      ]),
      act: (cubit) =>
          cubit.update(Todo.create(id: '2', title: "updated second")),
      expect: () => [
        TodoState.create(todos: [
          Todo.create(id: "1", title: "first"),
          Todo.create(id: "2", title: "updated second"),
          Todo.create(id: "3", title: "third"),
        ])
      ],
    );

    blocTest(
      "delete() removes a todo",
      build: () => TodoCubit(),
      seed: () => TodoState.create(todos: [
        Todo.create(id: "1"),
        Todo.create(id: "2"),
      ]),
      act: (cubit) => cubit.delete("2"),
      expect: () => [
        TodoState.create(todos: [Todo.create(id: "1")])
      ],
    );
  });
}
```

The [bloc_test](https://pub.dev/packages/bloc_test) package gives us some nice
helpers for writing tests for BLoC/Cubit.

We can define a test case with a call to `blocTest()`.

| Parameter | Description                                        |
| --------- | -------------------------------------------------- |
| `build`   | Construct an instance of BLoC/Cubt we want to test |
| `seed`    | Our initial state                                  |
| `act`     | The interaction we want to test                    |
| `expect`  | What state changes we expect as a result           |

Delete the default test that is included in a new project by removing
`test/widget_test.dart`.

Try it out by running:

```sh
flutter test
```

## Make functional UI

Okay, so we got a UI and some logic.
Let's tie it all together!

### Providing TodoCubit

Replace `main.dart`.

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/todo_cubit.dart';
import 'ui/todo_list_page.dart';

void main() {
  runApp(const TodoApp());
}

class TodoApp extends StatelessWidget {
  const TodoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => TodoCubit(),
      child: MaterialApp(home: TodoListPage()),
    );
  }
}
```

_TodoListPage will be added in a moment._

Remember: Widgets can use the [BuildContext](https://www.youtube.com/watch?v=rIaaH87z1-g)
to reach up the tree.
The `BlocProvider` allows its children to get hold of a Cubit/BLoC by reaching
up the element tree.

### React to state changes

By having a `BlocProvider` for `TodoCubit` at the root, it allows all other
widgets to access the `TodoCubit`.
Referencing `TodoCubit` can be done in one of several ways.

Using `final cubit = context.read<TodoCubit>()` or `final cubit = context.watch<TodoCubit>()`.
The difference is that `context.watch()` will trigger a rebuild when a new
state is emitted.
And `context.read()` will not.

We can also use a `BlocBuilder` to rebuild widgets when a new state is emitted.
Note: it will only rebuild its children provided by the `builder` parameter.

Add `lib/ui/todo_list_page.dart` with:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../core/todo_cubit.dart';
import '../core/todo_state.dart';

class TodoListPage extends StatelessWidget {
  const TodoListPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("ToDo")),

      body: BlocBuilder<TodoCubit, TodoState>(
        builder: (context, state) {
          return ListView.separated(
            itemBuilder: (context, index) {
              final todo = state.todos[index];
              return Dismissible(
                key: Key(todo.id),
                background: Container(color: Colors.redAccent),
                child: ListTile(
                  title: Text(todo.title),
                  subtitle: Text(todo.description),
                  trailing: Checkbox(
                    value: todo.done,
                    onChanged: (_) => context.read<TodoCubit>().toggle(todo.id),
                  ),
                ),
                onDismissed: (_) => context.read<TodoCubit>().delete(todo.id),
              );
            },
            separatorBuilder: (context, index) => const Divider(),
            itemCount: state.todos.length,
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.read<TodoCubit>().create();
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
```

### Update dialog

The `FloatingActionButton` above allows us to add new todo items.
But they are all empty!

What We need is a form so we can provide it some values.

We can use a combination of
[Form](https://api.flutter.dev/flutter/widgets/Form-class.html) and
[TextFormField](https://api.flutter.dev/flutter/material/TextFormField-class.html)
widgets to build a form with validation.

A `Form` widget allows validation across all the fields of its children.
But we need a key attached to the form, so we can refer to it when the "submit"
button is pressed/tapped.
You should use a
[GlobalKey](https://api.flutter.dev/flutter/widgets/GlobalKey-class.html) for
this.
`GlobalKey` is just a key that is unique throughout your entire app.

`lib/ui/update_todo_dialog.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../core/todo_cubit.dart';
import '../data/model.dart';

class UpdateTodoDialog extends StatefulWidget {
  final Todo todo;

  const UpdateTodoDialog({super.key, required this.todo});

  @override
  State<UpdateTodoDialog> createState() => _UpdateTodoDialogState();
}

class _UpdateTodoDialogState extends State<UpdateTodoDialog> {
  final _formKey = GlobalKey<FormState>();
  String? _title;
  String? _description;

  @override
  Widget build(BuildContext context) {
    return Dialog.fullscreen(
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            TextFormField(
              decoration: InputDecoration(labelText: 'Title'),
              validator: (value) =>
                  value?.isEmpty ?? true ? 'Please give it a title' : null,
              initialValue: widget.todo.title,
              onChanged: (value) => _title = value,
            ),
            TextFormField(
              decoration: InputDecoration(labelText: 'Description'),
              initialValue: widget.todo.description,
              onChanged: (value) => _description = value,
            ),
            FilledButton(
              onPressed: () {
                if (!_formKey.currentState!.validate()) return;
                final update = widget.todo.copyWith(
                  title: _title,
                  description: _description,
                );
                context.read<TodoCubit>().update(update);
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            )
          ],
        ),
      ),
    );
  }
}
```

Each `TextFormField` gets a `validator` function which can validate that one
field.
We can then use `_formKey.currentState!.validate()` to validate across the
entire form.

You can read more about forms and validation
[here](https://docs.flutter.dev/cookbook/forms/validation).

To open the dialog we need to change the floatingActionButton to:

```
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) =>
                UpdateTodoDialog(todo: context.read<TodoCubit>().create()),
          );
        },
        child: Icon(Icons.add),
      ),
```

## Optimize rebuilds

We can optimize the UI slightly by controlling when the list needs to be rebuilt.

In `lib/ui/todo_list_page.dart`, add following as parameter to `BlocBuilder`
just above the `build: (context) =>...` part:

```dart
buildWhen: (previous, current) => previous.todos != current.todos,
```

That will rebuild the list only when todo items changes, regardless of whether
other parts of `TodoState` changes.

## Show saving message

### Fake delay

We don't have time to build an API for the app, so we will pretend we have one.
We are going to fake some delay while network requests to complete.
Just so I can show you how to deal with it in the UI.

This is where `TodoStatus` comes in.

Replace `update()` and `delete()` in `TodoCubit`.

```dart
  void update(Todo todo) {
    final index = state.todos.indexWhere((x) => x.id == todo.id);
    final newState = state.copyWith(
      todos: [
        ...state.todos.take(index),
        todo,
        ...state.todos.skip(index + 1),
      ],
      status: TodoStatus.saving,
    );
    emit(newState);
    Future.delayed(Duration(seconds: 1))
        .then((_) => emit(state.copyWith(status: TodoStatus.ready)));
  }

  void delete(String id) {
    final index = state.todos.indexWhere((x) => x.id == id);
    final newState = state.copyWith(
      todos: [
        ...state.todos.take(index),
        ...state.todos.skip(index + 1),
      ],
      status: TodoStatus.saving,
    );
    emit(newState);
    Future.delayed(Duration(seconds: 1))
        .then((_) => emit(state.copyWith(status: TodoStatus.ready)));
  }
```

Whenever a change happen we emit a state where **status** is "saving" then
after a short delay (`Future.delay`) we emit a new state where **status** is
"ready" again.

### Show feedback

In `TodoListPage`, change `BlocBuilder` to `BlocConsumer`.
Add following above `buildWhen`:

```dart
listenWhen: (previous, current) =>
    previous.status == TodoStatus.ready &&
    current.status != TodoStatus.ready,
listener: (context, state) {
  final message = switch (state.status) {
    TodoStatus.saving => "Saving...",
    TodoStatus.loading => "Loading...",
    _ => null
  };
  if (message == null) return;
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(message)),
  );
},
```

From the [docs](https://pub.dev/documentation/flutter_bloc/latest/flutter_bloc/BlocListener-class.html) for `listener`:

_... should be used for functionality that needs to occur only in response to a
state change such as navigation, showing a SnackBar, showing a Dialog, etc...
The listener is guaranteed to only be called once for each state change unlike
the builder in BlocBuilder._

Try it out!
Notice a small message is shown each time you add/update or remove an item.

## Challenges

### Change an item

The app has a dialog to update todo items, but there is currently now way to
update an item after it has been created.

Can you fix that?

**Hint:**
Try adding a [GestureDetector](https://api.flutter.dev/flutter/widgets/GestureDetector-class.html) to the tile to show the dialog.

### Missing test

We don't have a test for `TodoCubit.toggle()`, can you write a test for it?

### Persistence

The app would be a lot more useful if the list was persisted on the device.

Can you implement it?

**Hint:** you can use
[shared_preferences](https://pub.dev/packages/shared_preferences) package for
on device persistence.
It works across all platforms supported by Flutter.

This might be a bit challenging.

Maybe you can find more hints in the [Password Manager
guide](../password-manager).
