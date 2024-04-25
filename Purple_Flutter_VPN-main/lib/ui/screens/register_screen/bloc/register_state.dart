part of 'register_bloc.dart';

sealed class RegisterState extends Equatable {
  const RegisterState();
  
  @override
  List<Object> get props => [];
}

final class RegisterInitial extends RegisterState {}

class VerificationSuccess extends RegisterState{}

class RegisterFail extends RegisterState{
  final String message;
  const RegisterFail({required this.message});
  
  @override
  List<Object> get props => [message];
}

class RegistationFail extends RegisterState{
  final String message;
  const RegistationFail({required this.message});
  @override
  List<Object> get props => [message];
}

class RegisterSuccess extends RegisterState{
  const RegisterSuccess();
}
