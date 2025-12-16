import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_application/core/constants/app_colors.dart';
import 'package:flutter_application/core/constants/spacings.dart';
import 'package:flutter_application/core/router/routes.dart';
import 'package:flutter_application/features/auth/presentation/bloc/login/login_cubit.dart';
import 'package:flutter_application/features/auth/presentation/widget/login_button.dart';
import 'package:flutter_application/features/auth/presentation/widget/login_email_input.dart';
import 'package:flutter_application/features/auth/presentation/widget/login_password_input.dart';

class LoginForm extends StatelessWidget {
  const LoginForm({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LoginCubit, LoginState>(
      builder: (context, state) {
        return Column(
          children: [
            // Back button
            Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                  onPressed: () => context.go(Routes.onboarding.path),
                ),
              ),
            ),
            Expanded(
              child: Column(
                children: [
                  const SizedBox(height: Spacing.s16),
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(Spacing.s24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(32),
                          topRight: Radius.circular(32),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, -5),
                          ),
                        ],
                      ),
                      child: SingleChildScrollView(
                        child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Title
                          Text(
                            state.isLoginMode ? "Masuk" : "Daftar",
                            style: GoogleFonts.poppins(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: AppColors.b93160,
                            ),
                          ),
                          const SizedBox(height: Spacing.s8),
                          Text(
                            state.isLoginMode
                                ? "Masuk sekarang dan kendalikan setiap pengeluaran tanpa repot!"
                                : "Daftar sekarang dan kendalikan setiap pengeluaran tanpa repot!",
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Colors.black54,
                            ),
                          ),
                          const SizedBox(height: Spacing.s16),
                          Container(
                            width: MediaQuery.of(context).size.width / 3,
                            height: 3,
                            decoration: BoxDecoration(
                              color: AppColors.b93160,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const SizedBox(height: Spacing.s24),
                          // Email input
                          const LoginEmailInput(),
                          const SizedBox(height: Spacing.s16),
                          // Password input
                          const LoginPasswordInput(),
                          if (state.isLoginMode) ...[
                            const SizedBox(height: Spacing.s8),
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: () {
                                  // TODO: Implement forgot password
                                },
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  minimumSize: const Size(0, 0),
                                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                ),
                                child: Text(
                                  "Lupa kata sandi?",
                                  style: GoogleFonts.poppins(
                                    color: Colors.blue,
                                    fontSize: 11,
                                  ),
                                ),
                              ),
                            ),
                          ],
                          const SizedBox(height: Spacing.s48),
                          // Login button
                          const LoginButton(),
                          const SizedBox(height: Spacing.s24),
                          // Toggle login/signup
                          Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  state.isLoginMode
                                      ? "Belum punya akun? "
                                      : "Sudah punya akun? ",
                                  style: GoogleFonts.poppins(
                                    color: Colors.black54,
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {
                                    if (state.isLoginMode) {
                                      // Navigate to register page
                                      context.push(Routes.register.path);
                                    } else {
                                      // Toggle back to login mode
                                      context.read<LoginCubit>().toggleLoginMode();
                                    }
                                  },
                                  style: TextButton.styleFrom(
                                    padding: EdgeInsets.zero,
                                    minimumSize: const Size(0, 0),
                                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  child: Text(
                                    state.isLoginMode ? "Daftar" : "Masuk",
                                    style: GoogleFonts.poppins(
                                      color: Colors.blue,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    },
  );
}
}
