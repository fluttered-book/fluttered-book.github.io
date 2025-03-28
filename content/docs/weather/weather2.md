---
title: Weather - Charts
description: Part 2 - Charts
weight: 4
---

# Weather app - Charts

![Screenshot](../images/weather_app_part2_screenshot.png)

## Introduction

[Open-Meteo](https://open-meteo.com/en/docs/) got many different variables we
can query.
It would be nice if we could plot the data in a chart.

_Here variable means a measurement or prediction that changes over time._

## Packages

The two most popular packages for making charts in Flutter are
[FL Chart](https://pub.dev/packages/fl_chart) and [Syncfusion Flutter Charts](https://pub.dev/packages/syncfusion_flutter_charts).

Picking a popular package is often a safe bet.
However "FL Chart" doesn't work well with time-series data.
And "Syncfusion Flutter Charts" has a license that makes it impractical for us.

There also used to be a 3rd popular option, [charts_flutter](https://pub.dev/packages/charts_flutter).
It was developed for use internally at Google.
But the project has been abandoned.

Luckily a community member is now maintaining a fork named
[community_charts_flutter](https://pub.dev/packages/community_charts_flutter).
So we are going with that package.

The chosen package isn't the best looking of the bunch.
But it has the simplest API.
And works really well with time series data, which is super important for our
use-case.

Here is an example, on how to use it:

```dart
typedef TimeSeriesDatum = ({DateTime domain, double measure});

final List<TimeSeriesDatum> data = [
  (domain: DateTime.parse("2024-03-09"), measure: 1),
  (domain: DateTime.parse("2024-03-10"), measure: 5),
  (domain: DateTime.parse("2024-03-11"), measure: 3),
];

class ChartsDemoScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: charts.TimeSeriesChart(
        [
            charts.Series<TimeSeriesDatum, DateTime>(
              id: 'Demo',
              domainFn: (TimeSeriesDatum datum, _) => datum.domain,
              measureFn: (TimeSeriesDatum datum, _) => datum.measure,
              data: data,
            )
        ],
        dateTimeFactory: const charts.LocalDateTimeFactory(),
        behaviors: [charts.SeriesLegend()],
      ),
    );
  }
}
```

![Simple chart example](../images/simple_chart_example.png)

Domain is the x-axis values and measure is the y-axis.

In all examples, I'm going to import the chart library like:

```dart
import 'package:community_charts_flutter/community_charts_flutter.dart' as charts;
```

The [library
prefix](https://dart.dev/language/libraries#specifying-a-library-prefix)
`charts` is used, because the library got some types that conflict with types
from other packages.

## Transform data

To make it simpler to plot the data we get from Open-Meteo, we are going to
transform/convert it into a different shape.

Here is an exempt of the data found in API response.

```json
{
  "daily_units": {
    "time": "iso8601",
    "temperature_2m_max": "°C",
    "temperature_2m_min": "°C"
  },
  "daily": {
    "time": ["2024-03-08", "2024-03-09", "2024-03-10"],
    "temperature_2m_max": [7.1, 7.0, 5.4],
    "temperature_2m_min": [0.1, -1.4, 2.4]
  }
}
```

We are going to transform it into:

```dart
 WeatherData(
  daily: [
    TimeSeriesVariable(
      name: 'temperature_2m_max',
      unit: '°C',
      values: [
        TimeSeriesDatum(domain: DateTime(2024, 03, 08), measure: 7.1),
        TimeSeriesDatum(domain: DateTime(2024, 03, 09), measure: 7.0),
        TimeSeriesDatum(domain: DateTime(2024, 03, 10), measure: 5.4),
      ],
    ),
  ],
)
```

Start by declaring the types.
Add the following to `lib/models/time_series.dart`:

```dart
/// Holds the same data as as response from Open-Meteo, but in a form that makes
/// it simpler to use in charts.
class WeatherChartData {
  /// Hourly Weather Variables
  final List<TimeSeriesVariable>? hourly;

  /// Daily Weather Variables
  final List<TimeSeriesVariable>? daily;

  WeatherChartData({this.hourly, this.daily});

  static WeatherChartData fromJson(Map<String, dynamic> json) =>
      WeatherDataConverter.convert(json);
}

/// A measure that changes over time
class TimeSeriesVariable {
  final String name;
  final String? unit;
  final List<TimeSeriesDatum> values;

  TimeSeriesVariable({required this.name, this.unit, required this.values});
}

/// A single point
class TimeSeriesDatum {
  final DateTime domain;
  final num measure;

  TimeSeriesDatum({required this.domain, required this.measure});
}
```

Here is a sketch of how we are going to convert the data.

![Sketch of data conversion](../images/weather_data_transform.drawio.png)

Not sure if that was useful at all.
Anyway, here is the code:

```dart
const _kTime = 'time';
const _kHourly = 'hourly';
const _kDaily = 'daily';
const _kUnits = 'units';

class WeatherDataConverter {
  static WeatherChartData convert(Map<String, dynamic> json) {
    return WeatherChartData(
      daily: convertGroup(json, group: _kDaily),
      hourly: convertGroup(json, group: _kHourly),
    );
  }

  static List<TimeSeriesVariable>? convertGroup(Map<String, dynamic> json,
      {required String group}) {
    if (!json.containsKey(group)) return null;

    // Find out what variables exist the group.
    final variables =
        (json[group] as Map<String, dynamic>).keys.where((key) => key != _kTime);

    return variables
        .map((variable) =>
            convertVariable(json, group: group, variable: variable)!)
        .toList();
  }

  static TimeSeriesVariable? convertVariable(Map<String, dynamic> json,
      {required String group, required String variable}) {
    if (!json.containsKey(group)) return null;

    // Find unit for variable
    final unit = json['${group}_$_kUnits']?[variable];

    // A data point is the value of variable at a specific point in time
    final values = List.generate(
      (json[group][_kTime] as List).length,
      (index) => TimeSeriesDatum(
        domain: DateTime.parse(json[group][_kTime][index]),
        measure: json[group][variable][index],
      ),
    );

    return TimeSeriesVariable(name: variable, unit: unit, values: values);
  }
}
```

Then add the familiar `fromJson` method to `WeatherChartData` class.

```dart
  static WeatherChartData fromJson(Map<String, dynamic> json) =>
      WeatherDataConverter.convert(json);
```

## Fetching data

1. Head over to [Open-Meteo](https://open-meteo.com/en/docs).
2. Select a location and time period in the top.
3. Select the variables want to have in your chart.
   - You can use both "Daily Weather Variables" and "Hourly Weather Variables".
4. Save the JSON to `assets/chart_data.json`.
5. Copy API URL.

Next, you need to update your data sources.
Add `getChartData` to `DataSource`.

```dart
abstract class DataSource {
  Future<WeeklyForecastDto> getWeeklyForecast();
  Future<WeatherChartData> getChartData();
}
```

Add overrides to the concrete classes.
In `FakeDataSource`, you add:

```dart
  @override
  Future<WeatherChartData> getChartData() async {
    final json = await rootBundle.loadString("assets/chart_data.json");
    return WeatherChartData.fromJson(jsonDecode(json));
  }
```

And in `RealDataSource`, you add:

```dart
  @override
  Future<WeatherChartData> getChartData() async {
    const apiUrl = "REPLACE THIS WITH THE URL YOU COPIED";
    final response = await http.get(Uri.parse(apiUrl));
    return WeatherChartData.fromJson(jsonDecode(response.body));
  }
```

## Adding charts

Change the provider `main.dart` to use `FakeDataSource`.

Then add `lib/chart_screen.dart` with:

```dart
class ChartScreen extends StatelessWidget {
  const ChartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<WeatherChartData>(
        future: context.read<DataSource>().getChartData(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const CircularProgressIndicator();
          final variables = snapshot.data!.daily!;
          return charts.TimeSeriesChart(
            [
              for (final variable in variables)
                charts.Series<TimeSeriesDatum, DateTime>(
                  id: '${variable.name} ${variable.unit}',
                  domainFn: (datum, _) => datum.domain,
                  measureFn: (datum, _) => datum.measure,
                  data: variable.values,
                ),
            ],
            animate: true,
            dateTimeFactory: const charts.LocalDateTimeFactory(),
            behaviors: [charts.SeriesLegend()],
          );
        },
      ),
    );
  }
}
```

This code only shows "Daily Weather Variables".
If you want to show "Hourly Weather Variables", then you just change the line:

```dart
final variables = snapshot.data!.daily!;
```

To this:

```dart
final variables = snapshot.data!.hourly!;
```

Change the `home` property of `WeatherApp` to `ChartScreen`.

```dart
class WeatherApp extends StatelessWidget {
  const WeatherApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: ChartScreen(), // <---- here
    );
  }
}
```

I've chosen the daily variables "Maximum Temperature (2 m)" and "Minimum Temperature (2 m)".
So my app looks like this.

![App with temperature chart](../images/app_with_temperature_chart.png)

## Customization

The charts package got a lot of options for customization.

**TimeSeriesChart**

| Option           | Description                                                                       |
| ---------------- | --------------------------------------------------------------------------------- |
| animate          | wether the chart will animate as it gets drawn.                                   |
| behaviors        | list of behaviors changing certain aspects of the chart (see ChartBehavior below) |
| selectionModels  | apply callbacks for when part of the graph is selected                            |
| flipVerticalAxis | flips the vertical axis                                                           |
| domainAxis       | change how domain (time) axis as shown                                            |
| defaultRenderer  | change the chart to a bar chart or something else                                 |

You can display week days by setting `domainAxis` to:

```dart
charts.DateTimeAxisSpec(
  tickFormatterSpec: charts.BasicDateTimeTickFormatterSpec(
    (datetime) => DateFormat("E").format(datetime),
  ),
)
```

A DateTime formatted [DateFormat](https://api.flutter.dev/flutter/intl/DateFormat-class.html).

**ChartBehavior**

Base class for types altering behavior of a chart.

| Type         | Description                                        | Example                            |
| ------------ | -------------------------------------------------- | ---------------------------------- |
| SeriesLegend | Show legend (id of chart series)                   | `charts.SeriesLegend()`            |
| ChartTitle   | Set a title for the chart                          | `charts.ChartTitle("Temperature")` |
| DatumLegend  | Legend (label) for each datum (point) in the chart | `charts.DatumLegend()`             |

**Series**

| Options | Description                 | Example                                                      |
| ------- | --------------------------- | ------------------------------------------------------------ |
| colorFn | changes the color of series | `(datum, index) => charts.MaterialPalette.pink.shadeDefault` |

**Colors**

A note on colors.
The charts package (for some reason) uses a different type to express a color
than the normal Dart [Color
class](https://api.flutter.dev/flutter/dart-ui/Color-class.html).

You can use `charts.ColorUtils` to convert between them.

```dart
// charts.Color -> Dart Color
Color dartColor =
    charts.ColorUtil.toDartColor(charts.Color.fromHex(code: "#FFC0CB"));

// Dart Color -> charts.Color
charts.Color chartsColor =
    charts.ColorUtil.fromDartColor(Color.fromRGBO(255, 192, 203, 1));
```

The charts don't look that great out-of-the-box with dark mode.
Here is how to fix it:

```dart
Widget build(BuildContext context) {
  final axisColor = charts.MaterialPalette.gray.shadeDefault;
  return charts.TimeSeriesChart(
    [ /* Your time series data here */ ],

    /// Assign a custom style for the domain axis.
    domainAxis: charts.DateTimeAxisSpec(
      renderSpec: charts.SmallTickRendererSpec(
        // Tick and Label styling here.
        labelStyle: charts.TextStyleSpec(color: axisColor),
        // Change the line colors to match text color.
        lineStyle: charts.LineStyleSpec(color: axisColor),
      ),
    ),

    /// Assign a custom style for the measure axis.
    primaryMeasureAxis: charts.NumericAxisSpec(
      renderSpec: charts.GridlineRendererSpec(
        // Tick and Label styling here.
        labelStyle: charts.TextStyleSpec(color: axisColor),
        // Change the line colors to match text color.
        lineStyle: charts.LineStyleSpec(color: axisColor),
      ),
    ),
  );
}
```

See [API documentation](https://pub.dev/documentation/community_charts_flutter/latest/community_charts_flutter/community_charts_flutter-library.html).

## Example

**[Chart examples gallery](https://rpede.github.io/charts_flutter_examples/)**

[More, but slightly outdated examples](https://juliansteenbakker.github.io/community_charts/flutter/gallery.html)

### Challenge

### Introduction

In this tutorial we replaced the entire app with just a chart.

The basics of this challenges is for you to find a way to integrate charts into
the weather app while still maintaining the weekly forecast.

This challenge gives you a lot of freedom to explore and in the end you will end
up with your own unique customized weather app.

### Target audience

Find your target audience.
Describe a persona for your weather app.
What do they need in a app like this.
Then make the app.

Do you do any activities that are weather dependent?
If so, here is your change make the perfect app to keep track of the weather
metrics that are important to you.
Or, maybe you have a friend or family member that loves hiking, surfing or some
other outdoor activity.

### Hints

Box constraint widgets can't be used inside directly inside a Sliver.
Most Flutter widgets you have working with this far are box constraint.

You can adapt a widget to work inside a Sliver by wrapping it in either a
[SliverToBoxAdapter](https://api.flutter.dev/flutter/widgets/SliverToBoxAdapter-class.html)
and
[SliverFillRemaining](https://api.flutter.dev/flutter/widgets/SliverFillRemaining-class.html).

