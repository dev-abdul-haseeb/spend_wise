part of 'navigation_bloc.dart';

abstract class NavigationEvent extends Equatable{
  NavigationEvent();

  @override

  List<Object?> get props => [];
}

class ChangeIndex extends NavigationEvent {
  int index;

  ChangeIndex({
    required this.index,
  });

  @override

  List<Object?> get props => [index];
}