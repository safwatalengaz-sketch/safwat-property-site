import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

import '../app.dart';
import '../data/property_data.dart';
import '../data/ranouna_villa.dart';
import '../data/salam_offer.dart';
import 'contact_screen.dart';

class WorksScreen extends StatelessWidget {
  const WorksScreen({super.key, required this.onOpenProperty});
  final VoidCallback onOpenProperty;
  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    padding: const EdgeInsets.fromLTRB(18, 24, 18, 28),
    child: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Eyebrow('مشاريع مختارة'),
            const SizedBox(height: 5),
            Text(
              'عقار',
              style: Theme.of(context).textTheme.headlineMedium
                  ?.copyWith(color: AppColors.navy),
            ),
            const SizedBox(height: 4),
            const Text(
              'فرص عقارية في المدينة المنورة',
              style: TextStyle(color: AppColors.muted),
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final (label, path) in const [
                  ('الشقق', '/apartments'),
                  ('العمائر', '/buildings'),
                  ('العقارات', '/properties'),
                  ('الجولات', '/tours'),
                ])
                  OutlinedButton(
                    onPressed: () => context.go(path),
                    child: Text(label),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            const RanounaVillaCard(),
            const SizedBox(height: 18),
            _ListingCard(
              cover: Image.asset(
                'assets/images/banners/works-banner.png',
                fit: BoxFit.contain,
              ),
              title: PropertyData.title,
              subtitle: const LocationLine(text: PropertyData.location),
              facts: const [PropertyData.area, '٣ غرف نوم', 'تشطيب سوبر لوكس'],
              onTap: onOpenProperty,
            ),
            const SizedBox(height: 18),
            const SalamOfferCard(),
            const SizedBox(height: 18),
            const AppCard(
              child: Text(
                'للاستفسار عن العقار أو ترتيب زيارة، تواصل مع صفوة الإنجاز.',
                style: TextStyle(color: AppColors.muted, fontSize: 13),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class RanounaVillaCard extends StatelessWidget {
  const RanounaVillaCard({super.key});

  @override
  Widget build(BuildContext context) => _ListingCard(
    cover: Image.asset(
      RanounaVilla.cover,
      fit: BoxFit.cover,
      semanticLabel: 'واجهة فيلا الرانوناء',
    ),
    coverAspectRatio: 16 / 11,
    title: RanounaVilla.title,
    subtitle: const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LocationLine(text: RanounaVilla.location),
        SizedBox(height: 5),
        Text(
          RanounaVilla.price,
          style: TextStyle(color: AppColors.navy, fontWeight: FontWeight.w800),
        ),
      ],
    ),
    facts: const [
      'الأرض ${RanounaVilla.landArea}',
      'البناء ${RanounaVilla.builtArea}',
    ],
    onTap: () => context.go(RanounaVilla.path),
    contactMessage: RanounaVilla.inquiry,
  );
}

class KingFahdBuildingCard extends StatelessWidget {
  const KingFahdBuildingCard({super.key});

  @override
  Widget build(BuildContext context) => _ListingCard(
    cover: Image.asset(
      'assets/images/banners/home-banner.png',
      fit: BoxFit.contain,
    ),
    title: PropertyData.buildingTitle,
    subtitle: const LocationLine(text: PropertyData.location),
    facts: const [
      '٣ أدوار',
      '٦ شقق',
      'مواقف سيارات',
      'الأرضي ${PropertyData.area}',
      'الدور الثاني ${PropertyData.buildingUpperArea}',
    ],
    onTap: () => context.go(PropertyData.buildingPath),
    contactMessage: PropertyData.buildingInquiry,
  );
}

class SalamOfferCard extends StatelessWidget {
  const SalamOfferCard({super.key, this.showContact = false});

  final bool showContact;

  @override
  Widget build(BuildContext context) => _ListingCard(
    cover: Image.asset(SalamOffer.cover, fit: BoxFit.contain),
    title: SalamOffer.title,
    subtitle: const Eyebrow(
      'عرض ${SalamOffer.reference} · ${SalamOffer.district}',
    ),
    facts: const [SalamOffer.area, 'كل شقة دور كامل', 'مصعد'],
    onTap: () => context.go(SalamOffer.path),
    contactMessage: showContact
        ? 'السلام عليكم، أود الاستفسار عن العرض ${SalamOffer.reference}.'
        : null,
  );
}

class _ListingCard extends StatelessWidget {
  const _ListingCard({
    required this.cover,
    required this.title,
    required this.subtitle,
    required this.facts,
    required this.onTap,
    this.contactMessage,
    this.coverAspectRatio = 2,
  });

  final Widget cover;
  final String title;
  final Widget subtitle;
  final List<String> facts;
  final VoidCallback onTap;
  final String? contactMessage;
  final double coverAspectRatio;

  @override
  Widget build(BuildContext context) => AppCard(
    padding: EdgeInsets.zero,
    onTap: onTap,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
          child: AspectRatio(aspectRatio: coverAspectRatio, child: cover),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              subtitle,
              const SizedBox(height: 7),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.ink,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final fact in facts)
                    _Chip(fact, prominent: contactMessage != null),
                ],
              ),
              const SizedBox(height: 13),
              if (contactMessage == null)
                const Row(
                  children: [
                    Expanded(
                      child: Text(
                        'عرض الصور والتفاصيل',
                        style: TextStyle(
                          color: AppColors.gold,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    Icon(Icons.chevron_left_rounded, color: AppColors.gold),
                  ],
                ),
              if (contactMessage case final message?) ...[
                Row(
                  children: [
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: () => ContactScreen.call(context),
                        icon: const Icon(Icons.call_outlined, size: 18),
                        label: const Text('اتصال'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: () =>
                            ContactScreen.whatsapp(context, message: message),
                        icon: const FaIcon(FontAwesomeIcons.whatsapp, size: 18),
                        label: const Text('واتساب'),
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFF137B49),
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: onTap,
                    icon: const Icon(Icons.chevron_left_rounded, size: 18),
                    label: const Text('استعراض العقار'),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.navy,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    ),
  );
}

class _Chip extends StatelessWidget {
  const _Chip(this.text, {required this.prominent});
  final String text;
  final bool prominent;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(
      color: prominent ? AppColors.navy : AppColors.background,
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(
      text,
      style: TextStyle(
        fontSize: 11,
        color: prominent ? Colors.white : AppColors.ink,
      ),
    ),
  );
}
