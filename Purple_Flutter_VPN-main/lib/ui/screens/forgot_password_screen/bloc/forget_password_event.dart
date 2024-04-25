part of 'forget_password_bloc.dart';

sealed class ForgetPasswordEvent extends Equatable {
  const ForgetPasswordEvent();

  @override
  List<Object> get props => [];
}


class ForgetPasswordCall extends ForgetPasswordEvent{
  final String email;
  const ForgetPasswordCall({required this.email});
}