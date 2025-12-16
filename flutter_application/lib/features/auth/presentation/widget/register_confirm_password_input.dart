import 'package:flutter/material.dart';
import 'package:flutter_application/core/constants/app_colors.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_application/features/auth/presentation/bloc/register/register_cubit.dart';

class RegisterConfirmPasswordInput extends StatelessWidget {
  const RegisterConfirmPasswordInput({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RegisterCubit, RegisterState>(
      buildWhen: (previous, current) => 
        previous.confirmPassword != current.confirmPassword || 
        previous.password != current.password,
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Konfirmasi Kata Sandi",
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 6),
            TextField(
              onChanged: (password) => context.read<RegisterCubit>().confirmPasswordChanged(password),
              obscureText: true,
              textInputAction: TextInputAction.done,
              style: GoogleFonts.poppins(fontSize: 14, color: Colors.black),
              decoration: InputDecoration(
                hintText: "Masukkan ulang kata sandi anda",
                hintStyle: GoogleFonts.poppins(
                  color: Colors.amber.shade300,
                  fontSize: 13,
                ),
                prefixIcon: Icon(Icons.lock_outline, color: Colors.amber.shade600, size: 20),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide(color: Colors.amber.shade300, width: 2),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: const BorderSide(color: AppColors.eed180, width: 2),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: const BorderSide(color: AppColors.ba9659, width: 2),
                ),
                errorText: state.confirmPassword.isNotEmpty && state.password.value != state.confirmPassword 
                  ? "Kata sandi tidak sama" 
                  : null,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                isDense: true,
              ),
            ),
          ],
        );
      },
    );
  }
}
