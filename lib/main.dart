// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import 'utils/routes.dart';
import 'providers/auth_provider.dart';
import 'services/enhanced_firebase_service.dart';
import 'services/storage_service.dart';
import 'utils/colors.dart';

void main() async {
  // Ensure Flutter binding is initialized
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize storage service
  await StorageService.init();
  
  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
    ),
  );

  // Global navigation key for Firebase notifications
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  
  try {
    // Initialize Enhanced Firebase Notification Service
    await EnhancedFirebaseNotificationService.initialize(navKey: navigatorKey);
    print('✅ Firebase notification service initialized successfully');
  } catch (e) {
    print('❌ Failed to initialize Firebase notification service: $e');
    // App should still work without notifications
  }

  runApp(ReUseMartApp(navigatorKey: navigatorKey));
}

class ReUseMartApp extends StatelessWidget {
  final GlobalKey<NavigatorState> navigatorKey;
  
  const ReUseMartApp({
    Key? key, 
    required this.navigatorKey,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider(),
        ),
        // Add other providers here if needed
      ],
      child: MaterialApp(
        // App Configuration
        title: 'ReUseMart',
        debugShowCheckedModeBanner: false,
        
        // Navigation
        navigatorKey: navigatorKey,
        initialRoute: AppRoutes.splash,
        routes: AppRoutes.routes,
        onGenerateRoute: AppRoutes.generateRoute,
        
        // Theme Configuration
        theme: ThemeData(
          // Primary Color Scheme
          primarySwatch: _createMaterialColor(AppColors.primary),
          primaryColor: AppColors.primary,
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppColors.primary,
            brightness: Brightness.light,
          ),
          
          // Typography
          textTheme: GoogleFonts.interTextTheme(
            Theme.of(context).textTheme,
          ),
          
          // AppBar Theme
          appBarTheme: const AppBarTheme(
            elevation: 0,
            centerTitle: true,
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.white,
            systemOverlayStyle: SystemUiOverlayStyle(
              statusBarColor: Colors.transparent,
              statusBarIconBrightness: Brightness.light,
            ),
          ),
          
          // Button Themes
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.white,
              elevation: 2,
              shadowColor: AppColors.primary.withOpacity(0.3),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
            ),
          ),
          
          outlinedButtonTheme: OutlinedButtonThemeData(
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: const BorderSide(
                color: AppColors.primary,
                width: 1.5,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
            ),
          ),
          
          // Input Decoration Theme
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: AppColors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppColors.greyLight,
                width: 1.5,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppColors.greyLight,
                width: 1.5,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppColors.primary,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppColors.error,
                width: 1.5,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppColors.error,
                width: 2,
              ),
            ),
          ),
          
          // Card Theme
          cardTheme: CardThemeData(
            elevation: 2,
            shadowColor: AppColors.black.withOpacity(0.1),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            color: AppColors.white,
          ),
          
          // Bottom Navigation Bar Theme
          bottomNavigationBarTheme: const BottomNavigationBarThemeData(
            backgroundColor: AppColors.white,
            selectedItemColor: AppColors.primary,
            unselectedItemColor: AppColors.grey,
            type: BottomNavigationBarType.fixed,
            elevation: 8,
          ),
          
          // Dialog Theme
          dialogTheme: const DialogThemeData(
            backgroundColor: AppColors.white,
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(16)),
            ),
          ),
          
          // Scaffold Background
          scaffoldBackgroundColor: AppColors.greyLight,
          
          // Divider Theme
          dividerTheme: const DividerThemeData(
            color: AppColors.greyLight,
            thickness: 1,
          ),
          
          // Progress Indicator Theme
          progressIndicatorTheme: const ProgressIndicatorThemeData(
            color: AppColors.primary,
          ),
          
          // Snackbar Theme
          snackBarTheme: SnackBarThemeData(
            backgroundColor: AppColors.greyDark,
            contentTextStyle: const TextStyle(
              color: AppColors.white,
              fontSize: 14,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            behavior: SnackBarBehavior.floating,
          ),
          
          // Switch Theme
          switchTheme: SwitchThemeData(
            thumbColor: MaterialStateProperty.resolveWith((states) {
              if (states.contains(MaterialState.selected)) {
                return AppColors.primary;
              }
              return AppColors.grey;
            }),
            trackColor: MaterialStateProperty.resolveWith((states) {
              if (states.contains(MaterialState.selected)) {
                return AppColors.primary.withOpacity(0.3);
              }
              return AppColors.greyLight;
            }),
          ),
          
          // Checkbox Theme
          checkboxTheme: CheckboxThemeData(
            fillColor: MaterialStateProperty.resolveWith((states) {
              if (states.contains(MaterialState.selected)) {
                return AppColors.primary;
              }
              return Colors.transparent;
            }),
            checkColor: MaterialStateProperty.all(AppColors.white),
            side: const BorderSide(
              color: AppColors.grey,
              width: 1.5,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          
          // Radio Theme
          radioTheme: RadioThemeData(
            fillColor: MaterialStateProperty.resolveWith((states) {
              if (states.contains(MaterialState.selected)) {
                return AppColors.primary;
              }
              return AppColors.grey;
            }),
          ),
          
          // Floating Action Button Theme
          floatingActionButtonTheme: const FloatingActionButtonThemeData(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.white,
            elevation: 4,
          ),
          
          // Tab Bar Theme
          tabBarTheme: const TabBarThemeData(
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.grey,
            indicatorColor: AppColors.primary,
            indicatorSize: TabBarIndicatorSize.label,
          ),
          
          // List Tile Theme
          listTileTheme: const ListTileThemeData(
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            minLeadingWidth: 24,
          ),
          
          // Icon Theme
          iconTheme: const IconThemeData(
            color: AppColors.grey,
            size: 24,
          ),
          
          // Primary Icon Theme
          primaryIconTheme: const IconThemeData(
            color: AppColors.white,
            size: 24,
          ),
          
          // Text Selection Theme
          textSelectionTheme: const TextSelectionThemeData(
            cursorColor: AppColors.primary,
            selectionColor: AppColors.primaryLight,
            selectionHandleColor: AppColors.primary,
          ),
          
          // Tooltip Theme
          tooltipTheme: TooltipThemeData(
            decoration: BoxDecoration(
              color: AppColors.greyDark,
              borderRadius: BorderRadius.circular(8),
            ),
            textStyle: const TextStyle(
              color: AppColors.white,
              fontSize: 12,
            ),
          ),
          
          // Chip Theme
          chipTheme: ChipThemeData(
            backgroundColor: AppColors.greyLight,
            selectedColor: AppColors.primary.withOpacity(0.2),
            labelStyle: const TextStyle(
              color: AppColors.greyDark,
              fontSize: 12,
            ),
            secondaryLabelStyle: const TextStyle(
              color: AppColors.primary,
              fontSize: 12,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          
          // Banner Theme
          bannerTheme: const MaterialBannerThemeData(
            backgroundColor: AppColors.accent,
            contentTextStyle: TextStyle(
              color: AppColors.greyDark,
              fontSize: 14,
            ),
          ),
          
          // Bottom Sheet Theme
          bottomSheetTheme: const BottomSheetThemeData(
            backgroundColor: AppColors.white,
            modalBackgroundColor: AppColors.white,
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(16),
              ),
            ),
          ),
          
          // Data Table Theme
          dataTableTheme: DataTableThemeData(
            headingRowColor: MaterialStateProperty.all(AppColors.greyLight),
            dataRowColor: MaterialStateProperty.all(AppColors.white),
            dividerThickness: 1,
            columnSpacing: 24,
            horizontalMargin: 16,
            checkboxHorizontalMargin: 12,
          ),
          
          // Time Picker Theme
          timePickerTheme: TimePickerThemeData(
            backgroundColor: AppColors.white,
            dialBackgroundColor: AppColors.greyLight,
            dialHandColor: AppColors.primary,
            dialTextColor: AppColors.greyDark,
            entryModeIconColor: AppColors.primary,
            hourMinuteColor: AppColors.greyLight,
            hourMinuteTextColor: AppColors.greyDark,
            dayPeriodColor: AppColors.primary.withOpacity(0.2),
            dayPeriodTextColor: AppColors.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          
          // Date Picker Theme
          datePickerTheme: DatePickerThemeData(
            backgroundColor: AppColors.white,
            headerBackgroundColor: AppColors.primary,
            headerForegroundColor: AppColors.white,
            dayForegroundColor: MaterialStateProperty.resolveWith((states) {
              if (states.contains(MaterialState.selected)) {
                return AppColors.white;
              }
              return AppColors.greyDark;
            }),
            dayBackgroundColor: MaterialStateProperty.resolveWith((states) {
              if (states.contains(MaterialState.selected)) {
                return AppColors.primary;
              }
              return Colors.transparent;
            }),
            todayForegroundColor: MaterialStateProperty.all(AppColors.primary),
            todayBackgroundColor: MaterialStateProperty.all(Colors.transparent),
            yearForegroundColor: MaterialStateProperty.resolveWith((states) {
              if (states.contains(MaterialState.selected)) {
                return AppColors.white;
              }
              return AppColors.greyDark;
            }),
            yearBackgroundColor: MaterialStateProperty.resolveWith((states) {
              if (states.contains(MaterialState.selected)) {
                return AppColors.primary;
              }
              return Colors.transparent;
            }),
            rangePickerBackgroundColor: AppColors.white,
            rangePickerHeaderBackgroundColor: AppColors.primary,
            rangePickerHeaderForegroundColor: AppColors.white,
            rangeSelectionBackgroundColor: AppColors.primary.withOpacity(0.2),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          
          // Slider Theme
          sliderTheme: SliderThemeData(
            activeTrackColor: AppColors.primary,
            inactiveTrackColor: AppColors.greyLight,
            thumbColor: AppColors.primary,
            overlayColor: AppColors.primary.withOpacity(0.2),
            valueIndicatorColor: AppColors.primary,
            valueIndicatorTextStyle: const TextStyle(
              color: AppColors.white,
              fontSize: 12,
            ),
          ),
          
          // Navigation Rail Theme
          navigationRailTheme: NavigationRailThemeData(
            backgroundColor: AppColors.white,
            selectedIconTheme: const IconThemeData(
              color: AppColors.primary,
              size: 24,
            ),
            unselectedIconTheme: const IconThemeData(
              color: AppColors.grey,
              size: 24,
            ),
            selectedLabelTextStyle: const TextStyle(
              color: AppColors.primary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
            unselectedLabelTextStyle: const TextStyle(
              color: AppColors.grey,
              fontSize: 12,
              fontWeight: FontWeight.w400,
            ),
            indicatorColor: AppColors.primary.withOpacity(0.1),
          ),
          
          // Search Bar Theme
          searchBarTheme: SearchBarThemeData(
            backgroundColor: MaterialStateProperty.all(AppColors.white),
            shadowColor: MaterialStateProperty.all(Colors.transparent),
            surfaceTintColor: MaterialStateProperty.all(Colors.transparent),
            overlayColor: MaterialStateProperty.all(Colors.transparent),
            side: MaterialStateProperty.all(
              const BorderSide(color: AppColors.greyLight, width: 1),
            ),
            shape: MaterialStateProperty.all(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            padding: MaterialStateProperty.all(
              const EdgeInsets.symmetric(horizontal: 16),
            ),
            textStyle: MaterialStateProperty.all(
              const TextStyle(
                color: AppColors.greyDark,
                fontSize: 16,
              ),
            ),
            hintStyle: MaterialStateProperty.all(
              const TextStyle(
                color: AppColors.grey,
                fontSize: 16,
              ),
            ),
          ),
          
          // Search View Theme
          searchViewTheme: SearchViewThemeData(
            backgroundColor: AppColors.white,
            surfaceTintColor: Colors.transparent,
            side: const BorderSide(color: AppColors.greyLight, width: 1),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            headerTextStyle: const TextStyle(
              color: AppColors.greyDark,
              fontSize: 16,
            ),
            headerHintStyle: const TextStyle(
              color: AppColors.grey,
              fontSize: 16,
            ),
          ),
        ),
        
        // Builder for global app configuration
        builder: (context, child) {
          return NotificationListener<OverscrollIndicatorNotification>(
            onNotification: (notification) {
              notification.disallowIndicator();
              return true;
            },
            child: child!,
          );
        },
      ),
    );
  }

  // Helper method to create MaterialColor from Color
  MaterialColor _createMaterialColor(Color color) {
    List strengths = <double>[.05];
    Map<int, Color> swatch = {};
    final int r = color.red, g = color.green, b = color.blue;

    for (int i = 1; i < 10; i++) {
      strengths.add(0.1 * i);
    }
    
    for (double strength in strengths) {
      final double ds = 0.5 - strength;
      swatch[(strength * 1000).round()] = Color.fromRGBO(
        r + ((ds < 0 ? r : (255 - r)) * ds).round(),
        g + ((ds < 0 ? g : (255 - g)) * ds).round(),
        b + ((ds < 0 ? b : (255 - b)) * ds).round(),
        1,
      );
    }
    
    return MaterialColor(color.value, swatch);
  }
}