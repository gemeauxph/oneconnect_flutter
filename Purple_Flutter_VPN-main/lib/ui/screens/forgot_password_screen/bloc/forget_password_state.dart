part of 'forget_password_bloc.dart';

sealed class ForgetPasswordState extends Equatable {
  const ForgetPasswordState();
  
  @override
  List<Object> get props => [];
}

final class ForgetPasswordInitial extends ForgetPasswordState {}

class ForgetPasswordFail extends ForgetPasswordState{
  final String message;
  const ForgetPasswordFail({required this.message});
  
  @override
  List<Object> get props => [message];
}

class ForgetPasswordSuccess extends ForgetPasswordState{
  final String message;
  const ForgetPasswordSuccess({required this.message});
}
