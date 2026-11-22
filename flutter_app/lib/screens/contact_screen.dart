import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

import '../analytics/marketing.dart';
import '../app.dart';
import '../data/property_data.dart';
import '../widgets/common.dart';
import '../widgets/marketing_choice.dart';

class ContactScreen extends StatelessWidget {
  const ContactScreen({super.key});

  static Future<void> call(BuildContext context) async =>
      _launch(context, Uri(scheme: 'tel', path: PropertyData.phone));
  static Future<void> whatsapp(BuildContext context) async =>
      _launch(context, Uri.parse(PropertyData.whatsapp));
  static Future<void> _launch(BuildContext context, Uri uri) async {
    if (uri.scheme == 'tel') Marketing.contact('phone');
    if (uri.host == 'wa.me') Marketing.contact('whatsapp');
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تعذر فتح الرابط على هذا الجهاز')),
      );
    }
  }

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    padding: const EdgeInsets.fromLTRB(18, 26, 18, 30),
    child: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Eyebrow('يسعدنا تواصلكم'),
            const SizedBox(height: 5),
            Text(
              'تواصل معنا',
              style: Theme.of(context).textTheme.headlineMedium
                  ?.copyWith(color: AppColors.navy),
            ),
            const SizedBox(height: 5),
            const Text(
              'فريق صفوة الإنجاز جاهز للرد على استفساراتكم.',
              style: TextStyle(color: AppColors.muted),
            ),
            const SizedBox(height: 21),
            const MarketingChoice(),
            _ContactTile(
              icon: const Icon(Icons.call_rounded),
              color: AppColors.navy,
              title: 'اتصال هاتفي',
              subtitle: '055 120 4411',
              onTap: () => call(context),
            ),
            const SizedBox(height: 10),
            _ContactTile(
              icon: const FaIcon(FontAwesomeIcons.whatsapp),
              color: const Color(0xFF25D366),
              title: 'واتساب',
              subtitle: 'راسل صفوة الإنجاز',
              onTap: () => whatsapp(context),
            ),
            const SizedBox(height: 22),
            const SectionTitle('تابعونا'),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _SocialSquare(
                    icon: const FaIcon(
                      FontAwesomeIcons.snapchat,
                      color: Colors.black,
                      size: 24,
                    ),
                    color: const Color(0xFFFFFC00),
                    foreground: Colors.black,
                    label: 'سناب شات',
                    onTap: () =>
                        _launch(context, Uri.parse(PropertyData.snapchat)),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _SocialSquare(
                    icon: const FaIcon(
                      FontAwesomeIcons.tiktok,
                      color: Colors.white,
                      size: 24,
                    ),
                    color: Colors.black,
                    foreground: Colors.white,
                    label: 'تيك توك',
                    onTap: () =>
                        _launch(context, Uri.parse(PropertyData.tiktok)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 22),
            const SectionTitle('موقع المكتب'),
            const SizedBox(height: 5),
            const Text(
              'زورونا في المدينة المنورة، وافتحوا موقع المكتب مباشرةً على الخريطة.',
              style: TextStyle(color: AppColors.muted, fontSize: 13),
            ),
            const SizedBox(height: 12),
            AppCard(
              padding: const EdgeInsets.all(8),
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(13),
                    child: SizedBox(
                      height: 220,
                      child: FlutterMap(
                        options: const MapOptions(
                          initialCenter: LatLng(24.4768611, 39.5066111),
                          initialZoom: 14,
                          interactionOptions: InteractionOptions(
                            flags:
                                InteractiveFlag.all & ~InteractiveFlag.rotate,
                          ),
                        ),
                        children: [
                          TileLayer(
                            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                            userAgentPackageName: 'com.safwat.property',
                          ),
                          MarkerLayer(
                            markers: [
                              Marker(
                                point: LatLng(24.4768611, 39.5066111),
                                width: 48,
                                height: 48,
                                child: const Icon(
                                  Icons.location_on_rounded,
                                  color: AppColors.gold,
                                  size: 42,
                                  shadows: [
                                    Shadow(color: Colors.white, blurRadius: 5),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          RichAttributionWidget(
                            attributions: [
                              TextSourceAttribution(
                                '© OpenStreetMap contributors',
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8, 12, 8, 4),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          color: AppColors.gold,
                        ),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text(
                            'موقع المكتب في المدينة المنورة',
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ),
                        TextButton.icon(
                          onPressed: () => _launch(
                            context,
                            Uri.parse(PropertyData.officeMap),
                          ),
                          icon: const Icon(Icons.directions_rounded, size: 18),
                          label: const Text('الاتجاهات'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'ترخيص الإعلان العقاري: ${PropertyData.license}',
              style: TextStyle(color: AppColors.muted, fontSize: 12),
            ),
            if (Marketing.available)
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: TextButton(
                  onPressed: () => _showPrivacy(context),
                  child: const Text('إعدادات الخصوصية'),
                ),
              ),
          ],
        ),
      ),
    ),
  );

  static Future<void> _showPrivacy(BuildContext context) async {
    final allowed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('إعدادات الخصوصية'),
        content: Text(
          'قياس زيارات الصفحات ونقرات الاتصال وواتساب عبر منصات الإعلان المفعّلة '
          '(سناب شات، جوجل وتيك توك). قد تستخدم هذه المنصات ملفات تعريف الارتباط. '
          'الحالة الحالية: ${Marketing.allowed ? 'مفعّل' : 'متوقف'}.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('رفض القياس'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('السماح بالقياس'),
          ),
        ],
      ),
    );
    if (allowed != null) Marketing.setAllowed(allowed);
  }
}

class _ContactTile extends StatelessWidget {
  const _ContactTile({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });
  final Widget icon;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => AppCard(
    onTap: onTap,
    child: Row(
      children: [
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: color.withValues(alpha: .1),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Center(child: icon),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
              Text(
                subtitle,
                style: const TextStyle(fontSize: 12, color: AppColors.muted),
              ),
            ],
          ),
        ),
        const Icon(Icons.chevron_left_rounded, color: AppColors.gold),
      ],
    ),
  );
}

class _SocialSquare extends StatelessWidget {
  const _SocialSquare({
    required this.icon,
    required this.color,
    required this.foreground,
    required this.label,
    required this.onTap,
  });
  final Widget icon;
  final Color color;
  final Color foreground;
  final String label;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => AppCard(
    onTap: onTap,
    padding: const EdgeInsets.symmetric(vertical: 17, horizontal: 12),
    child: Column(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: const [
              BoxShadow(
                color: Color(0x12102B3F),
                blurRadius: 10,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Center(child: icon),
        ),
        const SizedBox(height: 9),
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
        ),
      ],
    ),
  );
}
