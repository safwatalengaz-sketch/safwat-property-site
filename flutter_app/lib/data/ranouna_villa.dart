abstract final class RanounaVilla {
  static const path = '/villas/ranouna-200';
  static const title = 'فيلا للبيع في مخطط الرانوناء';
  static const location = 'مخطط الرانوناء داخل الحد';
  static const price = '١٬١٥٠٬٠٠٠ ريال سعودي';
  static const landArea = '٢٠٠ م²';
  static const builtArea = '٢٩٠ م²';
  static const license = '7201082795';
  static const inquiry =
      'السلام عليكم، أود الاستفسار عن فيلا مخطط الرانوناء بمساحة أرض ٢٠٠ م².';
  static const images = 'assets/images/ranouna';
  static const cover = '$images/cover-design.jpg';
  static const poster = '$images/front-exterior.webp';
  static const tour = 'assets/videos/ranouna-villa-web-2032eff413bb.mp4';
  static const description =
      'مواقف واسعة جدًا، بحسب وصف المالك. أرضيات باركيه وورق جدران في كامل الفيلا.';

  static const photos = <(String, String)>[
    ('front-exterior', 'واجهة الفيلا من الشارع'),
    ('family-lounge-wide', 'الصالة العائلية من المدخل'),
    ('majlis-wide', 'المجلس من المدخل'),
    ('green-lounge-entry', 'الصالة الخضراء من المدخل'),
    ('family-lounge-side', 'زاوية الجلسة العائلية'),
    ('majlis-seating', 'توزيع الجلسة في المجلس'),
    ('green-lounge-corner', 'زاوية الجلسة الخضراء'),
    ('family-lounge-decor', 'تفاصيل الستائر والتشطيبات في الصالة العائلية'),
    ('majlis-chandelier', 'ثريا المجلس والكنب'),
    ('majlis-serving-area', 'ركن الضيافة في المجلس'),
    ('green-lounge-tv', 'جدار التلفزيون في الصالة'),
    ('lounge-passage', 'الممر بجوار الصالة'),
    ('gate-closeup', 'البوابة الأمامية وتفاصيل الواجهة'),
    ('side-door', 'المدخل الجانبي من الخارج'),
    ('front-courtyard', 'الحوش أمام المدخل'),
    ('side-passage', 'الممر الخارجي'),
    ('hallway-lighting', 'ممر المدخل والإضاءة'),
    ('second-entry', 'الباب من الحوش الجانبي'),
    ('lift-lower', 'المصعد بجوار الدرج'),
    ('stairs-landing', 'الدرج الداخلي'),
    ('lift-upper', 'باب المصعد في الجزء العلوي'),
    ('entry-vanity', 'المغسلة الخارجية والمرايا'),
    ('bathroom-entry', 'دورة المياه من المدخل'),
    ('bathroom-shower', 'المغسلة والدش في دورة مياه'),
    ('roof-terrace', 'المساحة المفتوحة على السطح'),
  ];

  static final photoAssets = [
    for (final (file, _) in photos) '$images/$file.webp',
  ];

  static const floors = <(String, String)>[
    (
      'الدور الأرضي',
      'مدخلان، مدخل لمجلس الرجال مع دورات مياه، ومدخل آخر للصالة مع دورات مياه، بالإضافة إلى مطبخ ومستودع.',
    ),
    (
      'الدور الأول',
      'غرفة ماستر، وغرفتان بينهما دورات مياه، وصالة مع منطقة خدمات «سيرفس».',
    ),
    ('الملحق', 'غرفة مع دورات مياه، وغرفة غسيل، وسطح.'),
  ];
}
