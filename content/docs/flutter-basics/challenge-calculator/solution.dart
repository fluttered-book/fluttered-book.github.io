import 'package:flutter/material.dart';

typedef ButtonDef = (String, void Function()?);

void main() {
  runApp(const CalculatorApp());
}

class CalculatorApp extends StatelessWidget {
  const CalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      darkTheme: ThemeData.from(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.grey,
          brightness: Brightness.dark,
        ),
      ),
      themeMode: ThemeMode.dark,
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Calculator'),
          centerTitle: true,
        ),
        body: CalculatorBody(),
      ),
    );
  }
}

class CalculatorBody extends StatelessWidget {
  static const buttons = [
    ["C", "⌫", "%", '÷'],
    ['7', '8', '9', '*'],
    ['4', '5', '6', '-'],
    ['1', '2', '3', '+'],
    ['0', '.', '', "="],
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Flexible(
          flex: 2,
          child: CalculatorDisplay(equation: "1024 / 8", result: "128"),
        ),
        for (final (rowIndex, row) in buttons.indexed)
          Flexible(
            flex: 1,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final (colIndex, btn) in row.indexed)
                  Expanded(
                    flex: 1,
                    child: CalculatorButton(btn,
                        rowIndex: rowIndex, colIndex: colIndex),
                  ),
              ],
            ),
          )
      ],
    );
  }
}

class CalculatorDisplay extends StatelessWidget {
  const CalculatorDisplay({required this.equation, required this.result});

  final String equation;
  final String result;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: Padding(
        padding: EdgeInsets.all(32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Text(
              equation,
              style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
            ),
            Text(
              result,
              style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

class CalculatorButton extends StatelessWidget {
  const CalculatorButton(this.text,
      {required this.rowIndex, required this.colIndex});

  final String text;
  final int rowIndex;
  final int colIndex;

  @override
  Widget build(BuildContext context) {
    if (text.trim().isEmpty) return const SizedBox();
    TextStyle style;
    if (colIndex == 3) {
      style = TextStyle(fontSize: 36, color: Colors.lightBlueAccent);
    } else if (rowIndex == 0) {
      style = TextStyle(fontSize: 24, color: Colors.grey);
    } else {
      style = TextStyle(fontSize: 24, color: Colors.white);
    }
    return TextButton(child: Text(text, style: style), onPressed: () {});
  }
}
