import 'package:flutter/material.dart';

import '../app.dart';
import '../data/property_data.dart';
import 'privacy_screen.dart';
import 'works_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.onOpenWorks});
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
              const SizedBox(height: 10),
              TextButton.icon(
                onPressed: onOpenWorks,
                icon: const Icon(Icons.apartment_rounded, size: 19),
                label: const Text('العقارات المتاحة'),
              ),
              const SizedBox(height: 10),
              const RanounaVillaCard(),
              const SizedBox(height: 16),
              const KingFahdBuildingCard(),
              const SizedBox(height: 16),
              const SalamOfferCard(showContact: true),
              const SizedBox(height: 12),
              const PrivacyLink(),
            ],
          ),
        ),
      ),
    );
  }
}
