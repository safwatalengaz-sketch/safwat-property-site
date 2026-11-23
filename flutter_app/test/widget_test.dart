import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:safwat_property_app/app.dart';
import 'package:safwat_property_app/data/salam_offer.dart';
import 'package:safwat_property_app/screens/property_details_screen.dart';
import 'package:safwat_property_app/screens/works_screen.dart';

void main() {
  testWidgets('home links to MB:246 from the property card', (tester) async {
    await tester.pumpWidget(const SafwatApp());
    await tester.pumpAndSettle();

    expect(find.text('عقار'), findsOneWidget);
    final offer = find.byType(SalamOfferCard);
    await tester.ensureVisible(offer);
    await tester.pumpAndSettle();
    await tester.tap(find.text(SalamOffer.title).hitTestable());
    await tester.pumpAndSettle();

    expect(find.byType(PropertyDetailsScreen), findsOneWidget);
  });

  testWidgets('app starts with its Arabic splash screen', (tester) async {
    await tester.pumpWidget(const SafwatApp());
    expect(find.textContaining('%'), findsOneWidget);
  });

  testWidgets('legacy ad link still leads to home and the property catalog', (
    tester,
  ) async {
    final dispatcher = tester.binding.platformDispatcher;
    dispatcher.defaultRouteNameTestValue = '/apartments/?gclid=test-click';
    addTearDown(dispatcher.clearDefaultRouteNameTestValue);

    await tester.pumpWidget(const SafwatApp());
    await tester.pumpAndSettle();

    expect(find.text('الشقق المعروضة للبيع'), findsOneWidget);
    expect(find.text('تفاصيل الشقة والصور'), findsOneWidget);
    expect(find.text('فتح نسخة الموقع'), findsNothing);

    await tester.tap(find.text('الرئيسية').hitTestable());
    await tester.pumpAndSettle();
    expect(find.byType(SalamOfferCard), findsOneWidget);

    await tester.tap(find.text('عقار').hitTestable());
    await tester.pumpAndSettle();
    expect(find.byType(WorksScreen), findsOneWidget);
    expect(find.byType(SalamOfferCard), findsOneWidget);
  });

  testWidgets('MB:246 opens directly with its photos and reserved floor', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    final dispatcher = tester.binding.platformDispatcher;
    dispatcher.defaultRouteNameTestValue = '${SalamOffer.path}/';
    addTearDown(dispatcher.clearDefaultRouteNameTestValue);

    await tester.pumpWidget(const SafwatApp());
    await tester.runAsync(() async {
      await precacheImage(
        AssetImage(SalamOffer.photos.first),
        tester.element(find.byType(PropertyDetailsScreen)),
      );
    });
    await tester.pumpAndSettle();

    expect(find.byTooltip('مشاركة'), findsNothing);
    await tester.scrollUntilVisible(
      find.text('محجوز'),
      500,
      scrollable: find
          .descendant(
            of: find.byType(ListView).first,
            matching: find.byType(Scrollable),
          )
          .first,
    );
    expect(find.text('الدور الأول'), findsOneWidget);
    expect(find.text('موقع العقار'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
