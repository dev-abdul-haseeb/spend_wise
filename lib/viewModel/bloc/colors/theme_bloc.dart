import 'dart:ui';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:spend_wise/config/color/colors.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'theme_event.dart';
part 'theme_state.dart';

class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  ThemeBloc(): super(ThemeState()) {
    on<ToggleTheme>(_toggleTheme);
    on<LoadTheme>(_loadTheme);
    add(LoadTheme());   //Runs as soon as the bloc is initialized
  }

  void _toggleTheme(ToggleTheme event, Emitter<ThemeState>emit) async{
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('isDarkMode', !state.isDark);     //Change in preferences

    if(state.isDark) {
      emit(state.copyWith(newIsDark: !state.isDark, newTheme: AppColors.lightTheme));
    }
    else {
      emit(state.copyWith(newIsDark: !state.isDark, newTheme: AppColors.darkTheme));
    }
  }

  void _loadTheme(LoadTheme event, Emitter<ThemeState> emit) async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool('isDarkMode') ?? false;
    emit(state.copyWith(
      newIsDark: isDark,
      newTheme: isDark ? AppColors.darkTheme : AppColors.lightTheme,
    ));
  }

}