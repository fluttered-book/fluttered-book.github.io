---
title: Chat - Authentication
description: Part 1 - Authentication
weight: 3
---

# Chat - Authentication

{{% hint info %}}
This guide is based on [Flutter Tutorial: building a Flutter chat
app](https://supabase.com/blog/flutter-tutorial-building-a-chat-app).
I'm making my own version to better fit the narrative I want to convey in this
book.
{{% /hint %}}

## Introduction

This is the first part in a small series, where we make a chat app using
Supabase.
In this part, we will work with authentication and build login and register
pages.

![Screenshot of login page](../images/chat-login.png)
![Screenshot of register page](../images/chat-register.png)

## Supabase setup

We will start by setting up the database tables and authentication provider in
Supabase.

Head over to [Supabase Dashboard](https://supabase.com/dashboard).
Login or create a new account.

### Create an organization

![Create an organization](../images/supabase-create-organization.png)

Make sure the **free plan** is selected.

### Create a project

![Create a project](../images/supabase-create-project.png)

Choose a region near your location.
Take note of the password.

### Disable email confirmation

By default, our users will need to confirm their email address when creating a
new account.
It means that an email is sent to an account with a link that the user has to
click.
Confirming emails this way is normally a good practice for security, as it
makes sure the user can access the email address they have written.
Verifying the email account allows us to use it for password reset.
However, having to juggle several email accounts for test users makes early
stages of development more cumbersome.
We will therefore disable it for now.

1. Select "Authentication" in left menu on Supabase dashboard
2. "Sign In / Up"
3. Click "Email" under "Auth Providers" section
4. Disable "Confirm email" and click "Save"

![Auth Provider Email](../images/supabase_remove_email_confirmation1.png)
![Remove email confirmation](../images/supabase_remove_email_confirmation2.png)

### Schema

Supabase is built on top of Postgres.
It means that schemas can be created with PostgreSQL [DDL](https://en.wikipedia.org/wiki/Data_definition_language).

Supabase already have a built-in `users` table that is used for authentication.
If we need additional fields associate with a user, then we can create our own
table to store it.
In our chat app we are going to create an additional table to store a username
for a user.

1. Go to [Supabase Dashboard](https://supabase.com/dashboard/)
2. Select your project
3. Click "SQL Editor" in the left menu
4. Run the SQL script shown below

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

![Supabase SQL Editor](../images/supabase-sql-editor.png)

{{% hint info %}}
Supabase also has a table editor that gives you a GUI to create the schema for
your database.
However, when writing instructions like this, it is simpler just to provide the
DDL.
{{% /hint %}}

### User defined functions

We can create user defined functions (UDF) directly in the database.
These functions can be executed by triggers.
A trigger is something that automatically executes some code in the database
when certain changes happen to a row in a table.

Execute the SQL shown here:

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

### New project

Let's create a new project Flutter project.

```sh
flutter create chat
cd chat
```

If you want Android support, you need to open
`android/app/src/main/AndroidManifest.xml` and add internet permission:

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
  <!-- Required to fetch data from the internet. -->
  <uses-permission android:name="android.permission.INTERNET" />
  <!-- ... -->
</manifest>
```

### Theme

Many of the apps we have worked on so far looks very similar.
Why don't we change things up a bit with a custom theme?

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

To make sure our app looks consistent we'll create a couple of small re-useable
widgets and other helpers.

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

/// Error message to display the user when unexpected error occurs.
const unexpectedErrorMessage = 'Unexpected error occurred.';

/// Set of extension methods to easily display a snackbar
extension ShowSnackBar on BuildContext {
  /// Displays a basic snackbar
  void showSnackBar({
    required String message,
    Color backgroundColor = Colors.white,
  }) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: backgroundColor),
    );
  }

  /// Displays a red snackbar indicating error
  void showErrorSnackBar({required String message}) {
    showSnackBar(message: message, backgroundColor: Colors.red);
  }
}
```

### Login layout

Before we get too much into the Supabase functionality.
Maybe we should create a couple of screens/pages to see how the theme looks.

In `lib/account/login/login_page.dart` put:

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

Change `lib/main.dart` to see it in action.

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

Try it out!

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
You can change the orange to something else if you want.
{{% /hint %}}

## Architecture

### Folder structure

You might have noticed that there are a lot of sub-folders for the files.
It can seem a bit excessive given the current number of files.
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
In an app using the feature-first approach, you will (at some point) have files
that are needed by several features and therefore don't naturally belong in any
of them.
What do we do with those files?
A simple solution is just to throw them in a folder named `common` or
`shared`.

As you can tell, we are using the **feature first** approach for this app.
It means creating a lot of folders in the beginning.
However down the line, it has the advantage of scaling better as the app
continues to grow.

When I write apps, I often start with **layer first**.
Then transition to **feature first** once I've roughly figured out what
functionality it will have and how they naturally cluster.

You can read more about how to architect your application in the
[Quality](../../quality) chapter.

### Abstractions

Testing is important for any real world app.
The last thing you want is to learn about bugs in your app from bad reviews in
the app store.

The way you write your application determines how easy it is to write tests
for.
The golden rule is to create an abstraction around anything external or
anything <abbr title="Input/Output">I/O</abbr>.
If you are making a network request or reading a file - then you need an
abstraction.

It is also good practice in general to create abstractions for services and
3rd party libraries.
Since it gives you the agility to chance vendor without having to
rewrite the entire app.

Even if you don't plan to write tests or switch libraries.
It can still be a good idea to make abstractions for certain things, since it
makes the development of your app future-proof.
Also, following the principles for creating good abstractions (regardless) will
make your code cleaner by separating concerns.

For this app, it means that we should create an abstraction around Supabase.
We will therefore create an abstract `ChatService` to act as an interface.
We will make an implementation of it called `SupabaseChatService` that uses
(drum roll) Supabase.
It allows us to easily swap out the concrete implementation for something else
if needed.
We could swap it for a mock implementation when writing tests.
Or maybe even change the BaaS provider completely.

Create `lib/common/chat_service.dart` with:

```dart
abstract class ChatService {
  String? get userId;
  Future<void> login({required String email, required String password});
  Future<void> register({
    required String email,
    required String password,
    required String username,
  });
  Future<void> logout();
}
```

We will add the implementation in a moment.

## Authentication

### Configure Supabase client library

We are going to add Supabase to our project before writing the abstraction, so
we can make the concrete implementation at the same time.

```sh
flutter pub add supabase_flutter flutter_dotenv
```

We also add the [flutter_dotenv](https://pub.dev/packages/flutter_dotenv)
package.
Since secrets such as API-keys shouldn't committed to Git.
We will therefore store the Supabase settings in `.env` file that we gitignore.
Create a `.env` file in the root of you flutter project folder.

1. Go to [Supabase Dashboard](https://supabase.com/dashboard/).
2. Select your project.
3. Click "Project Settings" (gear icon) in the menu to the left.
4. Go to the "Date API" section.
5. Copy "Project URL" and paste it in your `.env` (example below).
6. Then go to "API Keys" section.
7. Copy "Project API Keys (anon public)" and paste it in your `.env` file
   (example below).

![Supabase project URL](../images/supabase-project-url.png)
![Supabase project keys](../images/supabase-anon-key.png)

Paste the Supabase URL and anon key into the file as shown.

```sh
SUPABASE_URL=https://xxxxxxxxxxxxxxxxxxxx.supabase.co
SUPABASE_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

Before you do anything else you need to add `.env` to `.gitignore`, so you
don't accidentally commit it.

In a terminal (git-bash on Windows) within the project folder, do:

```sh
echo ".env" >> .gitignore
```

You also need to add `.env` to assets.
So open up `pubspec.yaml` and add the following under `flutter:`:

```yaml
assets:
  - .env
```

Replace `lib/main.dart` with the following to configure Supabase client.

```dart
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'account/register/register_page.dart';
import 'theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();

  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_KEY']!,
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
      theme: theme,
      home: RegisterPage(),
    );
  }
}
```

`dotenv.load()` from `flutter_dotenv` package loads the variables you just
configured from `.env`.

### Implement abstraction

Add an implementation of `ChatService` in `lib/common/chat_service.dart` as shown:

```dart
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseChatService extends ChatService {
  final _supabase = Supabase.instance.client;
  @override
  String? get userId => _supabase.auth.currentUser?.id;

  @override
  Future<void> login({required String email, required String password}) async {
    await _supabase.auth.signInWithPassword(email: email, password: password);
  }

  @override
  Future<void> register({
    required String email,
    required String password,
    required String username,
  }) async {
    await _supabase.auth.signUp(
      email: email,
      password: password,
      data: {'username': username},
    );
  }

  @override
  Future<void> logout() async {
    await _supabase.auth.signOut();
  }
}
```

`Supabase.instance.client` allows us to access a client object.
For convenience, we've assigned it to an instance variable.

{{% hint info %}}
`Supabase.instance` is an example of the use of the [singleton
pattern](https://en.wikipedia.org/wiki/Singleton_pattern).
{{% /hint %}}

Our `SupabaseChatService` implementation simply forwards the calls to the
client instance.

The only thing worth mentioning is that in the `register()` method body, we
have a map for `data:` parameter with `username`.
The username gets picked up by the user defined function in Postgres that we
had in the beginning (see [User defined functions](#user-defined-functions)).

We can use the [provider](https://pub.dev/packages/provider) package to make an
instance of `ChatService` accessible throughout the app.

```sh
flutter pub add provider
```

Then open `main.dart` and change the build method of `MyApp` to:

```dart
final session = Supabase.instance.client.auth.currentSession;
return Provider<ChatService>(
  create: (_) => SupabaseChatService(),
  child: MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'My Chat App',
    theme: theme,
    home: session == null ? RegisterPage() : ChatPage(),
  ),
);
```

Notice that we determine what page to show based on whether a session exists.
Meaning whether the user has authenticated or not.

Create a placeholder `ChatPage` widget in `lib/chat/chat_page.dart` to avoid
compiler errors.
Then read on.

```dart
import 'package:flutter/material.dart';

class ChatPage extends StatelessWidget {
  const ChatPage({super.key});

  static Route<void> route() {
    return MaterialPageRoute(builder: (context) => const ChatPage());
  }

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
```

A `Provider` is similar to `BlocProvider`, but for objects that aren't
Blocs/Cubits.

### Registration

We can now begin to implement the actual registration and login functionality.
We will start with registration.
Even though there isn't much logic involved, we will still create a cubit for
it.

Add [flutter_bloc](https://pub.dev/packages/flutter_bloc) package.

```sh
flutter pub add flutter_bloc
```

`lib/account/register/register_state.dart`

```dart
import 'package:flutter/foundation.dart';

@immutable
abstract class RegisterState {}

class RegisterReady extends RegisterState {}

class RegisterLoading extends RegisterState {}

class RegisterError extends RegisterState {
  final String message;
  RegisterError(this.message);
}

class Registered extends RegisterState {}
```

`lib/account/register/register_cubit.dart`

```dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../common/common.dart';
import 'register_state.dart';

class RegisterCubit extends Cubit<RegisterState> {
  final ChatService service;
  RegisterCubit(this.service) : super(RegisterReady());

  Future<void> register({
    required String email,
    required String password,
    required String username,
  }) async {
    emit(RegisterLoading());
    try {
      await service.register(
        email: email,
        password: password,
        username: username,
      );
      emit(Registered());
    } on AuthException catch (error) {
      emit(RegisterError(error.message));
    } catch (error) {
      emit(RegisterError(unexpectedErrorMessage));
    }
  }
}
```

`RegisterCubit` manages the states and delegates the registration to
`ChatService`.

To use it change `lib/account/register/register_page.dart` to:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../chat/chat_page.dart';
import '../../common/common.dart';
import 'register_cubit.dart';
import 'register_form.dart';
import 'register_state.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  static Route<void> route() {
    return MaterialPageRoute(builder: (context) => const RegisterPage());
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => RegisterCubit(context.read<ChatService>()),
      child: BlocListener<RegisterCubit, RegisterState>(
        listener: (context, state) {
          if (state is Registered) {
            Navigator.of(
              context,
            ).pushAndRemoveUntil(ChatPage.route(), (route) => false);
          } else if (state is RegisterError) {
            context.showErrorSnackBar(message: state.message);
          }
        },
        child: Scaffold(
          appBar: AppBar(title: const Text('Register')),
          body: RegisterForm(),
        ),
      ),
    );
  }
}
```

We are using a `BlocListener` to navigate to `ChatPage` when state changes to
`Registered`.

As you can see, we are creating a new `RegisterForm` widget for the form
fields.
It is because that in order to access a value from a Provider/BlocProvider you
will need a child context of the provider.
The `RegisterCubit` will be accessed through `context.read<RegisterCubit>()`
when "Register" button is tapped.

![Register page](../images/chat-register.png)

So we need a child context for `context.read...`.
We could either wrap the form in a `BlocBuilder` or extract it into its own
widget.
I prefer having small widgets, so extracting the form into its own widget is my
preferred option.

Now for the form widget itself.
Create `lib/account/register/register_form.dart` with:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../common/widgets.dart';
import '../login/login_page.dart';
import 'register_cubit.dart';
import 'register_state.dart';
import 'validators.dart';

class RegisterForm extends StatefulWidget {
  const RegisterForm({super.key});

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _usernameController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) return;
    context.read<RegisterCubit>().register(
      email: _emailController.text,
      password: _passwordController.text,
      username: _usernameController.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RegisterCubit, RegisterState>(
      builder: (context, state) {
        return Form(
          key: _formKey,
          child: ListView(
            padding: formPadding,
            children: [
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(label: Text('Email')),
                keyboardType: TextInputType.emailAddress,
              ),
              const FormSpacer(),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(label: Text('Password')),
              ),
              const FormSpacer(),
              TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(label: Text('Username')),
              ),
              const FormSpacer(),
              ElevatedButton(
                onPressed: state is RegisterLoading ? null : _signUp,
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
        );
      },
    );
  }
}
```

It checks that the form is valid with `_formKey.currentState!.validate()`.
Speaking of validation, we should probably add some validation rules.
We are going to add those in a separate file.
Such that we don't pollute `RegisterForm`.

`lib/account/register/validators.dart`

```dart
String? emailValidator(String? value) =>
    value == null || value.isEmpty ? 'Required' : null;

String? passwordValidator(String? value) {
  if (value == null || value.isEmpty) return 'Required';
  if (value.length < 8) return '8 characters minimum';
  return null;
}

String? usernameValidator(String? value) {
  if (value == null || value.isEmpty) return 'Required';
  if (!RegExp(r'^[A-Za-z0-9_]{3,24}$').hasMatch(value)) {
    return '3-24 long with alphanumeric or underscore';
  }
  return null;
}
```

To use the validators, you need to change `_RegisterFormState` so that each of
the `TextFormField` receive a reference to the corresponding validation
function as `validator` parameter.
Example:

```dart
TextFormField(
  controller: _emailController,
  validator: emailValidator,
  // ...
),
```

### Login

We are simply following the same structure as for registration.
Create the files as listed below, but take some time to make sure you
understand what is going on.

`lib/account/login/login_state.dart`

```dart
import 'package:flutter/foundation.dart';

@immutable
abstract class LoginState {}

class LoginReady extends LoginState {}

class LoginLoading extends LoginState {}

class LoginError extends LoginState {
  final String message;
  LoginError(this.message);
}

class LoggedIn extends LoginState {}
```

`lib/account/login/login_cubit.dart`

```dart
import 'package:chat/common/chat_service.dart';
import 'package:chat/common/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  final ChatService service;

  LoginCubit(this.service) : super(LoginReady());

  Future<void> login({required String email, required String password}) async {
    emit(LoginLoading());
    try {
      await service.login(email: email, password: password);
      emit(LoggedIn());
    } on AuthException catch (error) {
      emit(LoginError(error.message));
    } catch (_) {
      emit(LoginError(unexpectedErrorMessage));
    }
  }
}
```

`lib/account/login/login_page.dart`

```dart
import 'package:chat/common/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../chat/chat_page.dart';
import '../../common/chat_service.dart';
import 'login_cubit.dart';
import 'login_state.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  static Route<void> route() {
    return MaterialPageRoute(builder: (context) => const LoginPage());
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => LoginCubit(context.read<ChatService>()),
      child: BlocConsumer<LoginCubit, LoginState>(
        listener: (context, state) {
          if (state is LoggedIn) {
            Navigator.of(
              context,
            ).pushAndRemoveUntil(ChatPage.route(), (route) => false);
          } else if (state is LoginError) {
            context.showErrorSnackBar(message: state.message);
          }
        },
        builder:
            (context, state) => Scaffold(
              appBar: AppBar(title: const Text('Sign In')),
              body: LoginForm(),
            ),
      ),
    );
  }
}
```

A
[BlocConsumer](https://pub.dev/documentation/flutter_bloc/latest/flutter_bloc/BlocConsumer-class.html)
is simply a combination of
[BlocBuilder](https://pub.dev/documentation/flutter_bloc/latest/flutter_bloc/BlocBuilder-class.html)
and
[BlocListener](https://pub.dev/documentation/flutter_bloc/latest/flutter_bloc/BlocListener-class.html).

`lib/account/login/login_form.dart`

```dart
import 'package:chat/common/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'login_cubit.dart';
import 'login_state.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  void _login() {
    context.read<LoginCubit>().login(
      email: _emailController.text,
      password: _passwordController.text,
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LoginCubit, LoginState>(
      builder:
          (context, state) => Form(
            child: ListView(
              padding: formPadding,
              children: [
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                  keyboardType: TextInputType.emailAddress,
                ),
                FormSpacer(),
                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(labelText: 'Password'),
                  obscureText: true,
                ),
                FormSpacer(),
                ElevatedButton(
                  onPressed: state is LoginLoading ? null : _login,
                  child: const Text('Login'),
                ),
              ],
            ),
          ),
    );
  }
}
```

## Wrapping up

Soon I'll encourage you to try out the app and create a couple of
different users.
But before you do that, it would be really convenient if you had a way to log
out.

Create/change `lib/chat/chat_page.dart` to:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../account/register/register_page.dart';
import '../common/chat_service.dart';

class ChatPage extends StatelessWidget {
  const ChatPage({super.key});

  static Route<void> route() {
    return MaterialPageRoute(builder: (context) => const ChatPage());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat'),
        actions: [
          IconButton(
            onPressed: () {
              context.read<ChatService>().logout();
              Navigator.of(
                context,
              ).pushAndRemoveUntil(RegisterPage.route(), (route) => false);
            },
            icon: Icon(Icons.logout),
          ),
        ],
      ),
      body: Center(child: Text("Chat placeholder")),
    );
  }
}
```

Since we have "Confirm Email" disabled it doesn't matter what address you type,
just as long as it is formatted like a valid email.

Go ahead and try it out!

{{% details "Reveal solution" %}}
[Go to source](https://github.com/fluttered-book/chat/tree/authentication)
{{% /details %}}
