import 'package:flutter/material.dart';

import '../analytics/marketing.dart';
import '../data/property_data.dart';

class MarketingChoice extends StatefulWidget {
  const MarketingChoice({super.key});

  @override
  State<MarketingChoice> createState() => _MarketingChoiceState();
}

class _MarketingChoiceState extends State<MarketingChoice> {
  void _choose(bool allowed) {
    Marketing.setAllowed(allowed);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (!Marketing.available || Marketing.hasPreference) {
      return const SizedBox.shrink();
    }

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
