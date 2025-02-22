import 'package:calculator_gui/main.dart';
import 'package:calculator_gui/widgets/calculator_display.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Enter a number', (WidgetTester tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = Size(412, 915);
    // Build our app and trigger a frame.
    await tester.pumpWidget(CalculatorApp());

    await tester.tapKey('5');
    await tester.pump();
    expect(find.inputText().data, equals('5'));
    await tester.tapKey('↲');
    await tester.pump();

    expect(find.stackText().data, equals('5.0'));
    expect(find.inputText().data, equals(''));
  });
}

extension on CommonFinders {
  Text inputText() {
    return find
        .descendant(
          of: find.byType(CalculatorDisplay),
          matching: find.byKey(
            ValueKey('input'),
          ),
        )
        .evaluate()
        .single
        .widget as Text;
  }

  Text stackText() {
    return find
        .descendant(
          of: find.byType(CalculatorDisplay),
          matching: find.byKey(
            ValueKey('stack'),
          ),
        )
        .evaluate()
        .single
        .widget as Text;
  }
}

extension on WidgetTester {
  Future<void> tapKey(String key) async {
    await tap(find.byKey(Key(key)));
  }
}
