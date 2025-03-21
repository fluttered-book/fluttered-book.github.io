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

Supabase already have a build in `users` table used for authentication.
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

Moving over to the Flutter side.
Let's create a new project.

```sh
flutter create chat
cd chat
flutter pub add supabase_flutter
```

Create Supabase project.

Tables:

`lib/constants.dart`

```dart
import 'package:flutter/material.dart';
  import 'package:supabase_flutter/supabase_flutter.dart';

  /// Supabase client
  final supabase = Supabase.instance.client;

  /// Simple preloader inside a Center widget
  const preloader =
      Center(child: CircularProgressIndicator(color: Colors.orange));

  /// Simple sized box to space out form elements
  const formSpacer = SizedBox(width: 16, height: 16);

  /// Some padding for all the forms to use
  const formPadding = EdgeInsets.symmetric(vertical: 20, horizontal: 16);

  /// Error message to display the user when unexpected error occurs.
  const unexpectedErrorMessage = 'Unexpected error occurred.';

  /// Basic theme to change the look and feel of the app
  final appTheme = ThemeData.light().copyWith(
    primaryColorDark: Colors.orange,
    appBarTheme: const AppBarTheme(
      elevation: 1,
      backgroundColor: Colors.white,
      iconTheme: IconThemeData(color: Colors.black),
      titleTextStyle: TextStyle(
        color: Colors.black,
        fontSize: 18,
      ),
    ),
    primaryColor: Colors.orange,
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: Colors.orange,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: Colors.orange,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      floatingLabelStyle: const TextStyle(
        color: Colors.orange,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: Colors.grey,
          width: 2,
        ),
      ),
      focusColor: Colors.orange,
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: Colors.orange,
          width: 2,
        ),
      ),
    ),
  );

  /// Set of extension methods to easily display a snackbar
  extension ShowSnackBar on BuildContext {
    /// Displays a basic snackbar
    void showSnackBar({
      required String message,
      Color backgroundColor = Colors.white,
    }) {
      ScaffoldMessenger.of(this).showSnackBar(SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
      ));
    }

    /// Displays a red snackbar indicating error
    void showErrorSnackBar({required String message}) {
      showSnackBar(message: message, backgroundColor: Colors.red);
    }
  }
```

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
