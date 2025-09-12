// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:give_app/constants/app_constants.dart';

void main() {
  testWidgets('App constants are defined', (WidgetTester tester) async {
    // Test that our app constants are properly defined
    expect(AppConstants.appName, isNotEmpty);
    expect(AppConstants.appVersion, isNotEmpty);
    expect(AppConstants.usersCollection, isNotEmpty);
    expect(AppConstants.courseGroupsCollection, isNotEmpty);
    expect(AppConstants.batchesCollection, isNotEmpty);
  });

  testWidgets('App colors are defined', (WidgetTester tester) async {
    // Test that our app colors are properly defined
    expect(AppColors.primaryColorValue, isA<int>());
    expect(AppColors.secondaryColorValue, isA<int>());
    expect(AppColors.accentColorValue, isA<int>());
  });

  testWidgets('App strings are defined', (WidgetTester tester) async {
    // Test that our app strings are properly defined
    expect(AppStrings.login, isNotEmpty);
    expect(AppStrings.register, isNotEmpty);
    expect(AppStrings.dashboard, isNotEmpty);
    expect(AppStrings.email, isNotEmpty);
    expect(AppStrings.password, isNotEmpty);
  });
}
