import 'package:flutter/material.dart';

import '../app.dart';

class PropertyData {
  static const title = 'شقة مميزة للبيع';
  static const area = '١٨٥ م²';
  static const buildingPath = '/properties/king-fahd-building';
  static const buildingTitle = 'عمارة سكنية في حي الملك فهد';
  static const buildingUpperArea = '٢٠٠ م²';
  static const buildingDescription =
      'عمارة سكنية من ٣ أدوار تضم ٦ شقق. يوجد مصعد وموقف خاص لكل شقة، '
      'وللشقق العلوية أسطح خاصة.';
  static const buildingInquiry =
      'السلام عليكم، أود الاستفسار عن العمارة في حي الملك فهد.';
  static const location = 'حي الملك فهد – المدينة المنورة';
  static const descriptionIntro =
      'تدور على شقة مميزة بالمدينة المنورة، بموقع مميز وتصميم يجمع بين الفخامة والخصوصية؟\n\nتقع الشقة في حي الملك فهد، مع سهولة الوصول للمسجد النبوي، ومحطة قطار الحرمين، ومطار الأمير محمد بن عبدالعزيز. تعرّف على التفاصيل:';
  static const descriptionClose =
      'تصميم يجمع بين جودة التشطيب، ورحابة المساحات، والخصوصية لكل أفراد العائلة. لا تفوّت الفرصة، تواصل معنا الآن واحجز موعد المعاينة.';
  static const license = '7201207204';
  static const phone = '+966551204411';
  static const whatsapp = 'https://wa.me/966551204411';
  static const propertyMap =
      'https://www.google.com/maps/place/24%C2%B029%2738.7%22N+39%C2%B041%2757.8%22E/@24.4940739,39.7015791,17z/data=!3m1!4b1!4m4!3m3!8m2!3d24.4940739!4d39.6993904';
  static const officeMap =
      'https://www.google.com/maps/place//@24.4768693,39.5088045,17z/data=!4m6!1m5!3m4!2zMjTCsDI4JzM2LjciTiAzOcKwMzAnMjMuOCJF!8m2!3d24.4768693!4d39.5066158';
  static const snapchat =
      'https://www.snapchat.com/add/aaqeralmadinah1?share_id=ULnIc5J3WP4&locale=ar-SA-u-nu-arab';
  static const tiktok = 'https://www.tiktok.com/@aaqeralmadinah1?_r=1';
  static const photos = [
    'assets/images/property/01-city-aerial.jpg',
    'assets/images/property/02-rooftop-aerial.jpg',
    'assets/images/property/03-building-front-evening.jpg',
    'assets/images/property/04-building-front-day.jpg',
    'assets/images/property/05-room-wide.jpg',
    'assets/images/property/06-room-doorway.jpg',
    'assets/images/property/07-bedroom-entry.jpg',
    'assets/images/property/08-hall-bathroom.jpg',
    'assets/images/property/09-room-ceiling.jpg',
    'assets/images/property/10-stairwell-window.jpg',
    'assets/images/property/11-interior-door.jpg',
    'assets/images/property/12-living-area.jpg',
    'assets/images/property/13-main-corridor.jpg',
    'assets/images/property/14-bedroom-corner.jpg',
    'assets/images/property/15-elevator-lobby.jpg',
    'assets/images/property/16-staircase.jpg',
    'assets/images/property/17-bathroom.jpg',
    'assets/images/property/18-double-vanity.jpg',
    'assets/images/property/19-ceiling-detail.jpg',
    'assets/images/property/20-bedroom-window.jpg',
  ];
  static const photoLabels = [
    'إطلالة جوية على العقار والحي',
    'سطح العمارة',
    'واجهة العمارة مساءً',
    'واجهة العمارة نهارًا',
    'مساحة داخلية',
    'مدخل الغرفة',
    'مدخل داخلي',
    'الممر المؤدي للحمام',
    'تفاصيل السقف والإضاءة',
    'درج داخلي ونافذة',
    'باب داخلي',
    'مساحة المعيشة',
    'الممر الداخلي',
    'زاوية من الغرفة',
    'ردهة المصعد',
    'الدرج الداخلي',
    'الحمام',
    'مغسلتان ومرآتان',
    'إضاءة السقف',
    'غرفة بإطلالة على النافذة',
  ];
  static const features = [
    'المساحة: ١٨٥ مترًا مربعًا',
    'تشطيب سوبر لوكس، وأسقف جبس بورد بتصاميم أنيقة',
    'مدخلان مستقلان: مدخل خاص للرجال ومدخل خاص للعائلة',
    'موقف خاص للسيارة',
    'قسم الرجال: مغاسل ودورات مياه، ومجلس خاص، وغرفة للضيافة',
    'قسم العائلة: صالة واسعة، وثلاث غرف نوم منها غرفة ماستر، ومطبخ، وغرفة خاصة للعاملة، وغرفة غسيل، ودورات مياه',
  ];
}

class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.onTap,
  });
  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) {
    final box = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.line),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A102B3F),
            blurRadius: 18,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: child,
    );
    return onTap == null
        ? box
        : Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(18),
              child: box,
            ),
          );
  }
}

class Eyebrow extends StatelessWidget {
  const Eyebrow(this.text, {super.key});
  final String text;
  @override
  Widget build(BuildContext context) => Text(
    text,
    style: const TextStyle(
      color: AppColors.gold,
      fontSize: 12,
      fontWeight: FontWeight.w700,
    ),
  );
}

class SectionTitle extends StatelessWidget {
  const SectionTitle(this.title, {super.key, this.subtitle});
  final String title;
  final String? subtitle;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        title,
        style: Theme.of(context).textTheme.titleLarge
            ?.copyWith(color: AppColors.ink),
      ),
      if (subtitle != null) ...[
        const SizedBox(height: 3),
        Text(
          subtitle!,
          style: const TextStyle(color: AppColors.muted, fontSize: 12),
        ),
      ],
    ],
  );
}

class AppActionButton extends StatelessWidget {
  const AppActionButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onPressed,
    this.gold = false,
    this.color,
  });
  final String label;
  final IconData icon;
  final VoidCallback onPressed;
  final bool gold;
  final Color? color;
  @override
  Widget build(BuildContext context) => FilledButton.icon(
    onPressed: onPressed,
    icon: Icon(icon, size: 18),
    label: Text(label),
    style: FilledButton.styleFrom(
      backgroundColor: color ?? (gold ? AppColors.gold : AppColors.navy),
      foregroundColor: gold || color == AppColors.gold
          ? AppColors.ink
          : Colors.white,
      minimumSize: const Size(0, 48),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  );
}

class LocationLine extends StatelessWidget {
  const LocationLine({super.key, required this.text});
  final String text;
  @override
  Widget build(BuildContext context) => Row(
    children: [
      const Icon(Icons.location_on_outlined, size: 18, color: AppColors.gold),
      const SizedBox(width: 6),
      Expanded(
        child: Text(
          text,
          style: const TextStyle(fontSize: 12, color: AppColors.muted),
        ),
      ),
    ],
  );
}
