// Basic smoke test for the iMama app.
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:imama/main.dart';
import 'package:imama/state/theme_controller.dart';

void main() {
  testWidgets('App builds without crashing', (WidgetTester tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => ThemeController(),
        child: const IMamaApp(),
      ),
    );
    // Splash screen should be visible immediately after the first frame.
    expect(find.text('iMama'), findsOneWidget);
  });
}
