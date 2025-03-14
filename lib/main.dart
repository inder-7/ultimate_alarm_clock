import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:ultimate_alarm_clock/app/data/providers/get_storage_provider.dart';
import 'package:ultimate_alarm_clock/app/modules/settings/controllers/theme_controller.dart';

import 'package:ultimate_alarm_clock/app/utils/language.dart';
import 'package:ultimate_alarm_clock/app/utils/constants.dart';
import 'package:ultimate_alarm_clock/app/utils/custom_error_screen.dart';
import 'app/routes/app_pages.dart';

import 'package:dynamic_color/dynamic_color.dart';

Locale? loc;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Permission.notification.isDenied.then((value) {
    if (value) {
      Permission.notification.request();
    }
  });

  await Firebase.initializeApp();

  await Get.putAsync(() => GetStorageProvider().init());

  final storage = Get.find<GetStorageProvider>();
  loc = await storage.readLocale();

  final ThemeController themeController = Get.put(ThemeController());

  AudioPlayer.global.setAudioContext(
    const AudioContext(
      android: AudioContextAndroid(
        audioMode: AndroidAudioMode.ringtone,
        contentType: AndroidContentType.music,
        usageType: AndroidUsageType.alarm,
        audioFocus: AndroidAudioFocus.gainTransient,
      ),
    ),
  );

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(statusBarColor: Colors.transparent),
  );
  runApp(
    const UltimateAlarmClockApp(),
  );
}

class UltimateAlarmClockApp extends StatelessWidget {
  const UltimateAlarmClockApp({super.key});

  @override
  Widget build(BuildContext context) {
    return DynamicColorBuilder(
      builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
        // Create color schemes based on dynamic color or fall back to app's defined themes
        final ThemeData lightTheme = _createLightTheme(lightDynamic);
        final ThemeData darkTheme = _createDarkTheme(darkDynamic);

        return Obx(() {
          return GetMaterialApp(
            theme: lightTheme,
            darkTheme: darkTheme,
            themeMode: Get.find<ThemeController>().currentTheme.value,
            title: 'UltiClock',
            initialRoute: AppPages.INITIAL,
            getPages: AppPages.routes,
            translations: AppTranslations(),
            locale: loc,
            fallbackLocale: const Locale('en', 'US'),
            builder: (BuildContext context, Widget? error) {
              ErrorWidget.builder = (FlutterErrorDetails? error) {
                return CustomErrorScreen(errorDetails: error!);
              };
              return error!;
            },
          );
        });
      },
    );
  }

  // Create light theme based on dynamic color or fallback to app's light theme
  ThemeData _createLightTheme(ColorScheme? lightDynamic) {
    if (lightDynamic != null) {
      return ThemeData(
        useMaterial3: true,
        colorScheme: lightDynamic.harmonized(),
        // Transfer your existing light theme properties to the dynamic theme
        fontFamily: 'poppins',
        textTheme: _createTextTheme(lightDynamic, false),
        sliderTheme: SliderThemeData(
          thumbColor: lightDynamic.primary,
          activeTrackColor: lightDynamic.primary,
          inactiveTrackColor: lightDynamic.onSurface.withOpacity(0.3),
        ),
        checkboxTheme: CheckboxThemeData(
          checkColor: MaterialStateProperty.all(kLightPrimaryTextColor),
          fillColor: MaterialStateProperty.all(lightDynamic.surface),
        ),
        inputDecorationTheme: InputDecorationTheme(
          hintStyle: TextStyle(color: lightDynamic.onSurface.withOpacity(0.5)),
          labelStyle: TextStyle(color: lightDynamic.onSurface),
          focusColor: lightDynamic.onSurface,
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: lightDynamic.primary),
            borderRadius: BorderRadius.circular(12),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: lightDynamic.primary),
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: ButtonStyle(
            backgroundColor: const MaterialStatePropertyAll(Colors.transparent),
            side: MaterialStatePropertyAll(
                BorderSide(color: lightDynamic.primary)),
          ),
        ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          elevation: 0,
          backgroundColor: lightDynamic.surface,
          selectedLabelStyle: TextStyle(
            color: lightDynamic.primary,
            shadows: const [
              Shadow(
                color: Color.fromARGB(120, 0, 0, 0),
                offset: Offset(1, 1),
                blurRadius: 10.0,
              ),
              Shadow(
                color: Color.fromARGB(120, 0, 0, 0),
                offset: Offset(1, -1),
                blurRadius: 10.0,
              ),
              Shadow(
                color: Color.fromARGB(120, 0, 0, 0),
                offset: Offset(-1, 1),
                blurRadius: 10.0,
              ),
              Shadow(
                color: Color.fromARGB(120, 0, 0, 0),
                offset: Offset(-1, -1),
                blurRadius: 10.0,
              ),
            ],
          ),
          unselectedLabelStyle: TextStyle(
            color: lightDynamic.onSurface,
          ),
          selectedIconTheme: IconThemeData(
            color: lightDynamic.primary,
            shadows: const [
              Shadow(
                color: Color.fromARGB(100, 0, 0, 0),
                offset: Offset(1, 1),
                blurRadius: 10.0,
              ),
              Shadow(
                color: Color.fromARGB(100, 0, 0, 0),
                offset: Offset(1, -1),
                blurRadius: 10.0,
              ),
              Shadow(
                color: Color.fromARGB(100, 0, 0, 0),
                offset: Offset(-1, 1),
                blurRadius: 10.0,
              ),
              Shadow(
                color: Color.fromARGB(100, 0, 0, 0),
                offset: Offset(-1, -1),
                blurRadius: 10.0,
              ),
            ],
          ),
          unselectedIconTheme: IconThemeData(
            color: lightDynamic.onSurface,
          ),
        ),
      );
    } else {
      // Fall back to the app's predefined light theme
      return kLightThemeData;
    }
  }

  // Create dark theme based on dynamic color or fallback to app's dark theme
  ThemeData _createDarkTheme(ColorScheme? darkDynamic) {
    if (darkDynamic != null) {
      return ThemeData(
        useMaterial3: true,
        colorScheme: darkDynamic.harmonized(),
        // Transfer your existing dark theme properties to the dynamic theme
        fontFamily: 'poppins',
        textTheme: _createTextTheme(darkDynamic, true),
        sliderTheme: SliderThemeData(
          thumbColor: darkDynamic.primary,
          activeTrackColor: darkDynamic.primary,
          inactiveTrackColor: darkDynamic.onSurface.withOpacity(0.3),
        ),
        checkboxTheme: CheckboxThemeData(
          checkColor: MaterialStateProperty.all(kprimaryTextColor),
          fillColor: MaterialStateProperty.all(darkDynamic.surface),
        ),
        inputDecorationTheme: InputDecorationTheme(
          hintStyle: TextStyle(color: darkDynamic.onSurface.withOpacity(0.5)),
          labelStyle: TextStyle(color: darkDynamic.onSurface),
          focusColor: darkDynamic.onSurface,
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: darkDynamic.primary),
            borderRadius: BorderRadius.circular(12),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: darkDynamic.primary),
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: ButtonStyle(
            backgroundColor: const MaterialStatePropertyAll(Colors.transparent),
            side: MaterialStatePropertyAll(
                BorderSide(color: darkDynamic.primary)),
          ),
        ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          elevation: 0,
          backgroundColor: darkDynamic.surface,
          selectedLabelStyle: TextStyle(
            color: darkDynamic.primary,
            shadows: const [
              Shadow(
                color: Color.fromARGB(90, 255, 255, 255),
                offset: Offset(1, 1),
                blurRadius: 10.0,
              ),
              Shadow(
                color: Color.fromARGB(90, 255, 255, 255),
                offset: Offset(1, -1),
                blurRadius: 10.0,
              ),
              Shadow(
                color: Color.fromARGB(90, 255, 255, 255),
                offset: Offset(-1, 1),
                blurRadius: 10.0,
              ),
              Shadow(
                color: Color.fromARGB(90, 255, 255, 255),
                offset: Offset(-1, -1),
                blurRadius: 10.0,
              ),
            ],
          ),
          unselectedLabelStyle: TextStyle(
            color: darkDynamic.onSurface,
          ),
          selectedIconTheme: IconThemeData(
            color: darkDynamic.primary,
            shadows: const [
              Shadow(
                color: Color.fromARGB(90, 255, 255, 255),
                offset: Offset(1, 1),
                blurRadius: 10.0,
              ),
              Shadow(
                color: Color.fromARGB(90, 255, 255, 255),
                offset: Offset(1, -1),
                blurRadius: 10.0,
              ),
              Shadow(
                color: Color.fromARGB(90, 255, 255, 255),
                offset: Offset(-1, 1),
                blurRadius: 10.0,
              ),
              Shadow(
                color: Color.fromARGB(90, 255, 255, 255),
                offset: Offset(-1, -1),
                blurRadius: 10.0,
              ),
            ],
          ),
          unselectedIconTheme: IconThemeData(
            color: darkDynamic.onSurface,
          ),
        ),
      );
    } else {
      // Fall back to the app's predefined dark theme
      return kThemeData;
    }
  }

  // Create text theme based on color scheme
  TextTheme _createTextTheme(ColorScheme colorScheme, bool isDark) {
    final textColor = colorScheme.onSurface;

    return TextTheme(
      titleSmall: TextStyle(color: textColor, letterSpacing: 0.15),
      titleMedium: TextStyle(color: textColor, letterSpacing: 0.15),
      titleLarge: TextStyle(color: textColor, letterSpacing: 0.15),
      bodySmall: TextStyle(color: textColor, letterSpacing: 0.15),
      bodyMedium: TextStyle(color: textColor, letterSpacing: 0.15),
      bodyLarge: TextStyle(color: textColor, letterSpacing: 0.15),
      displaySmall: TextStyle(
        fontSize: 16,
        color: textColor,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.15,
      ),
      displayLarge: TextStyle(
        fontSize: 28,
        color: textColor,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.15,
      ),
      displayMedium: TextStyle(
        fontSize: 23,
        color: textColor,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.15,
      ),
    );
  }
}