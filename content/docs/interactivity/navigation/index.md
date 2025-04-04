---
title: Navigation
description: >-
  How to navigate between screens
weight: 2
---

{{< classic-dartpad >}}

# Theory

Flutter uses a stack of routes for navigation between screens.
It is always the topmost route in the navigation stack that is shown.

Here is a visual representation of the stack operations.

![Stack operations](images/stack_operations.drawio.svg)

You can add a new route with:

```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => const SecondScreen(),
  ),
);
```

Pop a route makes you go back to previous screen:

```dart
Navigator.pop(context);
```

Replace with:

```dart
Navigator.pushReplacement(
  context,
  MaterialPageRoute(
    builder: (context) => const SecondScreen(),
  ),
);
```

# Demo

Here is a demo, so you can see it in action.

```run-dartpad:theme-dark:mode-flutter:width-100%:height-1000px
import 'package:flutter/material.dart';

void main() {
  runApp(const MaterialApp(
    title: 'Navigation Basics',
    home: FirstScreen(),
  ));
}

class FirstScreen extends StatelessWidget {
  const FirstScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('First Route'),
      ),
      body: Center(
        child: ElevatedButton(
          child: const Text('Push route'),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const SecondScreen(),
              ),
            );
          },
        ),
      ),
    );
  }
}

class SecondScreen extends StatelessWidget {
  const SecondScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Second Route'),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ThirdScreen(),
                  ),
                );
              },
              child: const Text('Push another route'),
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ThirdScreen(),
                  ),
                );
              },
              child: const Text('Push replacement'),
            ),
          ],
        ),
      ),
    );
  }
}

class ThirdScreen extends StatelessWidget {
  const ThirdScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Third Route'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('Pop'),
        ),
      ),
    );
  }
}
```

If you pop the last route, you will close the app.

# Cupertino

Here is a Cupertino version.
Notice that the animation is different.

```run-dartpad:theme-dark:mode-flutter:width-100%:height-800px
import 'package:flutter/cupertino.dart';

void main() {
  runApp(const CupertinoApp(
    title: 'Navigation Basics',
    home: FirstScreen(),
  ));
}

class FirstScreen extends StatelessWidget {
  const FirstScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('First Route')
      ),
      child: Center(
        child: CupertinoButton(
          child: const Text('Push route'),
          onPressed: () {
            Navigator.push(
              context,
              CupertinoPageRoute(
                builder: (context) => const SecondScreen(),
              ),
            );
          },
        ),
      ),
    );
  }
}

class SecondScreen extends StatelessWidget {
  const SecondScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('Second Route')
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CupertinoButton(
              onPressed: () {
                Navigator.push(
                  context,
                  CupertinoPageRoute(
                    builder: (context) => const ThirdScreen(),
                  ),
                );
              },
              child: const Text('Push another route'),
            ),
            SizedBox(height: 24),
            CupertinoButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  CupertinoPageRoute(
                    builder: (context) => const ThirdScreen(),
                  ),
                );
              },
              child: const Text('Push replacement'),
            ),
          ],
        ),
      ),
    );
  }
}

class ThirdScreen extends StatelessWidget {
  const ThirdScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Third Route'),
      ),
      child: Center(
        child: CupertinoButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('Pop'),
        ),
      ),
    );
  }
}
```

# BuildContext

All the methods on
[Navigator](https://api.flutter.dev/flutter/widgets/Navigator-class.html), that
we have seen - takes a
[BuildContext](https://api.flutter.dev/flutter/widgets/BuildContext-class.html)
as first parameter. Why is that?

You see, `Navigator` is a `StatefulWidget` and its `State` object controls what
route is shown.

But, where do the `Navigator` come from?
Well, both `MaterialApp` and `CuptertinoApp` builds a `Navigator` as part of
their build tree.

To answer the original question.
The `BuildContext` is used to reach up the tree for the `NavigatorState`.
This is similar to what happens when we do `Theme.of(context)`.

So, `BuildContext` allows us to reach up the tree, therefore it must hold
information about the tree.
**Elements** also hold information about the tree.
In fact `BuildContext` is just an interface implemented by `Element` 🤯.

# Named routes

Navigation can also be done using named routes.

Here, we give `MaterialApp` a map of `routes` and an initial route.

```dart
MaterialApp(
  initialRoute: '/',
  routes: {
    '/': (context) => const NavigationScreen(),
    '/home': (context) => const HomeScreen(),
    '/settings': (context) => const SettingsScreen(),
  },
)
```

You can then navigate to a route using the name.

```dart
Navigator.pushNamed(context, '/home')
```

Here is a demo with a couple of screens.

```run-dartpad:theme-dark:mode-flutter:width-100%:height-800px
import 'package:flutter/material.dart';

void main() {
  runApp(
    MaterialApp(
      title: 'Named Routes Demo',
      initialRoute: '/',
      routes: {
        '/': (context) => const NavigationScreen(),
        '/home': (context) => const HomeScreen(),
        '/settings': (context) => const SettingsScreen(),
      },
    ),
  );
}

class NavigationScreen extends StatelessWidget {
  const NavigationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          ElevatedButton.icon(
            icon: Icon(Icons.home),
            label: Text("Home"),
            onPressed: () => Navigator.pushNamed(context, '/home'),
          ),
          SizedBox(height: 8),
          ElevatedButton.icon(
            icon: Icon(Icons.settings),
            label: Text("Settings"),
            onPressed: () => Navigator.pushNamed(context, '/settings'),
          ),
        ]),
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: Center(child: Icon(Icons.home)),
    );
  }
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Center(child: Icon(Icons.settings)),
    );
  }
}
```
