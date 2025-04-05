part of 'login_bloc.dart';

@freezed
class LoginState with _$LoginState {
  const factory LoginState.initial() = _Initial;
  const factory LoginState.loading() = _Loading;
  const factory LoginState.success({required UserLoginModel respose}) = _Success;
  const factory LoginState.error({required String error}) = _Error;
  
  
  
}
