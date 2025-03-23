---
title: Chat - Authentication
description: Part 1 - Authentication
weight: 3
---

# Chat

## Introduction

This is the first part in a small series where we make a chat app using
Supabase.
In this part we will work with authentication and build login and register
pages.

{{% hint info %}}
This guide is based on [Flutter Tutorial: building a Flutter chat
app](https://supabase.com/blog/flutter-tutorial-building-a-chat-app).
I'm making my own version to better fit the narrative I want to convey in this
book.
{{% /hint %}}

## Supabase setup

We will start with setting up tables and authentication provider in Supabase.

Head over to [Supabase Dashboard](https://supabase.com/dashboard).
Login or create a new account.

### Create an organization

![Create an organization](../images/supabase-create-organization.png)

Make sure the **free plan** is selected.

### Create a project

![Create a project](../images/supabase-create-project.png)

Choose a region near where you are located and take note of the password.

### Disable email confirmation

By default, our users will need to confirm their email address when creating a
new account.
This is normally good practice for security as it makes sure they can access
the email address they have written.
It ensures they are who they claim, and that email can be used for password
reset.

1. Select "Authentication" in left menu
2. "Sign In / Up"
3. Click arrow "Email" provider
4. Disable "Confirm email"

![Auth Provider Email](../images/supabase_remove_email_confirmation1.png)
![Remove email confirmation](../images/supabase_remove_email_confirmation2.png)

### Schema

Supabase is built on top of Postgres.
It means that schemas can be created with PostgreSQL DDL.

Supabase already have a built-in `users` table used for authentication.
If we need additional fields associate with a user then we need to create an
additional table to store it.
In our chat app we also want to store a username for a user.
Let's create a new table for it.

```sql
create table if not exists public.profiles (
    id uuid references auth.users on delete cascade not null primary key,
    username varchar(24) not null unique,
    created_at timestamp with time zone default timezone('utc' :: text, now()) not null,

    -- username should be 3 to 24 characters long containing alphabets, numbers and underscores
    constraint username_validation check (username ~* '^[A-Za-z0-9_]{3,24}$')
);
comment on table public.profiles is 'Holds all of users profile information';
```

_NOTE: Supabase has a table editor that gives you a GUI to create schema for
your database.
It's just simpler when writing instructions like this to provide the DDL_

We can create user defined functions (UDF) directly in the database.
These functions can be executed by triggers.
A trigger can automatically execute a function when certain changes happens to
a row in a table.

```sql
-- Function to create a new row in profiles table upon signup
-- Also copies the username value from metadata
create or replace function handle_new_user() returns trigger as $$
    begin
        insert into public.profiles(id, username)
        values(new.id, new.raw_user_meta_data->>'username');

        return new;
    end;
$$ language plpgsql security definer;

-- Trigger to call `handle_new_user` when new user signs up
create trigger on_auth_user_created
    after insert on auth.users
    for each row
    execute function handle_new_user();
```

## Flutter setup

### New project

Moving over to the Flutter side.
Let's create a new project.

```sh
flutter create chat
cd chat
flutter pub add supabase_flutter
```

### Theme

Many of the apps we have worked on so far looks very similar.
Why don't we change things up a bit with a custom theme.

Add a file `lib/theme.dart` with:

```dart
import 'package:flutter/material.dart';

/// Basic theme to change the look and feel of the app
final theme = ThemeData.light().copyWith(
  primaryColorDark: Colors.orange,
  appBarTheme: const AppBarTheme(
    elevation: 1,
    backgroundColor: Colors.white,
    iconTheme: IconThemeData(color: Colors.black),
    titleTextStyle: TextStyle(color: Colors.black, fontSize: 18),
  ),
  primaryColor: Colors.orange,
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(foregroundColor: Colors.orange),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      foregroundColor: Colors.white,
      backgroundColor: Colors.orange,
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    floatingLabelStyle: const TextStyle(color: Colors.orange),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Colors.grey, width: 2),
    ),
    focusColor: Colors.orange,
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Colors.orange, width: 2),
    ),
  ),
);
```

To further make sure our app looks consistent we'll create a couple of small
re-useable widgets.

Put these in `lib/common/widgets.dart`.

```dart
import 'package:flutter/material.dart';

class Spinner extends StatelessWidget {
  const Spinner({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(child: CircularProgressIndicator(color: Colors.orange));
  }
}

class FormSpacer extends StatelessWidget {
  const FormSpacer({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(width: 16, height: 16);
  }
}

/// Some padding for all the forms to use
const formPadding = EdgeInsets.symmetric(vertical: 20, horizontal: 16);
```

### Login layout

Before we get too much into the Supabase functionality.
Maybe we should create a couple of screens/pages to try out our theme.

It `lib/account/login/login_page.dart` put:

```dart
class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  static Route<void> route() {
    return MaterialPageRoute(builder: (context) => const LoginPage());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign In')),
      body: Form(
        child: ListView(
          padding: formPadding,
          children: [
            TextFormField(
              decoration: const InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
            ),
            FormSpacer(),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            FormSpacer(),
            ElevatedButton(onPressed: () {}, child: const Text('Login')),
          ],
        ),
      ),
    );
  }
}
```

Change `lib/main.dart` so we can see it in action.

```dart
void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'My Chat App',
      theme: theme,
      home: LoginPage(),
    );
  }
}
```

![Login page](../images/chat-login.png)

### Register layout

In `lib/account/register/register_page.dart` put:

```dart
class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  static Route<void> route() {
    return MaterialPageRoute(builder: (context) => const RegisterPage());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign In')),
      body: Form(
          child: ListView(
            padding: formPadding,
            children: [
              TextFormField(
                decoration: const InputDecoration(label: Text('Email')),
                keyboardType: TextInputType.emailAddress,
              ),
              const FormSpacer(),
              TextFormField(
                obscureText: true,
                decoration: const InputDecoration(label: Text('Password')),
              ),
              const FormSpacer(),
              TextFormField(
                decoration: const InputDecoration(label: Text('Username')),
              ),
              const FormSpacer(),
              ElevatedButton(
                onPressed: () {},
                child: const Text('Register'),
              ),
              const FormSpacer(),
              TextButton(
                onPressed: () {
                  Navigator.of(context).push(LoginPage.route());
                },
                child: const Text('I already have an account'),
              ),
            ],
          ),
        )
    );
  }
}
```

Change the page in `lib/main.dart` to see it in action.

![Register page](../images/chat-register.png)

{{% hint info %}}
You can change the orange to something else if you don't like it.
{{% /hint %}}

## Architecture

### Folder structure

You might have noticed that there are a lot of sub-folders for the files.
It can seem a bit excessive for the number of files current.
The folder structure is just to prepare for several additional files being
added.

There are two main approaches people take when organizing files in projects.

There is **layer first**, where all files of a certain conceptual type is
put in the same folder.
Example: `lib/models/` for all models, `lib/pages` for widgets, `lib/bloc` for
BLoC/Cubit etc.

Then there is the **feature first** approach, where the app is divided into
vertical slices based on feature.
Example: `lib/account/login/login_page.dart`,
`lib/account/login/login_cubit.dart`,
`lib/account/register/register_page.dart`,
`lib/account/register/register_cubit` etc.
In app using this approach you will (at some point) have files that are needed
by several features and don't naturally belong in any of them.
What to do with those files?
A simple solution is just to throw them in a folder called `common` or
`shared`.

As you can tell we are using the **feature first** approach here.
It means creating a lot of folders in the beginning, but has the advantage of
scaling better as the app grows.

You are not locked to the approach you chose in the beginning, as you can
always restructure your app along the way.
Just make sure to get the rest of your development team in on the
restructuring.

When I write apps I often start with **layer first**, then restructure when I
figure out roughly what features my app is going to have and how they naturally
cluster.

You can read more about how to architect your application in the
[Quality](../../quality) chapter.

### Abstractions

Testing is important for any real world app, as the last thing you want is to
find out about bugs in your app from bad reviews in the app store.

How you write your application determines how easy it is to write tests for.
The golden rule is to create an abstraction around anything external or
anything IO.
If you are making a network request or reading a file then you need an
abstraction.
It is also good practice to create abstractions for services and 3rd party
libraries since it gives you the agility to chance vendor without having to
rewrite your entire app.

Even if you don't plan to write test or switch libraries it can still be a good
idea to make abstractions for certain things since it makes the development of
your app future-proof.
Also following the principles for creating good abstractions regardless will
make your code cleaner by separating concerns.

For this app it means that since Supabase is an external service we should
create an abstraction around it.
Therefore, we are going to create an abstract `ChatService` to act as an interface.
We will make an implementation of it called `SupabaseChatService` that uses
Supabase.
It allows us to easily swap out the concrete implementation for something else
if needed.
We could swap it for a mock implementation when writing widget or BLoC tests.
Or maybe even to change the BaaS provider completely.

## Authentication

Replace `lib/main.dart` but with your own `SUPABASE_URL` and
`SUPABASE_ANON_KEY` and `SUPABASE_ANON_KEY`.

```dart
import 'package:chat/constants.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'pages/splash_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    // TODO: Replace credentials with your own
    url: 'SUPABASE_URL',
    anonKey: 'SUPABASE_ANON_KEY',
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'My Chat App',
      theme: appTheme,
      home: const SplashPage(),
    );
  }
}
```

`lib/pages/splash_page.dart`

```dart
import 'package:chat/constants.dart';
import 'package:flutter/material.dart';

/// Page to redirect users to the appropriate page depending on the initial auth state
class SplashPage extends StatefulWidget {
  const SplashPage({Key? key}) : super(key: key);

  @override
  SplashPageState createState() => SplashPageState();
}

class SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _redirect();
  }

  Future<void> _redirect() async {
    // await for for the widget to mount
    await Future.delayed(Duration.zero);

    final session = supabase.auth.currentSession;
    // TODO redirect pages
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: preloader);
  }
}
```

`lib/pages/register_page.dart`

````

```dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../constants.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key, required this.isRegistering}) : super(key: key);

  static Route<void> route({bool isRegistering = false}) {
    return MaterialPageRoute(
      builder: (context) => RegisterPage(isRegistering: isRegistering),
    );
  }

  final bool isRegistering;

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final bool _isLoading = false;

  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _usernameController = TextEditingController();

  Future<void> _signUp() async {
    final isValid = _formKey.currentState!.validate();
    if (!isValid) {
      return;
    }
    final email = _emailController.text;
    final password = _passwordController.text;
    final username = _usernameController.text;
    try {
      await supabase.auth.signUp(
        email: email,
        password: password,
        data: {'username': username},
      );
      // TODO uncomment navigation
      //Navigator.of(
      //  context,
      //).pushAndRemoveUntil(ChatPage.route(), (route) => false);
    } on AuthException catch (error) {
      context.showErrorSnackBar(message: error.message);
    } catch (error) {
      context.showErrorSnackBar(message: unexpectedErrorMessage);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Register')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: formPadding,
          children: [
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(label: Text('Email')),
              validator: (val) {
                if (val == null || val.isEmpty) {
                  return 'Required';
                }
                return null;
              },
              keyboardType: TextInputType.emailAddress,
            ),
            formSpacer,
            TextFormField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(label: Text('Password')),
              validator: (val) {
                if (val == null || val.isEmpty) {
                  return 'Required';
                }
                if (val.length < 6) {
                  return '6 characters minimum';
                }
                return null;
              },
            ),
            formSpacer,
            TextFormField(
              controller: _usernameController,
              decoration: const InputDecoration(label: Text('Username')),
              validator: (val) {
                if (val == null || val.isEmpty) {
                  return 'Required';
                }
                final isValid = RegExp(r'^[A-Za-z0-9_]{3,24}$').hasMatch(val);
                if (!isValid) {
                  return '3-24 long with alphanumeric or underscore';
                }
                return null;
              },
            ),
            formSpacer,
            ElevatedButton(
              onPressed: _isLoading ? null : _signUp,
              child: const Text('Register'),
            ),
            formSpacer,
            TextButton(
              onPressed: () {
                // TODO uncomment navigation
                //Navigator.of(context).push(LoginPage.route());
              },
              child: const Text('I already have an account'),
            ),
          ],
        ),
      ),
    );
  }
}
````

`lib/pages/login_page.dart`

```dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../constants.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  static Route<void> route() {
    return MaterialPageRoute(builder: (context) => const LoginPage());
  }

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _isLoading = false;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  Future<void> _signIn() async {
    setState(() {
      _isLoading = true;
    });
    try {
      await supabase.auth.signInWithPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );
      // TODO uncomment navigation
      //Navigator.of(context)
      //    .pushAndRemoveUntil(ChatPage.route(), (route) => false);
    } on AuthException catch (error) {
      context.showErrorSnackBar(message: error.message);
    } catch (_) {
      context.showErrorSnackBar(message: unexpectedErrorMessage);
    }
    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign In')),
      body: ListView(
        padding: formPadding,
        children: [
          TextFormField(
            controller: _emailController,
            decoration: const InputDecoration(labelText: 'Email'),
            keyboardType: TextInputType.emailAddress,
          ),
          formSpacer,
          TextFormField(
            controller: _passwordController,
            decoration: const InputDecoration(labelText: 'Password'),
            obscureText: true,
          ),
          formSpacer,
          ElevatedButton(
            onPressed: _isLoading ? null : _signIn,
            child: const Text('Login'),
          ),
        ],
      ),
    );
  }
}
```

`lib/pages/chat_page.dart`

```dart
import 'dart:async';

import 'package:chat/constants.dart';
import 'package:chat/models/massage.dart';
import 'package:chat/models/profile.dart';
import 'package:flutter/material.dart';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:timeago/timeago.dart';

/// Page to chat with someone.
///
/// Displays chat bubbles as a ListView and TextField to enter new chat.
class ChatPage extends StatefulWidget {
  const ChatPage({Key? key}) : super(key: key);

  static Route<void> route() {
    return MaterialPageRoute(builder: (context) => const ChatPage());
  }

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  late final Stream<List<Message>> _messagesStream;
  final Map<String, Profile> _profileCache = {};

  @override
  void initState() {
    final myUserId = supabase.auth.currentUser!.id;
    _messagesStream = supabase
        .from('messages')
        .stream(primaryKey: ['id'])
        .order('created_at')
        .map(
          (maps) =>
              maps
                  .map(
                    (map) => MessageMapper.fromMap(
                      map..putIfAbsent("profileId", () => myUserId),
                    ),
                  )
                  .toList(),
        );
    super.initState();
  }

  Future<void> _loadProfileCache(String profileId) async {
    if (_profileCache[profileId] != null) {
      return;
    }
    final data =
        await supabase.from('profiles').select().eq('id', profileId).single();
    final profile = ProfileMapper.fromMap(data);
    setState(() {
      _profileCache[profileId] = profile;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chat')),
      body: StreamBuilder<List<Message>>(
        stream: _messagesStream,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final messages = snapshot.data!;
            return Column(
              children: [
                Expanded(
                  child:
                      messages.isEmpty
                          ? const Center(
                            child: Text('Start your conversation now :)'),
                          )
                          : ListView.builder(
                            reverse: true,
                            itemCount: messages.length,
                            itemBuilder: (context, index) {
                              final message = messages[index];

                              /// I know it's not good to include code that is not related
                              /// to rendering the widget inside build method, but for
                              /// creating an app quick and dirty, it's fine 😂
                              _loadProfileCache(message.profileId);

                              return _ChatBubble(
                                message: message,
                                profile: _profileCache[message.profileId],
                              );
                            },
                          ),
                ),
                const _MessageBar(),
              ],
            );
          } else {
            return preloader;
          }
        },
      ),
    );
  }
}

/// Set of widget that contains TextField and Button to submit message
class _MessageBar extends StatefulWidget {
  const _MessageBar({Key? key}) : super(key: key);

  @override
  State<_MessageBar> createState() => _MessageBarState();
}

class _MessageBarState extends State<_MessageBar> {
  late final TextEditingController _textController;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.grey[200],
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Expanded(
                child: TextFormField(
                  keyboardType: TextInputType.text,
                  maxLines: null,
                  autofocus: true,
                  controller: _textController,
                  decoration: const InputDecoration(
                    hintText: 'Type a message',
                    border: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: EdgeInsets.all(8),
                  ),
                ),
              ),
              TextButton(
                onPressed: () => _submitMessage(),
                child: const Text('Send'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    _textController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _submitMessage() async {
    final text = _textController.text;
    final myUserId = supabase.auth.currentUser!.id;
    if (text.isEmpty) {
      return;
    }
    _textController.clear();
    try {
      await supabase.from('messages').insert({
        'profile_id': myUserId,
        'content': text,
      });
    } on PostgrestException catch (error) {
      context.showErrorSnackBar(message: error.message);
    } catch (_) {
      context.showErrorSnackBar(message: unexpectedErrorMessage);
    }
  }
}

class _ChatBubble extends StatelessWidget {
  const _ChatBubble({Key? key, required this.message, required this.profile})
    : super(key: key);

  final Message message;
  final Profile? profile;

  @override
  Widget build(BuildContext context) {
    List<Widget> chatContents = [
      if (!message.isMine)
        CircleAvatar(
          child:
              profile == null
                  ? preloader
                  : Text(profile!.username.substring(0, 2)),
        ),
      const SizedBox(width: 12),
      Flexible(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          decoration: BoxDecoration(
            color:
                message.isMine
                    ? Theme.of(context).primaryColor
                    : Colors.grey[300],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(message.content),
        ),
      ),
      const SizedBox(width: 12),
      Text(format(message.createdAt, locale: 'en_short')),
      const SizedBox(width: 60),
    ];
    if (message.isMine) {
      chatContents = chatContents.reversed.toList();
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 18),
      child: Row(
        mainAxisAlignment:
            message.isMine ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: chatContents,
      ),
    );
  }
}
```
