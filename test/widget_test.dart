import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:chitt/main.dart';
import 'package:chitt/screens/splash_screen.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  testWidgets('App starts with SplashScreen', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());
    await tester.pump(); // Pump a frame

    // Verify basic app structure
    expect(find.byType(MaterialApp), findsOneWidget);

    // Debug print to see what's happening if it fails here
    debugPrint('Pumped MyApp');

    // Verify SplashScreen is displayed
    expect(find.byType(SplashScreen), findsOneWidget);
    expect(find.text('Chitti Manager'), findsOneWidget);
  });
}
