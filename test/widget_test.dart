import 'package:flutter_test/flutter_test.dart';

import 'package:week1/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const SocialNetworkApp());

    // Verify that our app bar title exists.
    // Login screen should have 'Đăng Nhập'
    expect(find.text('Đăng Nhập'), findsOneWidget);
  });
}
