import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_themes.dart';
import 'core/theme/theme_provider.dart';
import 'core/storage/secure_storage.dart';
import 'app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await SecureStorageService.instance.init();
  } catch (e) {
    debugPrint('SecureStorage init error: $e');
  }

  String themeId = 'midnight';
  try {
    themeId = await SecureStorageService.instance.getSelectedTheme();
  } catch (e) {
    debugPrint('Theme load error: $e');
  }
  final initialTheme = AppThemes.getById(themeId);

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: initialTheme.background,
    systemNavigationBarIconBrightness: Brightness.light,
  ));

  runApp(
    ProviderScope(
      child: NestShiftApp(initialTheme: initialTheme),
    ),
  );
}

class NestShiftApp extends ConsumerStatefulWidget {
  final AppTheme initialTheme;

  const NestShiftApp({super.key, required this.initialTheme});

  @override
  ConsumerState<NestShiftApp> createState() => _NestShiftAppState();
}

class _NestShiftAppState extends ConsumerState<NestShiftApp> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref.read(themeProvider.notifier).setTheme(widget.initialTheme.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);
    final themeState = ref.watch(themeProvider);

    return MaterialApp.router(
      title: 'NestShift',
      debugShowCheckedModeBanner: false,
      theme: themeState.theme.toThemeData(),
      routerConfig: router,
      builder: (context, child) {
        return Scaffold(
          backgroundColor: widget.initialTheme.background,
          body: child ?? const SizedBox.expand(),
        );
      },
    );
  }
}