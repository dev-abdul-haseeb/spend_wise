import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'navigation_state.dart';
part 'navigation_event.dart';

class NavigationBloc extends Bloc<NavigationEvent, NavigationState> {

  NavigationBloc(): super(NavigationState()) {
    on<ChangeIndex>(_changeIndex);
  }

  void _changeIndex (ChangeIndex event, Emitter<NavigationState> emit) {
    emit(state.copyWith(newIndex: event.index));
  }

}