import 'package:flutter_test/flutter_test.dart';
import 'package:baust_nexus/main.dart';

void main() {
  testWidgets('BAUST Nexus app starts successfully', (WidgetTester tester) async {
    await tester.pumpWidget(const BAUSTNexusApp());
    expect(find.byType(BAUSTNexusApp), findsOneWidget);
  });
}