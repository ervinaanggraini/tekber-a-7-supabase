import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import 'package:go_router/go_router.dart';

import 'package:flutter_application/core/constants/app_colors.dart';
import 'package:flutter_application/features/auth/presentation/bloc/register/register_cubit.dart';
import 'package:flutter_application/features/auth/presentation/widget/register_form.dart';
import 'package:flutter_application/core/extensions/build_context_extensions.dart';
import 'package:flutter_application/dependency_injection.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.linier,
        ),
        child: SafeArea(
          child: BlocProvider(
            create: (context) => getIt<RegisterCubit>(),
            child: BlocListener<RegisterCubit, RegisterState>(
              listener: (context, state) {
                switch (state.status) {
                  case FormzSubmissionStatus.failure:
                    context.showErrorSnackBarMessage(
                      state.errorMessage ?? 'Gagal mendaftar. Silakan coba lagi.',
                    );
                    return;
                  case FormzSubmissionStatus.success:
                    context.showSuccessSnackBarMessage(
                      'Berhasil mendaftar! Silakan masuk.',
                    );
                    context.pop();
                    return;
                  default:
                    return;
                }
              },
              child: const RegisterForm(),
            ),
          ),
        ),
      ),
    );
  }
}
