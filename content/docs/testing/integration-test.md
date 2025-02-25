---
title: Integration test
weight: 5
---

# Integration test

{{% hint danger %}}
This page is still in its early stages.
{{% /hint %}}

Integrations tests can look very similar to widget tests.
Here is a comparison table to help set them apart.

| Description                        | Widget       | Integration                   |
| ---------------------------------- | ------------ | ----------------------------- |
| What gets tested                   | widget       | the whole app                 |
| Folder with tests                  | test/        | integration_test/             |
| Command to execute                 | flutter test | flutter test integration_test |
| Can you see the UI being rendered? | no           | yes                           |
| Execution speed                    | fast         | slow                          |

Integration tests should call
`IntegrationTestWidgetsFlutterBinding.ensureInitialized()` before executing any
tests.

Let's look at an example.
First we need an app to test.

## Screen size

```dart
tester.view.devicePixelRatio = 1;
tester.view.physicalSize = Size(412, 915);
```
