---
title: iPhone
---

# Setup for iPhone

If you have an iPhone and would like to be able to build your Flutter projects
for it, then there is a bit of extra setup you need to do.

If you don't have an iPhone then skip to [here](../android_studio.md).

{{< hint info >}}
You need to use macOS to develop apps on iPhone.
This is a restriction imposed by Apple.
{{< /hint >}}

To build for iPhone you will need Xcode which can be found in App Store.
So go ahead and install it!

To make plugins work for iPhone you need to have
[CocoaPods](https://cocoapods.org/) installed.
But before you can install it you will need a couple of other things.

## Homebrew

Install [Homebrew](https://brew.sh/) if you don't have it already.
If you are unsure, you can check by entering `brew` in Terminal.

```sh
# To install Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

You can use brew to install Ruby which is required by CocoaPods.

```sh
brew install ruby
```

Then add a couple of more environment variables to `.zshrc`.

```sh
export PATH="/opt/homebrew/opt/ruby/bin:$PATH"
export LDFLAGS="-L/opt/homebrew/opt/ruby/lib"
export CPPFLAGS="-I/opt/homebrew/opt/ruby/include"
```

## CocoaPods

Finally, install CocoaPods with:

```sh
brew install cocoapods
brew link cocoapods
```

Hopefully you should see a checkmark for cocoapods now when running `flutter doctor` .

Then to set up Xcode.

```sh
sudo sh -c 'xcode-select -s /Applications/Xcode.app/Contents/Developer && xcodebuild -runFirstLaunch'
xcodebuild -downloadPlatform iOS
sudo xcodebuild -license
```

## Developer mode

Next, you need to pair your phone.
Connect your iPhone to your Mac with a cable.

{{< hint info >}}
The command below will create the project in a subfolder of your current
working directory.
If you want to store your projects in a different folder you should navigate to
it before executing the command.
{{< /hint >}}

Create a new Flutter project by running:

```sh
flutter create ios_test --platforms=ios
```

You will need to open the project in Xcode.
You can either do it by opening op Xcode, then select "File"->"Open Folder" and
browse to the location.
Or from Terminal using:

```sh
open ios_test/ios/Runner.xcworkspace
```

![](images/mac_xcode_device.png)

It unlocks a new "Developer Mode" menu on you iPhone, under
"Settings"->"Privacy & Security".
Enable it and restart.

![](images/ios_developer_mode1.jpeg)
![](images/ios_developer_mode2.jpeg)

After restart.
You should see a dialog like shown.
Just select "Turn On".

![](images/ios_developer_mode3.jpeg)

## Signing

Go to **Xcode**->"Settings...".
Then under "Accounts" tab, click the + and select "Apple ID".
Enter your Apple ID credentials.

![](images/mac_xcode_accounts.png)

Close the settings window.

1. Click on the Play icon in the top bar.
2. click "Runner" in the left panel.
3. Under "Signing & Capabilities" tab, click on the "Team" dropdown and select "{Your name} (Personal Team)".

![](images/mac_xcode_runner.png)

In "Bundle Identifier" field you must invent a unique name for you app.

![](images/mac_xcode_signing.png)

Before you can run the app, you need to find the device id.

```sh
flutter devices
```

It should list all devices that Flutter is able to run the project on.
Copy the **id** field for your iPhone.
Then do:

```sh
cd ios_test
flutter run -d < your phones id >
```

First time you run a project you will get the following message.

![](images/mac_xcode_first_run.png)

Do as the messages says.
It should look like the screenshots below.

![](images/ios_vpn1.jpeg)
![](images/ios_vpn2.jpeg)

Close Xcode and run the project again with:

```sh
flutter run -d < your phones id >
```

If everything went well, you should see the following:

![](images/ios_flutter_demo.jpeg)

Here are a couple of links that could help if you get stuck.

- [Start building Flutter iOS apps on macOS](https://docs.flutter.dev/get-started/install/macos/mobile-ios?tab=physical)
- [Enabling Developer Mode on a device](https://developer.apple.com/documentation/xcode/enabling-developer-mode-on-a-device)

---

Next you will install an IDE for Flutter, namely Android Studio.
Don't let the name fool you, as it is great for Flutter development no matter the platform.

# [Continue](../android-studio)
