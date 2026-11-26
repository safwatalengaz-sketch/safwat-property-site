import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:safwat_property_app/app.dart';
import 'package:safwat_property_app/data/ranouna_villa.dart';
import 'package:safwat_property_app/data/salam_offer.dart';
import 'package:safwat_property_app/screens/property_details_screen.dart';
import 'package:safwat_property_app/screens/privacy_screen.dart';
import 'package:safwat_property_app/screens/ranouna_villa_screen.dart';
import 'package:safwat_property_app/screens/works_screen.dart';

void main() {
  testWidgets('home shows matching property cards with contact and details', (
    tester,
  ) async {
    await tester.pumpWidget(const SafwatApp());
    await tester.pumpAndSettle();

    expect(find.text('عقار'), findsOneWidget);
    expect(find.text('العقارات المتاحة'), findsOneWidget);
    final kingFahd = find.byType(KingFahdBuildingCard);
    final salam = find.byType(SalamOfferCard);
    final ranouna = find.byType(RanounaVillaCard);
    for (final card in [kingFahd, salam, ranouna]) {
      Finder action(String label) =>
          find.descendant(of: card, matching: find.text(label));
      final browse = action('استعراض العقار');
      expect(browse, findsOneWidget);
      for (final label in ['اتصال', 'واتساب']) {
        final contact = action(label);
        expect(contact, findsOneWidget);
        expect(
          tester.getCenter(contact).dy,
          lessThan(tester.getCenter(browse).dy),
        );
      }
    }
    final buildingDetails = find.descendant(
      of: kingFahd,
      matching: find.text('استعراض العقار'),
    );
    await tester.ensureVisible(buildingDetails);
    await tester.pumpAndSettle();
    await tester.tap(buildingDetails);
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<PropertyDetailsScreen>(find.byType(PropertyDetailsScreen))
          .isBuilding,
      isTrue,
    );
    await tester.tap(find.byIcon(Icons.arrow_forward_rounded).hitTestable());
    await tester.pumpAndSettle();
    await tester.tap(find.text('الرئيسية').hitTestable());
    await tester.pumpAndSettle();
    final details = find.descendant(
      of: salam,
      matching: find.text('استعراض العقار'),
    );
    await tester.ensureVisible(details);
    await tester.pumpAndSettle();
    expect(find.text(SalamOffer.advertisingLicenseLabel), findsNothing);
    await tester.tap(details);
    await tester.pumpAndSettle();

    expect(find.byType(PropertyDetailsScreen), findsOneWidget);
  });

  testWidgets('app starts with its Arabic splash screen', (tester) async {
    await tester.pumpWidget(const SafwatApp());
    expect(find.textContaining('%'), findsOneWidget);
  });

  testWidgets('entrance card discloses the choice before the primary button', (
    tester,
  ) async {
    final choices = <bool>[];
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MeasurementWelcome(
            canChooseMeasurement: true,
            onClose: choices.add,
          ),
        ),
      ),
    );
    expect(
      find.text('لمشاهدة تفاصيل العقار، اضغط على الزر أدناه'),
      findsOneWidget,
    );
    expect(find.byType(FilledButton), findsOneWidget);
    expect(find.byType(OutlinedButton), findsNothing);
    expect(find.textContaining('توافق على قياس'), findsOneWidget);
    await tester.tap(find.text('متابعة دون قياس'));
    await tester.tap(find.text('افتح العقار'));
    expect(choices, [false, true]);
  });

  testWidgets('privacy options are reached through a dedicated page', (
    tester,
  ) async {
    await tester.pumpWidget(const SafwatApp());
    await tester.pumpAndSettle();
    expect(find.text('السماح بالقياس الإعلاني'), findsNothing);

    final link = find.text('الخصوصية والقياس');
    await tester.ensureVisible(link);
    await tester.pumpAndSettle();
    await tester.tap(link);
    await tester.pumpAndSettle();
    expect(find.text('السماح بالقياس الإعلاني'), findsOneWidget);
    expect(find.text('رفض القياس الإعلاني'), findsOneWidget);
    await tester.tap(find.byTooltip('رجوع'));
    await tester.pumpAndSettle();
    expect(find.text('رفض القياس الإعلاني'), findsNothing);
    expect(find.text('العقارات المتاحة'), findsOneWidget);
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
    final villaDetails = find.descendant(
      of: find.byType(RanounaVillaCard),
      matching: find.text('استعراض العقار'),
    );
    await tester.ensureVisible(villaDetails);
    await tester.pumpAndSettle();
    await tester.tap(villaDetails);
    await tester.pumpAndSettle();
    expect(find.byType(RanounaVillaScreen), findsOneWidget);
  });

  testWidgets('Ranouna opens directly and shows its details and full photos', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    final dispatcher = tester.binding.platformDispatcher;
    dispatcher.defaultRouteNameTestValue = '${RanounaVilla.path}/';
    addTearDown(dispatcher.clearDefaultRouteNameTestValue);

    await tester.pumpWidget(const SafwatApp());
    await tester.pumpAndSettle();
    expect(find.text(RanounaVilla.title), findsOneWidget);
    expect(find.text(RanounaVilla.price), findsOneWidget);
    expect(find.text(RanounaVilla.location), findsOneWidget);
    final scrollable = find.descendant(
      of: find.byType(CustomScrollView),
      matching: find.byType(Scrollable),
    );
    final facade = find.text('واجهة الفيلا');
    await tester.scrollUntilVisible(
      facade.hitTestable(),
      220,
      scrollable: scrollable,
    );
    await tester.tap(facade);
    await tester.pumpAndSettle();
    expect(find.text('1 / ${RanounaVilla.photos.length}'), findsOneWidget);
    await tester.tap(find.byTooltip('الصورة التالية'));
    await tester.pumpAndSettle();
    expect(find.text('2 / ${RanounaVilla.photos.length}'), findsOneWidget);
    await tester.tap(find.byTooltip('إغلاق الصور'));
    await tester.pumpAndSettle();

    final license = find.textContaining(RanounaVilla.license);
    await tester.scrollUntilVisible(license, 460, scrollable: scrollable);
    expect(license, findsOneWidget);
    expect(find.text('الملحق'), findsOneWidget);
    expect(find.textContaining('شارع 6'), findsNothing);
    expect(tester.takeException(), isNull);
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
    expect(tester.getSize(find.byType(PropertyDetailsScreen)).width, 390);
    final whatsapp = find.byTooltip('تواصل عبر واتساب');
    final phone = find.byTooltip('اتصل بنا');
    final whatsappCenter = tester.getCenter(whatsapp);
    final phoneCenter = tester.getCenter(phone);
    expect(whatsappCenter.dx, greaterThan(330));
    expect(phoneCenter.dx, whatsappCenter.dx);
    expect((whatsappCenter.dy + phoneCenter.dy) / 2, 422);
    final details = find
        .descendant(
          of: find.byType(ListView).first,
          matching: find.byType(Scrollable),
        )
        .first;
    await tester.scrollUntilVisible(
      find.text('محجوز'),
      500,
      scrollable: details,
    );
    expect(find.text('الدور الأول'), findsOneWidget);
    expect(find.text('موقع العقار'), findsNothing);
    final license = find.text(SalamOffer.advertisingLicenseLabel);
    await tester.scrollUntilVisible(license, 300, scrollable: details);
    expect(tester.getCenter(whatsapp), whatsappCenter);
    expect(tester.getCenter(phone), phoneCenter);
    expect(tester.widget<Text>(license).style?.fontSize, 12);
    expect(tester.takeException(), isNull);
  });
}
