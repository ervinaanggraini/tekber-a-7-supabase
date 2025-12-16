import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_application/core/constants/app_colors.dart';
import 'package:flutter_application/core/constants/spacings.dart';
import 'package:flutter_application/core/router/routes.dart';
import 'package:flutter_application/features/auth/presentation/bloc/register/register_cubit.dart';
import 'package:flutter_application/features/auth/presentation/widget/register_button.dart';
import 'package:flutter_application/features/auth/presentation/widget/register_name_input.dart';
import 'package:flutter_application/features/auth/presentation/widget/register_email_input.dart';
import 'package:flutter_application/features/auth/presentation/widget/register_password_input.dart';
import 'package:flutter_application/features/auth/presentation/widget/register_confirm_password_input.dart';

class RegisterForm extends StatelessWidget {
  const RegisterForm({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RegisterCubit, RegisterState>(
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
                  const SizedBox(height: Spacing.s8),
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: Spacing.s24, vertical: Spacing.s16),
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Title
                          Text(
                            "Daftar",
                            style: GoogleFonts.poppins(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: AppColors.b93160,
                            ),
                          ),
                          const SizedBox(height: Spacing.s4),
                          Text(
                            "Daftar sekarang dan kendalikan setiap pengeluaran tanpa repot!",
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              color: Colors.black54,
                            ),
                          ),
                          const SizedBox(height: Spacing.s12),
                          Container(
                            width: MediaQuery.of(context).size.width / 3,
                            height: 3,
                            decoration: BoxDecoration(
                              color: AppColors.b93160,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const SizedBox(height: Spacing.s8),
                          // Name input
                          const RegisterNameInput(),
                          const SizedBox(height: Spacing.s8),
                          // Email input
                          const RegisterEmailInput(),
                          const SizedBox(height: Spacing.s8),
                          // Password input
                          const RegisterPasswordInput(),
                          const SizedBox(height: Spacing.s8),
                          // Confirm Password input
                          const RegisterConfirmPasswordInput(),
                          const Spacer(),
                          // Register button
                          const RegisterButton(),
                          const SizedBox(height: Spacing.s8),
                          // Toggle to login
                          Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Sudah punya akun? ",
                                  style: GoogleFonts.poppins(
                                    color: Colors.black54,
                                    fontSize: 13,
                                  ),
                                ),
                                TextButton(
                                  onPressed: () => context.go(Routes.login.path),
                                  style: TextButton.styleFrom(
                                    padding: EdgeInsets.zero,
                                    minimumSize: const Size(0, 0),
                                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  child: Text(
                                    "Masuk",
                                    style: GoogleFonts.poppins(
                                      color: Colors.blue,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13,
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
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
