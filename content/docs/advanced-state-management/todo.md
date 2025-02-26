---
title: To-do app
description: >-
  Simplified password-manager demonstrating the use of Cubit
weight: 3
---

# To-do app

## Create project

```sh
flutter create todo
cd todo
flutter pub add flutter_bloc
```

## Prototype layout

Replace `MyApp`.

```dart
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

## Data model

```sh
flutter pub add equatable
flutter pub add uuid
```

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

## Managing state with a Cubit

`lib/core/todo_state.dart`

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

`lib/core/todo_cubit.dart`

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

We do something with an index which is pretty easy to screw up.
Off by one error are very common when working with indexes.
Better add some tests!

```sh
flutter pub add bloc_test
```

`test/core/todo_cubit_test.dart`

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
    final newState = state.copyWith(todos: [
      ...state.todos.take(index),
      todo,
      ...state.todos.skip(index + 1),
    ]);
    emit(newState);
  }

  void delete(String id) {
    final index = state.todos.indexWhere((x) => x.id == id);
    final newState = state.copyWith(todos: [
      ...state.todos.take(index),
      ...state.todos.skip(index + 1),
    ]);
    emit(newState);
  }

  void toggle(String id) {
    final todo = state.todos.singleWhere((x) => x.id == id);
    update(todo.toggleDone());
  }
}
```

## Make functional UI

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

Add `lib/ui/todo_list_page.dart` with:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../core/todo_cubit.dart';
import '../core/todo_state.dart';
import 'update_todo_dialog.dart';

class TodoListPage extends StatelessWidget {
  const TodoListPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("ToDo")),
          builder: (context, state) {
body: BlocBuilder<TodoCubit, TodoState>(
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
                      onChanged: (_) =>
                          context.read<TodoCubit>().toggle(todo.id),
                    ),
                  ),
                  onDismissed: (_) => context.read<TodoCubit>().delete(todo.id),
                );
              },
              separatorBuilder: (context, index) => const Divider(),
              itemCount: state.todos.length,
            );
          }),
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
    );
  }
}
```

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

In `lib/ui/todo_list_page.dart`, add following as parameter to `BlocBuilder` just above the `build: (context) =>` part:

```dart
buildWhen: (previous, current) => previous.todos != current.todos,
```

## Show saving message

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

Change `BlocBuilder` to `BlocConsumer`.
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
