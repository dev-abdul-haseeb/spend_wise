part of 'obscure_text_bloc.dart';

abstract class ObscureTextEvent extends Equatable {
  ObscureTextEvent();

  @override
  // TODO: implement props
  List<Object?> get props => [];

}

class ToggleObscure extends ObscureTextEvent{}