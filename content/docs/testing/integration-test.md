---
title: Integration test
weight: 5
---

# Integration test

{{% hint danger %}}
This page is still in its early stages.
{{% /hint %}}

Integration tests verify the behavior of the entire app.
And can be run on real device.

Integrations tests can look very similar to widget tests.
Here is a comparison table to help set them apart.

| Description                        | Widget       | Integration                   |
| ---------------------------------- | ------------ | ----------------------------- |
| What gets tested                   | widget       | the whole app                 |
| Folder with tests                  | test/        | integration_test/             |
| Command to execute                 | flutter test | flutter test integration_test |
| Can you see the UI being rendered? | no           | yes                           |
| Execution speed                    | fast         | slow                          |

To create an integration test you first need to add the `integration_test`
dependency.

```sh
flutter pub add 'dev:integration_test:{"sdk":"flutter"}'
```

Integration tests are written the same way as widget tests, except that you
must call `IntegrationTestWidgetsFlutterBinding.ensureInitialized()` before
executing any tests.

## Adding integration tests

Let's try to convert widget test for the calculator into an integration test.
You can either use your own solution, or mine by cloning the solution branch.

```sh
git clone -b separate-logic https://github.com/fluttered-book/quiz.git
```

Open the project in Android Studio.

Make a copy of your widget test (in my solution it is
`test/calculator_app_test.dart`) to
`integration_test/calculator_app_test.dart`.

As the first line of the main method in the test file you should add
`IntegrationTestWidgetsFlutterBinding.ensureInitialized()`.

```dart
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // All `widgetTest` must be below.
}
```

## Running the tests

### Mobile (iOS, Android)

My solution only supports web platform.
So, you will need to add support for mobile.

You can do that by running:

```sh
flutter create . --platforms=web,android,ios
```

For iOS you need to set up code signing in Xcode.
Refer back to the installation guide for iPhone to find instructions.

Make sure your device is connected.
Then run:

```sh
flutter test integration_test
```

You can also run tests on Android emulator.
Start the device from Device Manager in Android Studio.
Then rerun the command above.

{{% hint info %}}
Notice that you can see the app run and all the interactions animate.
It is running the full app on a real device, the only thing that is simulated
is tapping on button.
{{% /hint %}}

Even though interactions happen pretty quick, it is still a lot slower running
this way compared to running widget tests.

{{% hint info %}}
You can use breakpoints in Android Studio to pause the app for debugging.
A nice thing about integration tests compared to widget tests, is that you
can actually see what the app looks like when execution is paused.
{{% /hint %}}
