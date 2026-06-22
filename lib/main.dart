import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:provider_test/core/providers/language_provider.dart';
import 'package:provider_test/core/services/push_notification_service.dart';
import 'package:provider_test/features/auth/presentation/providers/auth_provider.dart';
import 'package:provider_test/features/hospitality_staff/presentation/providers/hospitality_staff_provider.dart';
import 'package:provider_test/features/splash/presentation/pages/splash_screen.dart';
import 'package:provider_test/features/tasks/presentation/providers/tasks_provider.dart';
import 'package:provider_test/firebase_options.dart';
import 'package:provider_test/injection_container.dart' as di;
import 'features/people_management/presentation/providers/people_provider.dart';
import 'core/theme/app_theme.dart';
import 'core/widgets/global_network_overlay.dart';
import 'features/dashboard/presentation/providers/network_provider.dart';

Future<String> fetchDailyWeddingTip() async {
  await Future.delayed(const Duration(seconds: 2));
  final tips = [
   "الحقونا "
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
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await di.configureDependencies();
  await di.sl<PushNotificationService>().initNotifications();

  await EasyLocalization.ensureInitialized();

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('ar'), Locale('en')],
      path: 'assets/translations',
      fallbackLocale: const Locale('ar'),
      startLocale: const Locale('ar'),
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => di.sl<AuthProvider>()),
         
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
          locale: languageProvider.appLocale,
          theme: AppTheme.lightTheme,

          builder: (context, child) {
            return GlobalNetworkOverlay(child: child!);
          },

          home: const SplashScreen()
        );
      },
    );
  }
}
