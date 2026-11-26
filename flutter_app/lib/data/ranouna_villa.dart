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
  static const cover = '$images/facade-cover.webp';
  static const poster = '$images/tour-poster.webp';
  static const tour = 'assets/videos/ranouna-villa-web-2032eff413bb.mp4';

  static const photos = <(String, String)>[
    ('facade', 'واجهة الفيلا'),
    ('front-gate', 'البوابة الأمامية'),
    ('side-entrance', 'المدخل الجانبي'),
    ('outdoor-passage', 'الممر الخارجي'),
    ('entrance-hall', 'ممر المدخل'),
    ('majlis', 'المجلس'),
    ('living-room', 'الصالة'),
    ('interior-finishes', 'التشطيبات الداخلية'),
    ('elevator-stairs', 'المصعد والدرج'),
    ('interior-room', 'غرفة داخلية'),
    ('upper-room', 'غرفة في الجزء العلوي'),
    ('bathroom', 'دورة مياه'),
    ('rooftop', 'السطح'),
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
