import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:spend_wise/view/splash/splash_screen.dart';
import 'package:spend_wise/viewModel/bloc/auth_state/auth_bloc.dart';
import 'package:spend_wise/viewModel/bloc/theme/theme_bloc.dart';

import 'config/color/colors.dart';
import 'config/routes/route_names.dart';
import 'config/routes/routes.dart';
import 'firebase_options.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'services/profile_photo_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await ProfilePhotoService.init();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => ThemeBloc()),

        BlocProvider(create: (context) => AuthBloc()),

      ],
      child: BlocBuilder<ThemeBloc, ThemeState>(
        builder: (context, themeState) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            initialRoute: RouteNames.splashScreen,
            onGenerateRoute: Routes.generateRoute,
            theme: ThemeData(
              useMaterial3: true,
              brightness: themeState.isDark ? Brightness.dark : Brightness.light,
              scaffoldBackgroundColor: themeState.theme[appColors.appBGColor],
              primaryColor: themeState.theme[appColors.primaryColor],
              cardColor: themeState.theme[appColors.cardColor],
              colorScheme: ColorScheme(
                brightness: themeState.isDark ? Brightness.dark : Brightness.light,
                primary: themeState.theme[appColors.primaryColor]!,
                onPrimary: Colors.white,
                secondary: themeState.theme[appColors.accentColor]!,
                onSecondary: Colors.black,
                error: themeState.theme[appColors.expenseColor]!,
                onError: Colors.white,
                surface: themeState.theme[appColors.cardColor]!,
                onSurface: themeState.theme[appColors.textPrimaryColor]!,
              ),
              dialogTheme: DialogThemeData(
                backgroundColor: themeState.theme[appColors.cardColor],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                elevation: 16,
              ),
              inputDecorationTheme: InputDecorationTheme(
                filled: true,
                fillColor: themeState.isDark
                    ? Colors.white.withValues(alpha: 0.05)
                    : Colors.grey.withValues(alpha: 0.06),
                hintStyle: TextStyle(
                  color: themeState.theme[appColors.textSecondaryColor],
                  fontSize: 14,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: themeState.isDark
                        ? Colors.white.withValues(alpha: 0.1)
                        : Colors.grey.withValues(alpha: 0.2),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: themeState.isDark
                        ? Colors.white.withValues(alpha: 0.1)
                        : Colors.grey.withValues(alpha: 0.2),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: themeState.theme[appColors.primaryColor]!,
                    width: 1.8,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
            ),
          );
        },
      ),
    );
  }
}