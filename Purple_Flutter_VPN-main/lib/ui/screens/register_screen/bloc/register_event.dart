part of 'register_bloc.dart';

sealed class RegisterEvent extends Equatable {
  const RegisterEvent();

  @override
  List<Object> get props => [];
}

class VerificationCall extends RegisterEvent {
  final String email;
  final String otp;
  const VerificationCall({required this.email, required this.otp});
}

class RegistationCall extends RegisterEvent {
  final String deviceid;
  final String name;
  final String email;
  final String passwrod;
  final String phoneNo;
  final String reference;
  const RegistationCall(
      {required this.deviceid,
      required this.name,
      required this.email,
      required this.passwrod,
      required this.phoneNo,
      required this.reference});
}
