import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:signin_language_app/authentication_screen/login_screen/login_contr/login_service.dart';

import '../login_model/login_model.dart';

part 'login_event.dart';
part 'login_state.dart';
part 'login_bloc.freezed.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  LoginBloc() : super(_Initial()) {
    on<LoginEvent>((event, emit) async {
      if (event is _Userlogin) {
        emit(const LoginState.loading());
        try {
          final response = await userlogin(
            userId: event.userId, 
            email: event.email, 
            paswd: event.paswd);
          emit(LoginState.success(respose: response));
        } catch (e) {
          emit(LoginState.error(error: e.toString()));
        }
      }
    });
  }
}
