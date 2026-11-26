import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

import '../app.dart';
import '../data/property_data.dart';
import '../data/ranouna_villa.dart';
import 'app_shell.dart';
import 'contact_screen.dart';
import 'privacy_screen.dart';
import 'property_details_screen.dart';

class RanounaVillaScreen extends StatelessWidget {
  const RanounaVillaScreen({super.key});

  void _showPhoto(BuildContext context, int index) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => PhotoViewer(
          startIndex: index,
          photos: [
            for (final (file, _) in RanounaVilla.photos)
              '${RanounaVilla.images}/$file.webp',
          ],
          showNavigation: true,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      leading: IconButton(
        tooltip: 'العودة إلى العقارات',
        icon: const BackButtonIcon(),
        onPressed: () => context.go(AppSection.works.path),
      ),
      title: const Text('صفوة الإنجاز العقارية'),
    ),
    body: LayoutBuilder(
      builder: (context, viewport) {
        final wide = viewport.maxWidth >= 720;
        final horizontal = wide ? 28.0 : 18.0;
        final sectionPadding = EdgeInsets.fromLTRB(
          horizontal,
          0,
          horizontal,
          18,
        );
        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 920),
            child: CustomScrollView(
              cacheExtent: 100,
              slivers: [
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(horizontal, 20, horizontal, 16),
                  sliver: SliverToBoxAdapter(
                    child: _VillaIntro(
                      wide: wide,
                      onShowFacade: () => _showPhoto(context, 0),
                    ),
                  ),
                ),
                SliverPadding(
                  padding: sectionPadding,
                  sliver: const SliverToBoxAdapter(child: _VillaDetails()),
                ),
                SliverPadding(
                  padding: sectionPadding.copyWith(bottom: 10),
                  sliver: const SliverToBoxAdapter(
                    child: SectionTitle('صور الفيلا'),
                  ),
                ),
                SliverPadding(
                  padding: sectionPadding,
                  sliver: SliverGrid.builder(
                    itemCount: RanounaVilla.photos.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: wide ? 4 : 2,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: .85,
                    ),
                    itemBuilder: (context, index) {
                      final (file, title) = RanounaVilla.photos[index];
                      return Material(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        clipBehavior: Clip.antiAlias,
                        child: InkWell(
                          onTap: () => _showPhoto(context, index),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Expanded(
                                child: Image.asset(
                                  '${RanounaVilla.images}/$file-thumb.webp',
                                  fit: BoxFit.cover,
                                  excludeFromSemantics: true,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 7,
                                  horizontal: 8,
                                ),
                                child: Text(title, textAlign: TextAlign.center),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                SliverPadding(
                  padding: sectionPadding,
                  sliver: SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SectionTitle('جولة فيديو داخل الفيلا'),
                        const SizedBox(height: 6),
                        Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 395),
                            child: const PropertyVideo(
                              clips: [
                                ('جولة فيلا الرانوناء', RanounaVilla.tour),
                              ],
                              poster: RanounaVilla.poster,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverPadding(
                  padding: sectionPadding.copyWith(bottom: wide ? 32 : 118),
                  sliver: const SliverToBoxAdapter(child: _VillaFloors()),
                ),
              ],
            ),
          ),
        );
      },
    ),
  );
}

class _VillaIntro extends StatelessWidget {
  const _VillaIntro({required this.wide, required this.onShowFacade});

  final bool wide;
  final VoidCallback onShowFacade;

  @override
  Widget build(BuildContext context) {
    final facade = Material(
      borderRadius: BorderRadius.circular(18),
      clipBehavior: Clip.antiAlias,
      color: AppColors.line,
      child: InkWell(
        onTap: onShowFacade,
        child: AspectRatio(
          aspectRatio: 16 / 11,
          child: Image.asset(
            RanounaVilla.cover,
            fit: BoxFit.cover,
            semanticLabel: 'واجهة فيلا الرانوناء',
          ),
        ),
      ),
    );
    final summary = AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            RanounaVilla.title,
            style: Theme.of(context).textTheme.headlineMedium
                ?.copyWith(color: AppColors.navy),
          ),
          const SizedBox(height: 6),
          const LocationLine(text: RanounaVilla.location),
          const SizedBox(height: 8),
          Text(
            RanounaVilla.price,
            style: Theme.of(context).textTheme.titleLarge
                ?.copyWith(color: AppColors.navy),
          ),
          const SizedBox(height: 12),
          const _VillaContact(),
        ],
      ),
    );
    return wide
        ? Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(child: facade),
              const SizedBox(width: 16),
              Expanded(child: summary),
            ],
          )
        : Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [facade, const SizedBox(height: 12), summary],
          );
  }
}

class _VillaDetails extends StatelessWidget {
  const _VillaDetails();

  static const facts = <(String, String)>[
    ('مساحة الأرض', RanounaVilla.landArea),
    ('مساحة البناء', RanounaVilla.builtArea),
    ('العمر التقريبي', '٣ سنوات'),
    ('الواجهة', 'شرقية'),
    ('المصعد', 'مركب وجاهز'),
    ('التكييف', '١٣ مكيف سبليت جديدًا'),
  ];

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      const SectionTitle('مواصفات الفيلا'),
      const SizedBox(height: 10),
      LayoutBuilder(
        builder: (context, constraints) {
          final columns = constraints.maxWidth >= 580 ? 3 : 2;
          final width = (constraints.maxWidth - 10 * (columns - 1)) / columns;
          return Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              for (final (label, value) in facts)
                SizedBox(
                  width: width,
                  child: AppCard(
                    padding: const EdgeInsets.all(11),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          label,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        Text(
                          value,
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(color: AppColors.navy),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          );
        },
      ),
      const SizedBox(height: 10),
      const AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('مواقف واسعة جدًا، بحسب وصف المالك.'),
            Text('أرضيات باركيه وورق جدران في كامل الفيلا.'),
          ],
        ),
      ),
    ],
  );
}

class _VillaFloors extends StatelessWidget {
  const _VillaFloors();

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      const SectionTitle('تفاصيل الأدوار'),
      const SizedBox(height: 10),
      for (final (floor, description) in RanounaVilla.floors) ...[
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(floor, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 4),
              Text(description),
            ],
          ),
        ),
        const SizedBox(height: 10),
      ],
      const AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('ترخيص الإعلان العقاري ${RanounaVilla.license}'),
            SizedBox(height: 12),
            _VillaContact(),
          ],
        ),
      ),
      const PrivacyLink(),
    ],
  );
}

class _VillaContact extends StatelessWidget {
  const _VillaContact();

  @override
  Widget build(BuildContext context) => Wrap(
    spacing: 8,
    runSpacing: 8,
    children: [
      FilledButton.icon(
        label: const Text('واتساب'),
        icon: const FaIcon(FontAwesomeIcons.whatsapp, size: 18),
        style: FilledButton.styleFrom(
          backgroundColor: const Color(0xFF087648),
          foregroundColor: Colors.white,
          minimumSize: const Size(0, 48),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: () =>
            ContactScreen.whatsapp(context, message: RanounaVilla.inquiry),
      ),
      AppActionButton(
        label: 'اتصال',
        icon: Icons.call_rounded,
        onPressed: () => ContactScreen.call(context),
      ),
    ],
  );
}
