import 'package:flutter/material.dart';

import '../app.dart';
import '../data/property_data.dart';
import '../widgets/marketing_choice.dart';
import 'contact_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    super.key,
    required this.onOpenProperty,
    required this.onOpenWorks,
  });
  final VoidCallback onOpenProperty;
  final VoidCallback onOpenWorks;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(18, 22, 18, 28),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Eyebrow('أهلًا بكم في صفوة الإنجاز'),
              const SizedBox(height: 6),
              Text(
                'عقارك القادم\nيبدأ من هنا',
                style: Theme.of(context).textTheme.headlineMedium
                    ?.copyWith(color: AppColors.navy, height: 1.27),
              ),
              const SizedBox(height: 6),
              const Text(
                'المدينة المنورة',
                style: TextStyle(color: AppColors.muted, fontSize: 14),
              ),
              const SizedBox(height: 18),
              AppCard(
                padding: EdgeInsets.zero,
                onTap: onOpenWorks,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: AspectRatio(
                    aspectRatio: 2,
                    child: Image.asset(
                      'assets/images/banners/home-banner.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const MarketingChoice(),
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const LocationLine(text: PropertyData.location),
                    const SizedBox(height: 12),
                    const Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _InfoPill(
                          icon: Icons.square_foot_rounded,
                          label: '١٨٥ م²',
                        ),
                        _InfoPill(icon: Icons.bed_outlined, label: '٣ غرف نوم'),
                        _InfoPill(
                          icon: Icons.door_front_door_outlined,
                          label: 'مدخلان مستقلان',
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: AppActionButton(
                            label: 'استعرض العقار',
                            icon: Icons.arrow_forward_rounded,
                            onPressed: onOpenProperty,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: AppActionButton(
                            label: 'اتصل بنا',
                            icon: Icons.call_outlined,
                            onPressed: () => ContactScreen.call(context),
                            gold: true,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              AppCard(
                onTap: onOpenProperty,
                child: Row(
                  children: [
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Eyebrow('العقار المتاح'),
                          SizedBox(height: 3),
                          Text(
                            PropertyData.title,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'صور وفيديو وتفاصيل العقار',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.muted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.chevron_left_rounded,
                      color: AppColors.gold,
                      size: 27,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoPill extends StatelessWidget {
  const _InfoPill({required this.icon, required this.label});
  final IconData icon;
  final String label;
  @override
  Widget build(BuildContext context) => ConstrainedBox(
    constraints: const BoxConstraints(minWidth: 92),
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 5),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.gold, size: 18),
          const SizedBox(height: 3),
          Text(
            label,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    ),
  );
}
