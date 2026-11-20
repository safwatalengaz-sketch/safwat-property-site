import 'package:flutter_test/flutter_test.dart';
import 'package:safwat_property_app/app.dart';

void main() {
  testWidgets('app starts with its Arabic splash screen', (tester) async {
    await tester.pumpWidget(const SafwatApp());
    expect(find.textContaining('%'), findsOneWidget);
  });

  testWidgets('legacy ad link opens its Flutter screen with the query intact', (
    tester,
  ) async {
    final dispatcher = tester.binding.platformDispatcher;
    dispatcher.defaultRouteNameTestValue = '/apartments/?gclid=test-click';
    addTearDown(dispatcher.clearDefaultRouteNameTestValue);

    await tester.pumpWidget(const SafwatApp());
    await tester.pump();

    expect(find.text('الشقق المعروضة للبيع'), findsOneWidget);
    expect(find.text('تفاصيل الشقة والصور'), findsOneWidget);
    expect(find.text('فتح نسخة الموقع'), findsNothing);
  });
}
