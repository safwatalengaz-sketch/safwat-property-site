import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

import 'analytics/marketing.dart';
import 'data/property_data.dart';
import 'data/salam_offer.dart';
import 'screens/app_shell.dart';
import 'screens/contact_screen.dart';
import 'screens/property_details_screen.dart';

class AppColors {
  static const navy = Color(0xFF102B3F);
  static const gold = Color(0xFFC5A15D);
  static const background = Color(0xFFF6F7F9);
  static const ink = Color(0xFF1B2731);
  static const muted = Color(0xFF77818A);
  static const line = Color(0xFFE8EBED);
}

class SafwatApp extends StatefulWidget {
  const SafwatApp({super.key});

  @override
  State<SafwatApp> createState() => _SafwatAppState();
}

class _SafwatAppState extends State<SafwatApp> {
  bool _showSplash = true;
  late final GoRouter _router = GoRouter(
    routes: [
      GoRoute(
        path: PropertyData.buildingPath,
        builder: (context, state) => const _MeasuredScreen(
          path: PropertyData.buildingPath,
          child: PropertyDetailsScreen(isBuilding: true),
        ),
      ),
      GoRoute(
        path: SalamOffer.path,
        builder: (context, state) => const _MeasuredScreen(
          path: SalamOffer.path,
          child: PropertyDetailsScreen(isSalamOffer: true),
        ),
      ),
      for (final section in AppSection.values)
        GoRoute(
          path: section.path,
          builder: (context, state) {
            final screen = section == AppSection.properties
                ? const PropertyDetailsScreen()
                : AppShell(section: section);
            return _MeasuredScreen(path: section.path, child: screen);
          },
        ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: TextButton(
          onPressed: () => context.go(AppSection.home.path),
          child: const Text('العودة إلى الرئيسية'),
        ),
      ),
    ),
  );

  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.navy,
      primary: AppColors.navy,
      secondary: AppColors.gold,
      surface: Colors.white,
    );
    return MaterialApp.router(
      routerConfig: _router,
      title: 'صفوة الإنجاز العقارية',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Tajawal',
        colorScheme: scheme,
        scaffoldBackgroundColor: AppColors.background,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: AppColors.ink,
          elevation: 0,
          centerTitle: false,
        ),
        textTheme: const TextTheme(
          displayLarge: TextStyle(
            fontSize: 40,
            fontWeight: FontWeight.w900,
            height: 1.2,
          ),
          headlineLarge: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w900,
            height: 1.25,
          ),
          headlineMedium: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            height: 1.35,
          ),
          titleLarge: TextStyle(
            fontSize: 23,
            fontWeight: FontWeight.w800,
            height: 1.4,
          ),
          titleMedium: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            height: 1.4,
          ),
          titleSmall: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          bodyLarge: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            height: 1.85,
          ),
          bodyMedium: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            height: 1.75,
          ),
          bodySmall: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            height: 1.6,
          ),
          labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
          labelMedium: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
        ),
      ),
      builder: (context, child) => Directionality(
        textDirection: TextDirection.rtl,
        child: Stack(
          fit: StackFit.expand,
          children: [
            ?child,
            if (_showSplash)
              SplashGate(onReady: () => setState(() => _showSplash = false)),
          ],
        ),
      ),
    );
  }
}

class _MeasuredScreen extends StatefulWidget {
  const _MeasuredScreen({required this.path, required this.child});

  final String path;
  final Widget child;

  @override
  State<_MeasuredScreen> createState() => _MeasuredScreenState();
}

class _MeasuredScreenState extends State<_MeasuredScreen> {
  @override
  void initState() {
    super.initState();
    _record();
  }

  @override
  void didUpdateWidget(covariant _MeasuredScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.path != oldWidget.path) _record();
  }

  void _record() => WidgetsBinding.instance.addPostFrameCallback((_) {
    if (mounted && ModalRoute.of(context)?.isCurrent == true) {
      Marketing.page(widget.path);
    }
  });

  @override
  Widget build(BuildContext context) => Stack(
    fit: StackFit.expand,
    children: [
      widget.child,
      SafeArea(
        minimum: const EdgeInsets.only(right: 8),
        child: Align(
          alignment: Alignment.centerRight,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton.filled(
                tooltip: 'تواصل عبر واتساب',
                style: IconButton.styleFrom(
                  minimumSize: const Size.square(48),
                  backgroundColor: const Color(0xFF087648),
                  foregroundColor: Colors.white,
                ),
                onPressed: () => ContactScreen.whatsapp(context),
                icon: const FaIcon(FontAwesomeIcons.whatsapp, size: 24),
              ),
              const SizedBox(height: 8),
              IconButton.filled(
                tooltip: 'اتصل بنا',
                style: IconButton.styleFrom(
                  minimumSize: const Size.square(48),
                  backgroundColor: AppColors.navy,
                  foregroundColor: Colors.white,
                ),
                onPressed: () => ContactScreen.call(context),
                icon: const Icon(Icons.call_rounded, size: 23),
              ),
            ],
          ),
        ),
      ),
    ],
  );
}
