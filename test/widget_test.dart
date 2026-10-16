import 'package:flutter_test/flutter_test.dart';
import 'package:eled/main.dart';

void main() {
  testWidgets('First launch renders onboarding before starting a lesson', (tester) async {
    await tester.pumpWidget(const EledApp(needsOnboarding: true));
    expect(find.text('ELED'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
