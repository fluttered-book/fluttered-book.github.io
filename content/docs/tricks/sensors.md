---
title: Sensors
weight: 14
---

# Sensors

## Introduction

Smartphones got a bunch of different sensors build in to it.
If you think about it, it's pretty amazing the amount of things that is crammed
into such a small device.

### What kind of sensors, and what are they used for?

Besides the obvious like camera, microphone and fingerprint.
There is also a whole slew of other sensors that you might not think about.

#### Light

Your phone has a light sensor that is used to automatically adjust the screen
brightness.

You might occasionally notice if you accidentally cover the sensor while being
it a lit room that it will turn down the brightness.

#### Accelerometer and gyroscope

There is an accelerometer and gyroscope that are used to determine orientation,
so it can automatically rotate the screen layout when you flip the phone.
They are also used for step counting.

#### Magnetometer

It has a magnetometer, so it can show the direction you are facing on maps.

#### Location (A-GPS)

Speaking of maps.
There is A-GPS to determine your location.
The A stands for Assisted.
Which means that it uses cell towers / mobile network to assist the
triangulation of location.

In addition, it can also use Wi-Fi signal strength to further assist in
determining position.
So, Apple and Google each have a database with the location of each Wi-Fi
access point in world.
Peoples phones send information about access points in its proximity to keep
the database up to date.
This all happens in the background on most devices.
Laptops and other devices that don't have GPS can also use this information to
determine its approximate location.

## Using sensors

Here we will explore how to use the sensors.

Support for the various sensors can be added to Flutter project through plugins
found on [pub.dev](https://pub.dev/).

### Light

This only works on Android.

Start by adding the [light](https://pub.dev/packages/light) plugin to your
project.

```sh
flutter pub add light
```

In your code, instantiate `Light` object then you can use `lightSensorStream`
to get a stream of values from the sensor.

```dart
import 'package:light/light.dart';

final light = Light();
light.lightSensorStream.forEach((value) => print(value));
```

[Example](https://github.com/fluttered-book/sensors/blob/main/lib/light/light_page.dart)

The example uses the light sensor to fade between two versions of an images
based on the level of ambient light.

<video controls>
  <source src="../images/light.mp4" type="video/mp4">
</video>

### Accelerometer, gyroscope and magnetometer

They can all be accessed using the
[sensors_plus](https://pub.dev/packages/sensors_plus) plugin.

It works both on iOS and Android.

{{% hint error %}}
On iOS you need to request access motions sensors through app metadata,
otherwise the app will crash when attempting to read sensor values.
Open `ios/Runner/Info.plist` and add the following:

```xml
<key>NSMotionUsageDescription</key>
<string>This app requires access to the barometer to provide altitude information.</string>
```

{{% /hint %}}

The `sensors_plus` plugin expose the following functions which can be used to
read values from the sensors.

- `accelerometerEventStream()`
  - Returns a broadcast stream of events from the device accelerometer at the
    given sampling frequency.
- `barometerEventStream()`
  - Returns a broadcast stream of events from the device barometer at the given
    sampling frequency.
- `gyroscopeEventStream()`
  - Returns a broadcast stream of events from the device gyroscope at the given
    sampling frequency.
- `magnetometerEventStream()`
  - Returns a broadcast stream of events from the device magnetometer at the
    given sampling frequency.
- `userAccelerometerEventStream()`
  - Returns a broadcast stream of events from the device accelerometer with
    gravity removed at the given sampling frequency.

That each (except barometer) provides a stream of readings with values for X, Y
and Z axis.

[Example](https://github.com/fluttered-book/sensors/blob/main/lib/sensors/chart/ui/sensors_chart_page.dart)

In the example readings of each sensor is shown on a chart.

<video controls>
  <source src="../images/sensors.mp4" type="video/mp4">
</video>

Some apps use the sensors to provide cool effects such as what can be achieved
using [flutter_tilt](https://pub.dev/packages/flutter_tilt) package.

```sh
flutter pub add flutter_tilt
```

{{% hint info %}}
Using `flutter_tilt` without accessing sensors directly doesn't require you to
add a dependency to `sensors_plus`, since `flutter_tilt` already depends on it.
{{% /hint %}}

Here is an example that uses the package to create a parallax effect when you
move your phone.

[Example](https://github.com/fluttered-book/sensors/blob/main/lib/tilt/tilt_page.dart)

### Location

There are two popular plugins that can be used to access location services.
There is [location](https://pub.dev/packages/location) and
[geolocator](https://pub.dev/packages/geolocator).
I'm using geolocator.

It works on iOS, Android, macOS, web and Windows.

There is a bit of platform specific setup to use it though.

{{% tabs "geolocator-platform" %}}
{{% tab Android %}}
In `android/app/build.gradle` you need to set `compileSdkVersion` to 34:

```gradle
android {
  compileSdkVersion 34

  ...
}
```

Then you need to add following permission to `AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
```

{{% /tab %}}

{{% tab iOS %}}

Add the following to `ios/Runner/Info.plist`:

```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>This app needs access to location when open.</string>
```

{{% /tab %}}
{{% /tabs %}}

To access location service it both needs to be enabled on the phone, and it
needs permission from the user.

```dart
if (!await Geolocator.isLocationServiceEnabled()) {
  throw Exception("Location disabled");
}

var permission = await Geolocator.checkPermission();
if (permission == LocationPermission.denied) {
  permission = await Geolocator.requestPermission();
  if (permission == LocationPermission.denied ||
      permission == LocationPermission.deniedForever) {
    throw Exception("Location denied");
  }
}
```

You can then use `Geolocator` to:

- `getCurrentPosition()`
  - Returns the current position.
- `getCurrentPosition()`
  - Returns the current position.
- `getLastKnownPosition()`
  - Returns the last known position stored on the users device.

It also has a convenient `distanceBetween()` method to calculate the distance
between the supplied coordinates in meters.

- [Example Cubit](https://github.com/fluttered-book/sensors/blob/main/lib/location/logic/location_cubit.dart)
- [Example widget](https://github.com/fluttered-book/sensors/blob/main/lib/location/ui/location_page.dart)

Geolocator can obviously be used to show where the user is located on a map.
Here I'm using [flutter_map] packages, since it doesn't require API-keys.

- [Example map](https://github.com/fluttered-book/sensors/blob/main/lib/location/ui/map_page.dart)

The examples use `flutter_map_location_marker` to add a marker for the current
location.
It also indicates the direction like on Google Maps.
