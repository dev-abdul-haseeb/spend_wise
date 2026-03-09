part of 'theme_bloc.dart';
class ThemeState extends Equatable {
  bool isDark;
  Map<appColors, Color> theme;

  ThemeState({
    this.isDark = false,
    this.theme = AppColors.lightTheme,
  });

  ThemeState copyWith({bool? newIsDark, Map<appColors,Color>? newTheme}) {
    return ThemeState(
      isDark: newIsDark ?? this.isDark,
      theme: newTheme ?? this.theme
    );
  }

  @override
  List<Object?> get props => [isDark,theme];
}