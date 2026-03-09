import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'obscure_text_event.dart';
part 'obscure_text_state.dart';

class ObscureTextBloc extends Bloc<ObscureTextEvent, ObscureTextState> {

  ObscureTextBloc() : super(ObscureTextState()) {
    on<ToggleObscure>(_toggleObscure);
  }

  void _toggleObscure (ToggleObscure event, Emitter<ObscureTextState> emit) {
    emit(state.copyWith(newBool: !state.obscureText));
  }

}