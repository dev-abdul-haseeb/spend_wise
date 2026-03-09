part of 'theme_bloc.dart';

abstract class ThemeEvent extends Equatable{

  ThemeEvent();
  @override
  List<Object?> get props => [];

}

class ToggleTheme extends ThemeEvent {}

class LoadTheme extends ThemeEvent {
  @override
  List<Object?> get props => [];
}