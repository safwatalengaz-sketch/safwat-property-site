import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../analytics/marketing.dart';
import '../app.dart';

class MeasurementWelcome extends StatelessWidget {
  const MeasurementWelcome({
    super.key,
    required this.canChooseMeasurement,
    required this.onClose,
  });

  final bool canChooseMeasurement;
  final ValueChanged<bool> onClose;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 7, sigmaY: 7),
          child: const ModalBarrier(
            dismissible: false,
            color: Color(0x60102B3F),
          ),
        ),
        SafeArea(
          minimum: const EdgeInsets.all(20),
          child: Center(
            child: SingleChildScrollView(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 410),
                child: FocusScope(
                  autofocus: true,
                  child: Semantics(
                    scopesRoute: true,
                    namesRoute: true,
                    label: 'تفاصيل العقار',
                    explicitChildNodes: true,
                    child: Material(
                      color: Colors.white,
                      elevation: 12,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(22)),
                        side: BorderSide(color: AppColors.gold),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Image.asset(
                              'assets/logo/safwat-logo.jpeg',
                              width: 76,
                              height: 76,
                              fit: BoxFit.contain,
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              'لمشاهدة تفاصيل العقار، اضغط على الزر أدناه',
                              textAlign: TextAlign.center,
                            ),
                            if (canChooseMeasurement) ...[
                              const SizedBox(height: 6),
                              const Text(
                                'بالضغط على «افتح العقار»، توافق على قياس مشاهدات الصفحات ونقرات واتساب والهاتف عبر جوجل وسناب شات وتيك توك.',
                                textAlign: TextAlign.center,
                              ),
                              TextButton(
                                onPressed: () => onClose(false),
                                child: const Text('متابعة دون قياس'),
                              ),
                            ],
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              child: FilledButton(
                                onPressed: () => onClose(canChooseMeasurement),
                                child: const Text('افتح العقار'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class PrivacyLink extends StatelessWidget {
  const PrivacyLink({super.key});

  @override
  Widget build(BuildContext context) => TextButton(
    onPressed: () => context.push(PrivacyScreen.path),
    child: const Text('الخصوصية والقياس'),
  );
}

class PrivacyScreen extends StatefulWidget {
  const PrivacyScreen({super.key});

  static const path = '/privacy';

  @override
  State<PrivacyScreen> createState() => _PrivacyScreenState();
}

class _PrivacyScreenState extends State<PrivacyScreen> {
  void _choose(bool allow) {
    Marketing.setAllowed(allow);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = Marketing.privacyState;
    final status = switch (state) {
      'allow' => 'اختيارك الحالي: السماح بالقياس الإعلاني.',
      'deny' => 'اختيارك الحالي: رفض القياس الإعلاني.',
      'blocked' => 'إشارة الخصوصية في متصفحك توقف القياس الإعلاني.',
      'unavailable' => 'إعدادات القياس غير متاحة في هذه الجلسة.',
      _ => 'لم تحفظ اختيارًا بعد.',
    };

    return Scaffold(
      appBar: AppBar(
        title: const Text('الخصوصية والقياس'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_forward_rounded),
          tooltip: 'رجوع',
          onPressed: () => context.canPop() ? context.pop() : context.go('/'),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(18, 28, 62, 32),
            children: [
              Text(
                'خيارات القياس الإعلاني',
                style: theme.textTheme.headlineSmall,
              ),
              const SizedBox(height: 12),
              const Text(
                'قبل اختيارك، قد ترسل Google Ads إشارات محدودة عن مشاهدة الصفحات وضغطات واتساب والهاتف دون استخدام ملفات تعريف الارتباط الإعلانية. '
                'إذا اخترت السماح، تستخدم Google Ads وسناب شات وتيك توك هذه الأحداث لقياس أداء الإعلانات.',
              ),
              const SizedBox(height: 10),
              const Text(
                'عند الرفض يتوقف إرسال أحداث القياس الإعلاني من هذا المتصفح. يمكنك تغيير اختيارك هنا في أي وقت، ويظل التواصل متاحًا في الحالتين.',
              ),
              const SizedBox(height: 20),
              Semantics(liveRegion: true, child: Text(status)),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 8,
                children: [
                  OutlinedButton(
                    onPressed:
                        state == 'allow' ||
                            state == 'blocked' ||
                            state == 'unavailable'
                        ? null
                        : () => _choose(true),
                    child: const Text('السماح بالقياس الإعلاني'),
                  ),
                  OutlinedButton(
                    onPressed: state == 'deny' || state == 'unavailable'
                        ? null
                        : () => _choose(false),
                    child: const Text('رفض القياس الإعلاني'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
