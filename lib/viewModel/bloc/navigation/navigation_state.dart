part of 'navigation_bloc.dart';

class NavigationState extends Equatable {

  int selectedIndex;

  NavigationState( {
    this.selectedIndex = 0,
  });

  NavigationState copyWith({int? newIndex}) {
    return NavigationState(
      selectedIndex: newIndex ?? this.selectedIndex,
    );
  }

  @override
  List<Object?> get props => [selectedIndex];

}