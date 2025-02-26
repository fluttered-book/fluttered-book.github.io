---
title: Weather - Location
description: Part 3 - Location
weight: 5
---

# Weather app - Location

## Introduction

Here we will address a major flaw that our weather app have had up until now.
That is that the location is hardcoded.

## Location service

It would be pretty nice if the app just knew where you are located and shows
weather information based on that.

The answer is of cause to use the devices location service.

### Plugin

There are two popular plugins that allows you to take advantage of the mobiles
location service.

- [location](https://pub.dev/packages/location)
- [geolocator](https://pub.dev/packages/geolocator)

**Geolocator** got most likes but the setup seems a bit more complicated than the
**location** plugin.
So we are going with **location**.

Add the package:

```sh
flutter pub add location
```

### Permissions

#### Android

For Android, edit `android/app/src/main/AndroidManifest.xml` so it contains:

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">

    <!-- Location permissions-->
    <uses-permission android:name="android.permission.FOREGROUND_SERVICE" />
    <uses-permission android:name="android.permission.ACCESS_BACKGROUND_LOCATION"/>

    <!-- Network permissions-->
    <uses-permission android:name="android.permission.INTERNET" />
    <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
```

You should already have the network permissions from previously.
Stating network permissions is only really necessary when building a release
APK (Android Package).

You also need to update the minimum SDK version, as is common for many plugins.
Edit `android/app/build.gradle` to include:

```gradle
android {
    // ...
    defaultConfig {
      minSdkVersion 21
      // ...
    }
}
```

I was getting this error:

```
┌─ Flutter Fix ──────────────────────────────────────────────────────────────────────────────┐
│ [!] Your project requires a newer version of the Kotlin Gradle plugin.                     │
│ Find the latest version on https://kotlinlang.org/docs/releases.html#release-details, then │
│ update                                                                                     │
│ /home/rpe/AwesomeApps/weather/android/build.gradle:                                        │
│ ext.kotlin_version = '<latest-version>'                                                    │
└────────────────────────────────────────────────────────────────────────────────────────────┘
Error: Gradle task assembleDebug failed with exit code 1
```

Which I fixed by changing `android/settings.gradle`.

```gradle
-    id "org.jetbrains.kotlin.android" version "1.7.10" apply false
+    id "org.jetbrains.kotlin.android" version "1.9.23" apply false
```

Btw, you can change the location in the emulator by clicking on the "..." button
next to the emulator screen.

![Android emulator location](../images/android_emulator_location.png)

#### iOS

For iPhones, add the following lines to `ios/Runner/Info.plist`, inside the
plist->dict tag:

```plist
 <key>NSLocationWhenInUseUsageDescription</key>
 <string>Give accurate weather info based on you current location.</string>
```

If you click "Open iOS/macOS module in Xcode" then the Runner/Info file should look like this:

![Location permission in Xcode](../images/ios_location_permission.png)

_Note: for iOS you have to give a description of why your app needs permission.
They will likely reject it in the App Store if they don't find the reason to be
valid._

If your app looks stuck while attempting to retrieve location in the Simulator, you can fix it by changing the location.

![Change iOS Simulator location](../images/ios_simulator_location.png)

#### Get location

If you had trouble with the above, you might want to check the [docs for
location](https://docs.page/Lyokone/flutterlocation/getting-started).

Once the setup is done, then you can simply get the current location like this:

Change your `RealDataSource` to include:

```dart
class RealDataSource extends DataSource {
  @override
  Future<WeeklyForecastDto> getWeeklyForecast() async {
    final location = await Location.instance.getLocation();
    final apiUrl =
        'https://api.open-meteo.com/v1/forecast?latitude=${location.latitude}&longitude=${location.longitude}&daily=weather_code,temperature_2m_max,temperature_2m_min&wind_speed_unit=ms&timezone=Europe%2FBerlin';
    final response = await http.get(Uri.parse(apiUrl));
    return WeeklyForecastDto.fromJson(jsonDecode(response.body));
  }
  //...
}
```

**Important** make sure you are importing `Location` from
`'package:location/location.dart'`.

_Notice: `apiUrl` can no longer be final.
That is because we are now using string interpolation to construct the string
using values from variables._

Make sure your are providing `RealDataSource` in `lib/main.dart`.

First time you try the app after adding `Location.instance.getLocation()`, you
should see a dialog like this:

![Android location permission dialog](../images/android_location_permission_dialog.png)
![iOS location permission dialog](../images/ios_location_permission_dialog.png)

_Note: if you want a permission dialog to reappear, you can just remove the app
from the device and run it again._

## Query parameters

The API URL looks a bit unmanageable.
Don't you think?

```dart
final apiUrl =
    'https://api.open-meteo.com/v1/forecast?latitude=${location.latitude}&longitude=${location.longitude}&daily=weather_code,temperature_2m_max,temperature_2m_min&wind_speed_unit=ms&timezone=Europe%2FBerlin';
```

Let's clean it up a bit.

```dart
final apiUrl = Uri.https("api.open-meteo.com", '/v1/forecast', {
    'latitude': '${location.latitude}',
    'longitude': '${location.longitude}',
    'daily': ['weather_code', 'temperature_2m_max', 'temperature_2m_min'],
    'wind_speed_unit': 'ms',
    'timezone': 'Europe/Berlin',
});
```

Specifying parameters this way makes it a lot easier visually inspect.
It also makes it easier to construct programmatically.

If you add a breakpoint or print `apiUrl` you will see that it is exactly the
same as what we had before.

_Note: 3rd parameter to `Uri.https` is a `Map` where the values can either be `String`
or `Iterable<String>` (a List is an Iterable).
Meaning we need to convert the double for latitude and longitude to String_

## Refresh indicator

It is good practice to always give the user some sort of indication on what the
app is doing.

To make an indicator for when the app is frefreshing its data.
Simply wrap `CustomScrollView` with a
[RefreshIndicator](https://api.flutter.dev/flutter/material/RefreshIndicator-class.html)
and use its `onRefresh` callback instead of the `onStretchTrigger` callback in
`SliverAppBar`.

## Closing thought

That's it.
Now the app shows the forecast based on users location.

🥂 🥳

You can use a StreamController and StreamBuilder if you want to refresh the
chart when user pulls down, just like last lesson.

## Challenge

Finish up your awesome weather app.

### Error handling

There will always going to be some users that find stupid ways to break your
app.
Like tapping "Don't allow" to the location permission dialog.

Maybe you should show slightly more helpful message then?

### Navigation hint

You will likely end up with several screens in your app.
So you need a to navigate between them.

See the [Navigation page](../interactivity/navigation) for a refresher.

Maybe you need a
[Drawer](https://api.flutter.dev/flutter/material/Drawer-class.html) or a
[NavigationBar](https://api.flutter.dev/flutter/material/NavigationBar-class.html)?

