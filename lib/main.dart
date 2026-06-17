import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:provider_test/core/providers/Language_Provider.dart';
import 'package:provider_test/features/auth/presentation/providers/auth_provider.dart';
import 'package:provider_test/features/auth/presentation/screens/login_screen.dart';
import 'package:provider_test/features/dashboard/presentation/pages/dashboard_screen.dart';
import 'package:provider_test/features/hospitality_staff/presentation/providers/hospitality_staff_provider.dart';
import 'package:provider_test/features/tasks/presentation/providers/tasks_provider.dart';
import 'package:provider_test/firebase_options.dart';
import 'package:provider_test/injection_container.dart' as di;
import 'features/people_management/presentation/providers/people_provider.dart';
import 'core/theme/app_theme.dart';
import 'core/widgets/global_network_overlay.dart';
import 'features/dashboard/presentation/provider/network_provider.dart';

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
    await Future.delayed(const Duration(seconds: 1));
    daystoleft--;
    yield daystoleft;
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await EasyLocalization.ensureInitialized();

  await di.configureDependencies();

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('ar'), Locale('en')],
      path: 'assets/translations',
      fallbackLocale: const Locale('ar'),
      startLocale: const Locale('ar'),
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider(
      create: (_) => di.sl<AuthProvider>()..checkAuthStatus(),),
          ChangeNotifierProvider(create: (_) => LanguageProvider()),
          ChangeNotifierProvider(
            create: (_) => di.sl<HospitalityStaffProvider>(),
          ),
          ChangeNotifierProvider(create: (_) => di.sl<TasksProvider>()),
          ChangeNotifierProvider(create: (_) => di.sl<PeopleProvider>()),

          ChangeNotifierProvider(create: (_) => NetworkProvider()),

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
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<LanguageProvider>(
      builder: (context, languageProvider, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'مساعد الزفاف',

          localizationsDelegates: context.localizationDelegates,
          supportedLocales: context.supportedLocales,
          locale: context.locale,
          theme: AppTheme.lightTheme,

          builder: (context, child) {
            return GlobalNetworkOverlay(child: child!);
          },

          home: Consumer<AuthProvider>(
  builder: (context, authProvider, _) {
    if (authProvider.isAuthenticated) {
      return const DashboardScreen();
    }
    return const LoginScreen();
  },
),
        );
      },
    );
  }
}
