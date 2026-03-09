part of 'obscure_text_bloc.dart';

class ObscureTextState extends Equatable {

  bool obscureText;

  ObscureTextState ({
    this.obscureText = true,
  });

  ObscureTextState copyWith({bool? newBool}) {
    return ObscureTextState(
      obscureText: newBool ?? this.obscureText,
    );
  }

  @override
  // TODO: implement props
  List<Object?> get props => [obscureText];

}