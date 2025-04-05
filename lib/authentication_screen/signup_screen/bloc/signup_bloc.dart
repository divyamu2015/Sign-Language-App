import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:signin_language_app/authentication_screen/signup_screen/signup_cont/signup_service.dart';

import '../signup_model/signup_model.dart';

part 'signup_event.dart';
part 'signup_state.dart';
part 'signup_bloc.freezed.dart';

class SignupBloc extends Bloc<SignupEvent, SignupState> {
  SignupBloc() : super(_Initial()) {
    on<SignupEvent>((event, emit) async {
      if (event is _UseRegistration) {
        emit(SignupState.loading());

        try {
          final response = await useRegistration(
              id: event.id,
              username: event.username,
              email: event.email,
              phone: event.phone,
              password: event.password);
          emit(SignupState.success(response: response));
        } catch (e) {
          emit(SignupState.error(error: e.toString()));
        }
      }
    });
  }
}
