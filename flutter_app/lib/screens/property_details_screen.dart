import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';

import '../app.dart';
import '../data/property_data.dart';
import '../data/salam_offer.dart';
import '../widgets/common.dart';
import 'contact_screen.dart';
import 'privacy_screen.dart';

class PropertyDetailsScreen extends StatefulWidget {
  const PropertyDetailsScreen({
    super.key,
    this.isSalamOffer = false,
    this.isBuilding = false,
  });
  final bool isSalamOffer;
  final bool isBuilding;
  @override
  State<PropertyDetailsScreen> createState() => _PropertyDetailsScreenState();
}

class _PropertyDetailsScreenState extends State<PropertyDetailsScreen> {
  late final PageController _pageController;
  int _index = 0;
  List<String> get _photos =>
      widget.isSalamOffer ? SalamOffer.photos : PropertyData.photos;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'تفاصيل العقار',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_forward_rounded),
          onPressed: () => context.go('/works'),
        ),
        actions: widget.isSalamOffer
            ? null
            : [
                IconButton(
                  tooltip: 'مشاركة',
                  onPressed: () async {
                    await Clipboard.setData(
                      ClipboardData(text: PropertyData.propertyMap),
                    );
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('تم نسخ رابط موقع العقار'),
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.share_outlined),
                ),
                const SizedBox(width: 6),
              ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 30),
            children: [
              _galleryCard(),
              const SizedBox(height: 18),
              Eyebrow(
                widget.isSalamOffer
                    ? SalamOffer.district
                    : PropertyData.location,
              ),
              if (widget.isSalamOffer)
                const Text('رقم العرض ${SalamOffer.reference}'),
              const SizedBox(height: 4),
              Text(
                widget.isSalamOffer
                    ? SalamOffer.title
                    : widget.isBuilding
                    ? PropertyData.buildingTitle
                    : PropertyData.title,
                style: Theme.of(context).textTheme.titleLarge
                    ?.copyWith(color: AppColors.navy, fontSize: 22),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: widget.isSalamOffer
                    ? const [
                        _DetailPill(Icons.square_foot_rounded, SalamOffer.area),
                        _DetailPill(
                          Icons.apartment_outlined,
                          '٣ شقق، كل شقة دور كامل',
                        ),
                        _DetailPill(Icons.elevator_outlined, 'مصعد'),
                      ]
                    : widget.isBuilding
                    ? const [
                        _DetailPill(Icons.apartment_outlined, '٣ أدوار'),
                        _DetailPill(Icons.meeting_room_outlined, '٦ شقق'),
                        _DetailPill(
                          Icons.local_parking_rounded,
                          'مواقف سيارات',
                        ),
                      ]
                    : const [
                        _DetailPill(Icons.square_foot_rounded, '١٨٥ م²'),
                        _DetailPill(Icons.bed_outlined, '٣ غرف نوم'),
                        _DetailPill(Icons.door_front_door_outlined, 'مدخلان'),
                      ],
              ),
              const SizedBox(height: 22),
              SectionTitle(
                widget.isSalamOffer
                    ? 'وصف العرض'
                    : widget.isBuilding
                    ? 'وصف العمارة'
                    : 'وصف الشقة',
              ),
              const SizedBox(height: 10),
              AppCard(
                child: Text(
                  widget.isSalamOffer
                      ? SalamOffer.description
                      : widget.isBuilding
                      ? PropertyData.buildingDescription
                      : PropertyData.descriptionIntro,
                  style: const TextStyle(
                    color: AppColors.ink,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    height: 1.9,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const SectionTitle('المساحات والتفاصيل'),
              const SizedBox(height: 10),
              if (widget.isSalamOffer) ...[
                for (final (floor, description, reserved) in SalamOffer.floors)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: AppCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Wrap(
                            spacing: 10,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              Text(
                                floor,
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              if (reserved) const Eyebrow('محجوز'),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(description),
                        ],
                      ),
                    ),
                  ),
              ] else if (widget.isBuilding)
                const AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('الدور الأرضي: ${PropertyData.area}'),
                      SizedBox(height: 6),
                      Text('الدور الثاني: ${PropertyData.buildingUpperArea}'),
                    ],
                  ),
                )
              else ...[
                _featuresCard(),
                const SizedBox(height: 10),
                const AppCard(
                  child: Text(
                    PropertyData.descriptionClose,
                    style: TextStyle(
                      color: AppColors.navy,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      height: 1.8,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 22),
              const SectionTitle('شاهد العقار بالفيديو'),
              const SizedBox(height: 10),
              if (widget.isSalamOffer)
                const PropertyVideo(
                  clips: SalamOffer.clips,
                  poster: 'assets/images/mb-246/02-living-stairs.jpg',
                )
              else
                const PropertyVideo(),
              if (!widget.isSalamOffer) ...[
                const SizedBox(height: 22),
                const SectionTitle('موقع العقار'),
                const SizedBox(height: 10),
                AppCard(
                  onTap: () => _openMap(context),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: 24,
                        color: AppColors.gold,
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              PropertyData.location,
                              style: TextStyle(fontWeight: FontWeight.w700),
                            ),
                            SizedBox(height: 2),
                            Text(
                              '24.4940739, 39.6993904',
                              style: TextStyle(
                                fontSize: 11,
                                color: AppColors.muted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.open_in_new_rounded,
                        size: 18,
                        color: AppColors.gold,
                      ),
                    ],
                  ),
                ),
                if (!widget.isBuilding) ...[
                  const SizedBox(height: 16),
                  const Text(
                    'ترخيص الإعلان العقاري: ${PropertyData.license}',
                    style: TextStyle(color: AppColors.muted, fontSize: 12),
                  ),
                ],
              ],
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: AppActionButton(
                      label: 'اتصال',
                      icon: Icons.call_rounded,
                      onPressed: () => ContactScreen.call(context),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: AppActionButton(
                      label: 'احجز موعد المعاينة',
                      icon: Icons.chat_bubble_outline_rounded,
                      onPressed: () => ContactScreen.whatsapp(
                        context,
                        message: widget.isSalamOffer
                            ? 'السلام عليكم، أود الاستفسار عن العرض ${SalamOffer.reference}.'
                            : widget.isBuilding
                            ? PropertyData.buildingInquiry
                            : null,
                      ),
                      gold: true,
                    ),
                  ),
                ],
              ),
              if (widget.isSalamOffer) ...[
                const SizedBox(height: 16),
                const Text(
                  SalamOffer.advertisingLicenseLabel,
                  style: TextStyle(color: AppColors.muted, fontSize: 12),
                ),
              ],
              const SizedBox(height: 12),
              const PrivacyLink(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _galleryCard() {
    final mediaWidth = MediaQuery.sizeOf(context).width;
    final imageWidth = (mediaWidth - 32).clamp(280.0, 800.0);
    // All supplied property photos are portrait 9:16 images. Match their
    // native ratio so the original photos fill the gallery without side bars.
    final galleryHeight = imageWidth * 16 / 9;
    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: SizedBox(
              height: galleryHeight,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  PageView.builder(
                    controller: _pageController,
                    itemCount: _photos.length,
                    onPageChanged: (i) => setState(() => _index = i),
                    itemBuilder: (context, i) => GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              PhotoViewer(startIndex: i, photos: _photos),
                        ),
                      ),
                      child: ColoredBox(
                        color: Colors.white,
                        child: Image.asset(_photos[i], fit: BoxFit.contain),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 12,
                    right: 14,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        child: Text(
                          '${_arabic(_index + 1)} / ${_arabic(_photos.length)}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            height: 82,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
              itemCount: _photos.length,
              separatorBuilder: (context, index) => const SizedBox(width: 8),
              itemBuilder: (context, i) => GestureDetector(
                onTap: () => _pageController.animateToPage(
                  i,
                  duration: const Duration(milliseconds: 280),
                  curve: Curves.easeOut,
                ),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: 62,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: i == _index ? AppColors.gold : Colors.transparent,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(9),
                    child: Image.asset(_photos[i], fit: BoxFit.cover),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _featuresCard() => AppCard(
    child: Column(
      children: PropertyData.features
          .map(
            (feature) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.check_circle_outline,
                    size: 19,
                    color: AppColors.gold,
                  ),
                  const SizedBox(width: 9),
                  Expanded(
                    child: Text(feature, style: const TextStyle(fontSize: 13)),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    ),
  );

  String _arabic(int n) => n
      .toString()
      .replaceAll('0', '٠')
      .replaceAll('1', '١')
      .replaceAll('2', '٢')
      .replaceAll('3', '٣')
      .replaceAll('4', '٤')
      .replaceAll('5', '٥')
      .replaceAll('6', '٦')
      .replaceAll('7', '٧')
      .replaceAll('8', '٨')
      .replaceAll('9', '٩');

  Future<void> _openMap(BuildContext context) async {
    final ok = await launchUrl(
      Uri.parse(PropertyData.propertyMap),
      mode: LaunchMode.externalApplication,
    );
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('تعذر فتح الخريطة')));
    }
  }
}

class _DetailPill extends StatelessWidget {
  const _DetailPill(this.icon, this.label);
  final IconData icon;
  final String label;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
    decoration: BoxDecoration(
      color: const Color(0xFFECE6D7),
      borderRadius: BorderRadius.circular(24),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 15, color: AppColors.navy),
        const SizedBox(width: 5),
        Text(
          label,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        ),
      ],
    ),
  );
}

class PhotoViewer extends StatefulWidget {
  const PhotoViewer({
    super.key,
    required this.startIndex,
    required this.photos,
  });
  final int startIndex;
  final List<String> photos;
  @override
  State<PhotoViewer> createState() => _PhotoViewerState();
}

class _PhotoViewerState extends State<PhotoViewer> {
  late final PageController _controller;
  late int _index;
  @override
  void initState() {
    super.initState();
    _index = widget.startIndex;
    _controller = PageController(initialPage: _index);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFF0B1118),
    appBar: AppBar(
      backgroundColor: const Color(0xFF0B1118),
      foregroundColor: Colors.white,
      title: Text(
        '${_index + 1} / ${widget.photos.length}',
        style: const TextStyle(fontSize: 14),
      ),
      leading: IconButton(
        icon: const Icon(Icons.close),
        onPressed: () => Navigator.pop(context),
      ),
    ),
    body: PageView.builder(
      controller: _controller,
      itemCount: widget.photos.length,
      onPageChanged: (i) => setState(() => _index = i),
      itemBuilder: (_, i) => InteractiveViewer(
        minScale: 1,
        maxScale: 4,
        child: Center(
          child: Image.asset(widget.photos[i], fit: BoxFit.contain),
        ),
      ),
    ),
  );
}

class PropertyVideo extends StatefulWidget {
  const PropertyVideo({
    super.key,
    this.clips = _defaultClips,
    this.poster = 'assets/images/property/05-room-wide.jpg',
  });
  static const _defaultClips = <(String, String)>[
    ('جولة العقار ١', 'assets/videos/property-tour.mp4'),
    ('جولة العقار ٢', 'assets/videos/property-tour-2.mp4'),
    ('جولة العقار ٣', 'assets/videos/property-tour-3.mp4'),
  ];
  final List<(String, String)> clips;
  final String poster;

  @override
  State<PropertyVideo> createState() => _PropertyVideoState();
}

class _PropertyVideoState extends State<PropertyVideo> {
  int _selected = 0;
  VideoPlayerController? _controller;
  bool _loading = false;

  Future<void> _select(int index) async {
    if (_selected == index) return;
    final old = _controller;
    _controller = null;
    _selected = index;
    _loading = false;
    await old?.dispose();
    if (mounted) setState(() {});
  }

  Future<void> _start() async {
    if (_controller != null) {
      _controller!.play();
      return;
    }
    setState(() => _loading = true);
    final controller = VideoPlayerController.asset(widget.clips[_selected].$2);
    _controller = controller;
    try {
      await controller.initialize();
      await controller.play();
      if (mounted) setState(() => _loading = false);
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    final ready = controller != null && controller.value.isInitialized;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (widget.clips.length > 1)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (var i = 0; i < widget.clips.length; i++) ...[
                  if (i > 0) const SizedBox(width: 8),
                  ChoiceChip(
                    label: Text(widget.clips[i].$1),
                    selected: _selected == i,
                    selectedColor: AppColors.gold.withValues(alpha: .24),
                    onSelected: (_) => _select(i),
                  ),
                ],
              ],
            ),
          ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(17),
          child: !ready
              ? _poster()
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AspectRatio(
                      aspectRatio: controller.value.aspectRatio,
                      child: Directionality(
                        textDirection: TextDirection.ltr,
                        child: VideoPlayer(controller),
                      ),
                    ),
                    ColoredBox(
                      color: const Color(0xFF101820),
                      child: _VideoControls(
                        controller: controller,
                        onFullscreen: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                _FullscreenVideo(controller: controller),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      ],
    );
  }

  Widget _poster() => LayoutBuilder(
    builder: (context, constraints) {
      final width = constraints.maxWidth.clamp(0.0, 760.0);
      final height = width * 16 / 9;
      return SizedBox(
        height: height,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(widget.poster, fit: BoxFit.contain),
            const ColoredBox(color: Colors.black26),
            Center(
              child: _loading
                  ? const CircularProgressIndicator(color: AppColors.gold)
                  : IconButton.filled(
                      tooltip: 'تشغيل الفيديو',
                      onPressed: _start,
                      style: IconButton.styleFrom(
                        backgroundColor: AppColors.gold,
                        foregroundColor: AppColors.navy,
                        iconSize: 33,
                      ),
                      icon: const Icon(Icons.play_arrow_rounded),
                    ),
            ),
            Positioned(
              bottom: 14,
              right: 16,
              child: Text(
                widget.clips[_selected].$1,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}

class _VideoControls extends StatelessWidget {
  const _VideoControls({required this.controller, required this.onFullscreen});
  final VideoPlayerController controller;
  final VoidCallback onFullscreen;
  @override
  Widget build(BuildContext context) =>
      ValueListenableBuilder<VideoPlayerValue>(
        valueListenable: controller,
        builder: (context, value, _) {
          final max = value.duration.inMilliseconds.toDouble().clamp(
            1.0,
            double.infinity,
          );
          final current = value.position.inMilliseconds.toDouble().clamp(
            0.0,
            max,
          );
          return Row(
            children: [
              IconButton(
                color: Colors.white,
                onPressed: () =>
                    value.isPlaying ? controller.pause() : controller.play(),
                icon: Icon(value.isPlaying ? Icons.pause : Icons.play_arrow),
              ),
              Expanded(
                child: Slider(
                  value: current,
                  max: max,
                  activeColor: AppColors.gold,
                  onChanged: (v) =>
                      controller.seekTo(Duration(milliseconds: v.round())),
                ),
              ),
              IconButton(
                color: Colors.white,
                tooltip: 'ملء الشاشة',
                onPressed: onFullscreen,
                icon: const Icon(Icons.fullscreen),
              ),
            ],
          );
        },
      );
}

class _FullscreenVideo extends StatelessWidget {
  const _FullscreenVideo({required this.controller});
  final VideoPlayerController controller;
  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Colors.black,
    appBar: AppBar(
      backgroundColor: Colors.black,
      foregroundColor: Colors.white,
      leading: IconButton(
        icon: const Icon(Icons.close),
        onPressed: () => Navigator.pop(context),
      ),
    ),
    body: Center(
      child: AspectRatio(
        aspectRatio: controller.value.aspectRatio,
        child: VideoPlayer(controller),
      ),
    ),
  );
}
