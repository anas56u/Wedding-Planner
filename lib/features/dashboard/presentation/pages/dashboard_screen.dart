import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:provider_test/features/dashboard/presentation/pages/settings_screen.dart';
import 'package:provider_test/features/people_management/presentation/pages/home_screen.dart';
import 'package:provider_test/features/tasks/presentation/pages/tasks_screen.dart';
import 'package:provider_test/features/hospitality_staff/presentation/pages/hospitality_staff_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  Widget build(BuildContext context) {
    // جلب البيانات من الـ Providers
    final dailyTip = context.watch<String>();
    
    // استخدام الـ Theme للوصول للألوان الموحدة بدلاً من Hardcoding
    final theme = Theme.of(context);

    return Scaffold(
      // نعتمد على لون الخلفية المحدد في AppTheme
      appBar: AppBar(
        title: Text('dashboard.home'.tr()),
        // إضافة زر الإعدادات في الـ AppBar كبديل لبطاقة كاملة في الأسفل (اختياري، لكنه أفضل في الـ UX)
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              ).then((_) => setState(() {}));
            },
          )
        ],
      ),
      // استخدمنا SingleChildScrollView لمنع مشاكل الـ Overflow في الشاشات الصغيرة
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. البطاقة الترحيبية (تدمج العداد والنصيحة)
            _buildWelcomeBanner(context, dailyTip, theme),

            const SizedBox(height: 24),

            // 2. عنوان قسم الخدمات
            Text(
              'الخدمات الأساسية', // يفضل إضافتها لملف الترجمة لاحقاً
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary, // الكحلي الملكي
              ),
            ),
            const SizedBox(height: 16),

            // 3. شبكة الخدمات (GridView)
            // استخدمنا shrinkWrap لنسمح للـ GridView بالعمل داخل ScrollView
            GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.0, // جعل البطاقات مربعة ومتناسقة
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(), // إيقاف التمرير الداخلي للشبكة
              children: [
                _buildServiceCard(
                  context: context,
                  title: 'dashboard.guests'.tr(),
                  icon: Icons.people_alt_rounded,
                  theme: theme,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const HomeScreen()),
                  ),
                ),
                _buildServiceCard(
                  context: context,
                  title: 'dashboard.preparations'.tr(),
                  icon: Icons.task_alt_rounded,
                  theme: theme,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const TasksScreen()),
                  ),
                ),
                _buildServiceCard(
                  context: context,
                  title: 'dashboard.hospitality'.tr(),
                  icon: Icons.room_service_rounded, // أيقونة معبرة أكثر
                  theme: theme,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const HospitalityStaffScreen()),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ويدجت مساعدة لبناء البطاقة الترحيبية (Hero Banner)
Widget _buildWelcomeBanner(BuildContext context, String dailyTip, ThemeData theme) {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [
          theme.colorScheme.primary,
          theme.colorScheme.primary.withOpacity(0.8),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(24),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // 🌟 الحل السحري هنا: تغليف النص بـ Expanded لمنع الـ Overflow وتحويله للترجمة
            Expanded(
              child: Text(
                'dashboard.wedding_approaching'.tr(), // استخدام مفتاح الترجمة بدلاً من النص الثابت
                style: theme.textTheme.titleMedium?.copyWith(
                  color: Colors.white70,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 2, // السماح بنزول النص لسطرين إذا كان طويلاً بالإنجليزية
                overflow: TextOverflow.ellipsis, // وضع نقاط إذا زاد عن سطرين في الشاشات الصغيرة جداً
              ),
            ),
            const SizedBox(width: 12), // مسافة أمان أفقية بين النص والعداد
            const CountdownBadge(),
          ],
        ),
        const SizedBox(height: 20),
        // صندوق النصيحة اليومية...
      ],
    ),
  );
}
  // تصميم جديد وحديث لبطاقات الخدمات (Glassmorphism / Clean Cards)
  Widget _buildServiceCard({
    required BuildContext context,
    required String title,
    required IconData icon,
    required ThemeData theme,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withOpacity(0.08),
            blurRadius: 12,
            spreadRadius: 0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          splashColor: theme.colorScheme.secondary.withOpacity(0.1), // لون سبلاش ذهبي
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.secondary.withOpacity(0.15), // خلفية ذهبية خفيفة للأيقونة
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon, 
                    size: 36, 
                    color: theme.colorScheme.secondary // اللون الذهبي من الـ Theme
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// 🌟 الكلاس المعزول (الدرع الواقي للأداء) تم تعديله ليناسب البطاقة العلوية
class CountdownBadge extends StatelessWidget {
  const CountdownBadge({super.key});

  @override
  Widget build(BuildContext context) {
    final timeLeft = context.watch<int>();
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.secondary, // اللون الذهبي (Accent Rose Gold)
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.timer_outlined, color: Colors.white, size: 18),
          const SizedBox(width: 6),
          Text(
            'dashboard.days_remaining'.tr(
              namedArgs: {'days': timeLeft.toString()},
            ),
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white, // نص أبيض ليبرز فوق اللون الذهبي
            ),
          ),
        ],
      ),
    );
  }
}