import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:provider_test/features/dashboard/presentation/pages/settings_screen.dart';
import 'package:provider_test/features/people_management/presentation/pages/home_screen.dart';
import 'package:provider_test/features/tasks/presentation/pages/tasks_screen.dart';
import 'package:provider_test/features/hospitality_staff/presentation/pages/hospitality_staff_screen.dart';


class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 💡 نقرأ النصيحة فقط هنا (لأنها تتغير مرة واحدة ولن تضر الأداء)
    final dailyTip = context.watch<String>();

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        centerTitle: true,
        title: Text(
          'dashboard.home'.tr(),
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsetsDirectional.all(16.0),
        child: Column(
          children: [
            // --- صندوق النصيحة (Future) ---
            Container(
              width: double.infinity,
              padding: const EdgeInsetsDirectional.all(16),
              margin: const EdgeInsetsDirectional.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.blue.shade100),
              ),
              child: Text(
                '💡 $dailyTip',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue, height: 1.5),
                textAlign: TextAlign.center,
              ),
            ),

            // 🌟 --- صندوق العداد الحي (Stream) --- 🌟
            // استدعينا الويدجت المعزول هنا لحماية الشاشة من إعادة البناء المتكرر
            const CountdownWidget(),
            
            const SizedBox(height: 20),

            // --- شبكة الأزرار الثابتة ---
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.1,
                children: [
                  _buildGridCard(
                    context: context,
                    title: 'dashboard.guests'.tr(),
                    icon: Icons.people_alt_rounded,
                    color: Colors.blue,
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const HomeScreen()));
                    },
                  ),
                  _buildGridCard(
                    context: context,
                    title: 'dashboard.preparations'.tr(),
                    icon: Icons.task_alt_rounded,
                    color: Colors.green,
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const TasksScreen()));
                    },
                  ),
                  _buildGridCard(
                    context: context,
                    title: 'dashboard.hospitality'.tr(),
                    icon: Icons.woman,
                    color: Colors.red,
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const HospitalityStaffScreen()));
                    },
                  ),
                  _buildGridCard(
                    context: context,
                    title: 'dashboard.settings'.tr(),
                    icon: Icons.settings,
                    color: Colors.orange,
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsScreen()));
                    },
                  ), 
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGridCard({required BuildContext context, required String title, required IconData icon, required Color color, required VoidCallback onTap}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: color.withOpacity(0.1), blurRadius: 10, spreadRadius: 2, offset: const Offset(0, 4))],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          splashColor: color.withOpacity(0.1),
          highlightColor: color.withOpacity(0.05),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle), child: Icon(icon, size: 40, color: color)),
              const SizedBox(height: 12),
              Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
            ],
          ),
        ),
      ),
    );
  }
}

// 🌟 الكلاس المعزول (الدرع الواقي للأداء)
class CountdownWidget extends StatelessWidget {
  const CountdownWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final timeLeft = context.watch<int>();

    return Container(
      width: double.infinity,
      padding: const EdgeInsetsDirectional.all(16),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.timer, color: Colors.red),
          const SizedBox(width: 8),
          Text(
            'dashboard.days_remaining'.tr(namedArgs: {'days': timeLeft.toString()}),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red),
          ),
        ],
      ),
    );
  }
}
