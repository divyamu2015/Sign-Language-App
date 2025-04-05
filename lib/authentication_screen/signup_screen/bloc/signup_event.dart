part of 'signup_bloc.dart';

@freezed
class SignupEvent with _$SignupEvent {
  const factory SignupEvent.started() = _Started;
  const factory SignupEvent.useRegistration(
    {
    required String id,
    required String username,
    required String email,
    required String phone,
    required String password,
    }
  ) = _UseRegistration;
  
}