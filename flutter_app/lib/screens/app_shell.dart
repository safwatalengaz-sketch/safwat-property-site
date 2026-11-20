import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:go_router/go_router.dart';

import '../app.dart';
import 'about_screen.dart';
import 'catalog_screens.dart';
import 'contact_screen.dart';
import 'home_screen.dart';
import 'works_screen.dart';

enum AppSection {
  home('/'),
  works('/works'),
  apartments('/apartments'),
  buildings('/buildings'),
  properties('/properties'),
  tours('/tours'),
  about('/about'),
  contact('/contact');

  const AppSection(this.path);
  final String path;
}

class SplashGate extends StatefulWidget {
  const SplashGate({super.key, required this.onReady});
  final VoidCallback onReady;
  @override
  State<SplashGate> createState() => _SplashGateState();
}

class _SplashGateState extends State<SplashGate>
    with SingleTickerProviderStateMixin {
  final AudioPlayer _introAudio = AudioPlayer();
  bool _audioStarted = false;
  late final AnimationController _controller;
  late final Animation<double> _scale;
  late final Animation<Offset> _offset;
  double _progress = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );
    _scale = Tween<double>(
      begin: .36,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));
    _offset = Tween<Offset>(begin: const Offset(0, 1.2), end: Offset.zero)
        .animate(
          CurvedAnimation(parent: _controller, curve: Curves.easeInOutCubic),
        );
    _prepare();
  }

  Future<void> _prepare() async {
    _controller.forward();
    _playIntroAudio();
    const core = [
      'assets/logo/safwat-logo.jpeg',
      'assets/images/banners/home-banner.png',
      'assets/images/banners/works-banner.png',
    ];
    for (var i = 0; i < core.length; i++) {
      try {
        await precacheImage(AssetImage(core[i]), context);
      } catch (_) {}
      if (mounted) setState(() => _progress = (i + 1) / core.length);
    }
    if (!mounted) return;
    await _controller.animateTo(
      1,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutCubic,
    );
    if (mounted) widget.onReady();
  }

  Future<void> _playIntroAudio() async {
    if (_audioStarted) return;
    try {
      await _introAudio.play(AssetSource('audio/splash-chime.wav'));
      _audioStarted = true;
    } catch (_) {
      // Browsers may block autoplay until the visitor interacts with the page.
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _introAudio.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.navy,
    body: GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _playIntroAudio,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedBuilder(
              animation: _controller,
              builder: (_, child) => Transform.translate(
                offset: _offset.value * 180,
                child: Transform.scale(scale: _scale.value, child: child),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(22),
                child: Image.asset(
                  'assets/logo/safwat-logo.jpeg',
                  width: 132,
                  height: 132,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: 42,
              height: 42,
              child: CircularProgressIndicator(
                value: _progress == 0 ? null : _progress,
                strokeWidth: 2.5,
                color: AppColors.gold,
                backgroundColor: Colors.white24,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '${(_progress * 100).round()}%',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.section});
  final AppSection section;
  static const destinations = [
    AppSection.home,
    AppSection.works,
    AppSection.about,
    AppSection.contact,
  ];
  static const labels = ['الرئيسية', 'أعمالنا', 'من نحن', 'تواصل'];
  static const icons = [
    Icons.home_rounded,
    Icons.apartment_rounded,
    Icons.info_outline_rounded,
    Icons.chat_bubble_outline_rounded,
  ];

  @override
  Widget build(BuildContext context) {
    void openProperty() => context.go(AppSection.properties.path);
    void select(int index) => context.go(destinations[index].path);
    final selected = switch (section) {
      AppSection.home => 0,
      AppSection.about => 2,
      AppSection.contact => 3,
      _ => 1,
    };
    final content = switch (section) {
      AppSection.home => HomeScreen(
        onOpenProperty: openProperty,
        onOpenWorks: () => select(1),
      ),
      AppSection.works => WorksScreen(onOpenProperty: openProperty),
      AppSection.apartments => const ApartmentsScreen(),
      AppSection.buildings => const BuildingsScreen(),
      AppSection.tours => const ToursScreen(),
      AppSection.about => const AboutScreen(),
      AppSection.contact => const ContactScreen(),
      AppSection.properties => const SizedBox.shrink(),
    };
    final wide = MediaQuery.sizeOf(context).width >= 760;
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 18,
        title: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                'assets/logo/safwat-logo.jpeg',
                width: 38,
                height: 38,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(width: 10),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'صفوة الإنجاز',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                ),
                Text(
                  'للخدمات العقارية',
                  style: TextStyle(fontSize: 10, color: AppColors.muted),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'اتصال',
            onPressed: () => ContactScreen.call(context),
            icon: const Icon(Icons.call_outlined, color: AppColors.gold),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (!wide) return content;
          return Row(
            children: [
              Expanded(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 760),
                    child: content,
                  ),
                ),
              ),
              NavigationRail(
                selectedIndex: selected,
                onDestinationSelected: select,
                labelType: NavigationRailLabelType.all,
                destinations: List.generate(
                  4,
                  (i) => NavigationRailDestination(
                    icon: Icon(icons[i]),
                    selectedIcon: Icon(icons[i]),
                    label: Text(labels[i]),
                  ),
                ),
                backgroundColor: Colors.white,
                indicatorColor: AppColors.gold.withValues(alpha: .2),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: wide
          ? null
          : _FloatingNav(index: selected, onSelect: select),
    );
  }
}

class _FloatingNav extends StatelessWidget {
  static const labels = ['الرئيسية', 'أعمالنا', 'من نحن', 'تواصل'];
  static const icons = [
    Icons.home_rounded,
    Icons.apartment_rounded,
    Icons.info_outline_rounded,
    Icons.chat_bubble_outline_rounded,
  ];
  const _FloatingNav({required this.index, required this.onSelect});
  final int index;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) => SafeArea(
    top: false,
    minimum: const EdgeInsets.fromLTRB(22, 0, 22, 10),
    child: Container(
      height: 66,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(36),
        border: Border.all(color: AppColors.line),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A102B3F),
            blurRadius: 22,
            offset: Offset(0, 7),
          ),
        ],
      ),
      child: Row(
        children: List.generate(4, (i) {
          final selected = i == index;
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 5),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => onSelect(i),
                  borderRadius: BorderRadius.circular(30),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeOutCubic,
                    decoration: BoxDecoration(
                      color: selected
                          ? AppColors.gold.withValues(alpha: .18)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AnimatedScale(
                          scale: selected ? 1.08 : 1,
                          duration: const Duration(milliseconds: 200),
                          child: Icon(
                            icons[i],
                            color: selected ? AppColors.navy : AppColors.muted,
                            size: 21,
                          ),
                        ),
                        const SizedBox(height: 2),
                        AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 200),
                          style: TextStyle(
                            fontSize: 10,
                            color: selected ? AppColors.navy : AppColors.muted,
                            fontWeight: selected
                                ? FontWeight.w700
                                : FontWeight.w500,
                          ),
                          child: Text(labels[i]),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    ),
  );
}
