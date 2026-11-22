import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../analytics/marketing.dart';
import '../app.dart';
import '../data/property_data.dart';
import 'contact_screen.dart';
import 'property_details_screen.dart';

class ApartmentsScreen extends StatelessWidget {
  const ApartmentsScreen({super.key});

  @override
  Widget build(BuildContext context) => _CatalogPage(
    title: 'الشقق المعروضة للبيع',
    children: [
      Image.asset(PropertyData.photos[4], fit: BoxFit.cover, height: 240),
      const SizedBox(height: 16),
      const LocationLine(text: PropertyData.location),
      const SizedBox(height: 8),
      const Text(
        'شقة أرضية بمساحة ١٨٥ م²، ثلاث غرف نوم منها غرفة ماستر، '
        'مدخلان مستقلان، موقف خاص وتشطيب سوبر لوكس.',
      ),
      const _PropertyActions(detailsLabel: 'تفاصيل الشقة والصور'),
    ],
  );
}

class BuildingsScreen extends StatelessWidget {
  const BuildingsScreen({super.key});

  @override
  Widget build(BuildContext context) => _CatalogPage(
    title: 'عمارة سكنية في حي الملك فهد',
    children: [
      Image.asset(
        'assets/images/banners/works-banner.png',
        fit: BoxFit.contain,
      ),
      const SizedBox(height: 16),
      const LocationLine(text: PropertyData.location),
      const SizedBox(height: 8),
      const Text(
        'عمارة من ٣ أدوار تضم ٦ شقق. للشقق العلوية أسطح خاصة، '
        'ويوجد مصعد وموقف خاص لكل شقة.',
      ),
      const Text('تواصل معنا لمعرفة السعر والتوفر وترتيب المعاينة.'),
      const _PropertyActions(detailsLabel: 'اطّلع على تفاصيل الشقة'),
    ],
  );
}

class ToursScreen extends StatelessWidget {
  const ToursScreen({super.key});

  @override
  Widget build(BuildContext context) => const _CatalogPage(
    title: 'الجولات العقارية المصورة',
    children: [
      Text('شاهد جولات العقار في حي الملك فهد بالمدينة المنورة.'),
      SizedBox(height: 16),
      PropertyVideo(),
      _PropertyActions(detailsLabel: 'تفاصيل العقار والصور'),
    ],
  );
}

class _CatalogPage extends StatelessWidget {
  const _CatalogPage({required this.title, required this.children});
  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Center(
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 600),
      child: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.headlineMedium
                ?.copyWith(color: AppColors.navy),
          ),
          const SizedBox(height: 16),
          if (Marketing.available) const _MarketingChoice(),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: children,
            ),
          ),
        ],
      ),
    ),
  );
}

class _MarketingChoice extends StatefulWidget {
  const _MarketingChoice();

  @override
  State<_MarketingChoice> createState() => _MarketingChoiceState();
}

class _MarketingChoiceState extends State<_MarketingChoice> {
  void _choose(bool allowed) {
    Marketing.setAllowed(allowed);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (Marketing.hasPreference) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('يمكنك السماح بقياس زيارات الإعلانات ونقرات التواصل.'),
            Wrap(
              spacing: 8,
              children: [
                TextButton(
                  onPressed: () => _choose(true),
                  child: const Text('السماح بالقياس'),
                ),
                TextButton(
                  onPressed: () => _choose(false),
                  child: const Text('المتابعة دون قياس'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PropertyActions extends StatelessWidget {
  const _PropertyActions({required this.detailsLabel});
  final String detailsLabel;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 12),
    child: Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        FilledButton(
          onPressed: () => context.go('/properties'),
          child: Text(detailsLabel),
        ),
        OutlinedButton(
          onPressed: () => ContactScreen.whatsapp(context),
          child: const Text('واتساب'),
        ),
        OutlinedButton(
          onPressed: () => ContactScreen.call(context),
          child: const Text('اتصل الآن'),
        ),
      ],
    ),
  );
}
