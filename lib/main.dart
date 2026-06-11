import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:provider_test/features/dashboard/presentation/pages/dashboard_screen.dart';
import 'package:provider_test/features/hospitality_staff/presentation/providers/hospitality_staff_provider.dart';
import 'package:provider_test/features/tasks/presentation/providers/tasks_provider.dart';
import 'package:provider_test/injection_container.dart' as di;
import 'features/people_management/presentation/providers/people_provider.dart';

Future<String> fetchDailyWeddingTip() async {
  await Future.delayed(const Duration(seconds: 2));
  final tips = [
    "لا تنسَ تأكيد حجز القاعة قبل شهر من الموعد!",
    "ابتسم دائماً، صور الزفاف تدوم للأبد.",
    "تأكد من توزيع المهام ولا تحمل كل العبء وحدك.",
    "خصص وقتاً للراحة قبل يوم الزفاف لتكون بكامل نشاطك.",
  ];
  tips.shuffle(); 
  return tips.first; 
}

Stream<int> weddingCountdownStream() async* {
  int daystoleft = 100; 
  while (daystoleft >= 0) {
    await Future.delayed(const Duration(seconds: 3)); 
    daystoleft--; 
    yield daystoleft; 
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await di.configureDependencies(); 

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => di.sl<HospitalityStaffProvider>()),
        ChangeNotifierProvider(create: (_) => di.sl<TasksProvider>()),

        ChangeNotifierProvider(create:(_) => di.sl<PeopleProvider>()),
        
        FutureProvider<String>( 
          create: (context) => fetchDailyWeddingTip(),
          initialData: 'جاري تحميل نصيحة اليوم...', 
        ),
        StreamProvider<int>(
          create: (context) => weddingCountdownStream(),
          initialData: 100,
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'نظام الفلترة',
      home: DashboardScreen(),
    );
  }
}