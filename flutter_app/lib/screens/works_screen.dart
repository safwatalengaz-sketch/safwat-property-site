import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../app.dart';
import '../data/property_data.dart';
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
            AppCard(
              padding: EdgeInsets.zero,
              onTap: onOpenProperty,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(18),
                    ),
                    child: AspectRatio(
                      aspectRatio: 2,
                      child: Image.asset(
                        'assets/images/banners/works-banner.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const LocationLine(text: PropertyData.location),
                        const SizedBox(height: 7),
                        const Text(
                          PropertyData.title,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppColors.ink,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _Chip('١٨٥ م²'),
                            _Chip('٣ غرف نوم'),
                            _Chip('تشطيب سوبر لوكس'),
                          ],
                        ),
                        const SizedBox(height: 13),
                        Row(
                          children: [
                            const Text(
                              'عرض الصور والتفاصيل',
                              style: TextStyle(
                                color: AppColors.gold,
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                              ),
                            ),
                            const Spacer(),
                            const Icon(
                              Icons.chevron_left_rounded,
                              color: AppColors.gold,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
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
