import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../app.dart';
import '../data/property_data.dart';
import '../data/salam_offer.dart';
import '../widgets/marketing_choice.dart';

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
            const MarketingChoice(),
            _ListingCard(
              cover: Image.asset(
                'assets/images/banners/works-banner.png',
                fit: BoxFit.contain,
              ),
              title: PropertyData.title,
              subtitle: const LocationLine(text: PropertyData.location),
              facts: const ['١٨٥ م²', '٣ غرف نوم', 'تشطيب سوبر لوكس'],
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

class SalamOfferCard extends StatelessWidget {
  const SalamOfferCard({super.key});

  @override
  Widget build(BuildContext context) => _ListingCard(
    cover: Image.asset(SalamOffer.cover, fit: BoxFit.contain),
    title: SalamOffer.title,
    subtitle: const Eyebrow(
      'عرض ${SalamOffer.reference} · ${SalamOffer.district}',
    ),
    facts: const [SalamOffer.area, 'كل شقة دور كامل', 'مصعد'],
    onTap: () => context.go(SalamOffer.path),
  );
}

class _ListingCard extends StatelessWidget {
  const _ListingCard({
    required this.cover,
    required this.title,
    required this.subtitle,
    required this.facts,
    required this.onTap,
  });

  final Widget cover;
  final String title;
  final Widget subtitle;
  final List<String> facts;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => AppCard(
    padding: EdgeInsets.zero,
    onTap: onTap,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
          child: AspectRatio(aspectRatio: 2, child: cover),
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
                children: [for (final fact in facts) _Chip(fact)],
              ),
              const SizedBox(height: 13),
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
            ],
          ),
        ),
      ],
    ),
  );
}

class _Chip extends StatelessWidget {
  const _Chip(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(
      color: AppColors.background,
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(
      text,
      style: const TextStyle(fontSize: 11, color: AppColors.ink),
    ),
  );
}
