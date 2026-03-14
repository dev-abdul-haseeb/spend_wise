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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

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
              textTheme: TextTheme(
                bodyMedium: TextStyle(
                  color: themeState.isDark ? themeState.theme[appColors.accentColor] : themeState.theme[appColors.primaryColor]
                ),
              ),
              inputDecorationTheme: InputDecorationTheme(
                hintStyle: TextStyle(
                  color: themeState.isDark ? themeState.theme[appColors.accentColor] : themeState.theme[appColors.primaryColor]
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}