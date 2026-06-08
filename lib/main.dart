import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:grad_project/core/cubit/auth_cubit.dart';
import 'package:grad_project/core/cubit/language_cubit.dart';
import 'package:grad_project/core/cubit/theme_cubit.dart';
import 'package:grad_project/core/theme/app_theme.dart';
import 'package:grad_project/core/network/api_client.dart';
import 'package:grad_project/firebase_options.dart';
import 'package:grad_project/l10n/app_localizations.dart';
import 'package:grad_project/patient/features/patient/data/repositories/patient_repository_impl.dart';
import 'package:grad_project/splash.dart';
import 'package:grad_project/patient/features/patient/viewmodel/patient_cubit.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await ApiClient.instance.init();
  // Resolve saved theme + locale before the first frame to avoid a flash of
  // the wrong appearance on cold start.
  final initialThemeMode = await ThemeCubit.readSaved();
  final initialLocale = await LanguageCubit.readSaved();
  runApp(MyApp(initialThemeMode: initialThemeMode, initialLocale: initialLocale));
}

class MyApp extends StatelessWidget {
  final ThemeMode initialThemeMode;
  final Locale initialLocale;

  const MyApp({
    super.key,
    this.initialThemeMode = ThemeMode.light,
    this.initialLocale = const Locale('en'),
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthCubit>(create: (_) => AuthCubit()),
        BlocProvider<PatientCubit>(
          create: (_) => PatientCubit(PatientRepositoryImpl()),
        ),
        BlocProvider<ThemeCubit>(
          create: (_) => ThemeCubit(initialThemeMode),
        ),
        BlocProvider<LanguageCubit>(
          create: (_) => LanguageCubit(initialLocale),
        ),
      ],
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, themeMode) {
          return BlocBuilder<LanguageCubit, Locale>(
            builder: (context, locale) {
              return MaterialApp(
                title: 'Health Rootz',
                debugShowCheckedModeBanner: false,
                // ── Theme ──────────────────────────────────────────────
                theme: AppTheme.lightTheme,
                darkTheme: AppTheme.darkTheme,
                themeMode: themeMode,
                // ── Localizations ──────────────────────────────────────
                locale: locale,
                localizationsDelegates: const [
                  AppLocalizations.delegate,
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                ],
                supportedLocales: AppLocalizations.supportedLocales,
                home: const SplashScreen(),
              );
            },
          );
        },
      ),
    );
  }
}
