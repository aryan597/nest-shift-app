import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nestshift_flutter/main.dart';

void main() {
  testWidgets('NestShiftApp renders without crashing', (WidgetTester tester) async {
    await tester.pumpWidget(const NestShiftApp());
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
