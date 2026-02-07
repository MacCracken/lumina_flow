import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'dart:io';

import 'themes/app_theme.dart';
import 'screens/home_screen.dart';
import 'services/task_service.dart';
import 'services/desktop_integration.dart';
import 'services/sync_service.dart';
import 'models/task.dart';
import 'models/ritual.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive
  await Hive.initFlutter();
  Hive.registerAdapter(TaskAdapter());
  Hive.registerAdapter(RitualAdapter());
  
  // Open boxes
  await Hive.openBox<Task>('tasks');
  await Hive.openBox<Ritual>('rituals');
  await Hive.openBox('settings');

  // Initialize desktop integration
  if (Platform.isMacOS || Platform.isLinux || Platform.isWindows) {
    await DesktopIntegration.initializeWindowManager();
    await DesktopIntegration.setupSystemTray();
  }

  runApp(const LuminaFlowApp());
}

class LuminaFlowApp extends StatelessWidget {
  const LuminaFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TaskService()),
        ChangeNotifierProvider(create: (_) => ThemeService()),
        ChangeNotifierProvider(create: (_) => SyncService()),
      ],
      child: Consumer<ThemeService>(
        builder: (context, themeService, child) {
          return MaterialApp(
            title: 'Lumina Flow',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.vibrantTheme,
            darkTheme: AppTheme.vibrantDarkTheme,
            themeMode: themeService.isEReaderMode 
                ? ThemeMode.light 
                : ThemeMode.system,
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('en', ''),
            ],
            home: const HomeScreen(),
            builder: (context, child) {
              return themeService.isEReaderMode
                  ? AppTheme.applyEReaderTheme(context, child!)
                  : child!;
            },
          );
        },
      ),
    );
  }
}