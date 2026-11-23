import 'package:flutter/material.dart';

import '../app.dart';
import '../data/property_data.dart';
import '../widgets/common.dart';
import 'contact_screen.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    padding: const EdgeInsets.fromLTRB(18, 26, 18, 32),
    child: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.asset(
                  'assets/logo/safwat-logo.jpeg',
                  width: 104,
                  height: 104,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            const SizedBox(height: 22),
            const Eyebrow('من نحن'),
            const SizedBox(height: 5),
            Text(
              'صفوة الإنجاز\nللخدمات العقارية',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: AppColors.navy,
                fontWeight: FontWeight.w900,
                height: 1.25,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'صفوة الإنجاز مؤسسة عقارية في المدينة المنورة، نعمل عبر مراحل العقار كاملة: نطوّر المشروعات والفرص، وننفّذ أعمال التشطيب وتجهيز الوحدات، ثم نتولى تسويق العقارات وبيعها، بما في ذلك الوحدات الجاهزة.',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.ink,
                fontWeight: FontWeight.w500,
                height: 1.9,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'نبدأ بفهم احتياج العميل، ونوضح تفاصيل كل عقار ومزاياه، ونتابع طلبات المعاينة والتواصل. نهتم بجودة التنفيذ، والتشطيبات العملية، وخصوصية الأسرة، ونقدم للعميل معلومات واضحة تساعده على اختيار العقار المناسب في المدينة المنورة.',
              style: TextStyle(
                fontSize: 15,
                color: AppColors.muted,
                fontWeight: FontWeight.w500,
                height: 1.9,
              ),
            ),
            const SizedBox(height: 24),
            const SectionTitle('خدماتنا العقارية'),
            const SizedBox(height: 11),
            const AppCard(
              child: Column(
                children: [
                  _ServiceLine(
                    Icons.apartment_rounded,
                    'تطوير المشروعات والفرص العقارية',
                    'دراسة الفرص وتحويلها إلى منتجات عقارية واضحة.',
                  ),
                  Divider(height: 25),
                  _ServiceLine(
                    Icons.handyman_rounded,
                    'التشطيب وتجهيز الوحدات',
                    'تنفيذ التشطيبات وتهيئة العقار ليكون جاهزًا للاستخدام أو البيع.',
                  ),
                  Divider(height: 25),
                  _ServiceLine(
                    Icons.campaign_rounded,
                    'التسويق والبيع',
                    'عرض العقارات ومساعدة العملاء على ترتيب المعاينة والتواصل.',
                  ),
                  Divider(height: 25),
                  _ServiceLine(
                    Icons.key_rounded,
                    'بيع الوحدات الجاهزة',
                    'خيارات سكنية منجزة بتفاصيل ومزايا موضحة للعميل.',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 23),
            const SectionTitle('السجل التجاري'),
            const SizedBox(height: 10),
            AppCard(
              padding: EdgeInsets.zero,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const RegistryViewer()),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Padding(
                    padding: EdgeInsets.fromLTRB(16, 16, 16, 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.verified_rounded, color: AppColors.gold),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'مؤسسة صفوة الإنجاز للخدمات العقارية',
                                style: TextStyle(
                                  color: AppColors.navy,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 12),
                        _RegistryLine('الرقم الوطني الموحد', '7025764932'),
                        _RegistryLine('نوع الكيان', 'مؤسسة'),
                        _RegistryLine('تاريخ الإصدار', '١٥ / ٠٩ / ٢٠٢١'),
                        _RegistryLine('حالة السجل', 'نشط'),
                      ],
                    ),
                  ),
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      bottom: Radius.circular(18),
                    ),
                    child: Image.asset(
                      'assets/images/company/commercial-registration.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.zoom_in_rounded,
                          color: AppColors.gold,
                          size: 19,
                        ),
                        SizedBox(width: 6),
                        Text(
                          'اضغط لتكبير صورة السجل',
                          style: TextStyle(
                            color: AppColors.navy,
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            AppActionButton(
              label: 'تواصل مع صفوة الإنجاز',
              icon: Icons.chat_rounded,
              onPressed: () => ContactScreen.whatsapp(context),
              gold: true,
            ),
            const SizedBox(height: 14),
            Text(
              'ترخيص الإعلان العقاري للشقة المعروضة: ${PropertyData.license}',
              style: const TextStyle(
                color: AppColors.muted,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _ServiceLine extends StatelessWidget {
  const _ServiceLine(this.icon, this.title, this.subtitle);
  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Icon(icon, color: AppColors.gold, size: 22),
      const SizedBox(width: 11),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
            const SizedBox(height: 3),
            Text(
              subtitle,
              style: const TextStyle(
                color: AppColors.muted,
                fontSize: 13,
                height: 1.6,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    ],
  );
}

class _RegistryLine extends StatelessWidget {
  const _RegistryLine(this.label, this.value);
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 8),
    child: Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              color: AppColors.muted,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: AppColors.ink,
            fontWeight: FontWeight.w800,
            fontSize: 13,
          ),
        ),
      ],
    ),
  );
}

class RegistryViewer extends StatelessWidget {
  const RegistryViewer({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFF0B1118),
    appBar: AppBar(
      backgroundColor: const Color(0xFF0B1118),
      foregroundColor: Colors.white,
      title: const Text('شهادة السجل التجاري'),
      leading: IconButton(
        icon: const Icon(Icons.close_rounded),
        onPressed: () => Navigator.pop(context),
      ),
    ),
    body: InteractiveViewer(
      minScale: 1,
      maxScale: 4,
      child: Center(
        child: Image.asset(
          'assets/images/company/commercial-registration.png',
          fit: BoxFit.contain,
        ),
      ),
    ),
  );
}
