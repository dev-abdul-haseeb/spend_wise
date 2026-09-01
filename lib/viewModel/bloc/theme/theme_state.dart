part of 'theme_bloc.dart';

class ThemeState extends Equatable {
  final bool isDark;
  final Map<appColors, Color> theme;

  const ThemeState({
    this.isDark = false,
    this.theme = AppColors.lightTheme,
  });

  ThemeState copyWith({bool? newIsDark, Map<appColors, Color>? newTheme}) {
    return ThemeState(
      isDark: newIsDark ?? isDark,
      theme: newTheme ?? theme,
    );
  }

  @override
  List<Object?> get props => [isDark, theme];
}