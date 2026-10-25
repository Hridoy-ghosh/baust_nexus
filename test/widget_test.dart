import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:baust_nexus/main.dart';

void main() {
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await Supabase.initialize(
      url: 'https://example.supabase.co',
      anonKey: 'test-anon-key',
    );
  });

  testWidgets('BAUST Nexus app starts successfully', (WidgetTester tester) async {
    await tester.pumpWidget(const BAUSTNexusApp());
    expect(find.byType(BAUSTNexusApp), findsOneWidget);
    await tester.pump(const Duration(seconds: 4));
    await tester.pump();
  });
}