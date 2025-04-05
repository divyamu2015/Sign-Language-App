part of 'login_bloc.dart';

@freezed
class LoginEvent with _$LoginEvent {
  const factory LoginEvent.started() = _Started;
  const factory LoginEvent.userlogin({
    required String userId,
    required String email,
    required String paswd,
  }) = _Userlogin;
  
}