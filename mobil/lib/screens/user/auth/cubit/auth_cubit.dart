import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(AuthInitial());

  Future<void> login(String email, String password) async {
    emit(AuthLoading());

    try {
      await Future.delayed(const Duration(seconds: 2)); // Simulate API call

      emit(AuthSuccess());
    } catch (e) {
      emit(AuthError("Login failed"));
    }
  }
}
