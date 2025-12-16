import 'package:flutter/material.dart';
import 'package:flutter_application/core/constants/app_colors.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_application/features/auth/presentation/bloc/register/register_cubit.dart';

class RegisterEmailInput extends StatelessWidget {
  const RegisterEmailInput({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RegisterCubit, RegisterState>(
      buildWhen: (previous, current) => previous.email != current.email,
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Email",
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 6),
            TextField(
              onChanged: (email) => context.read<RegisterCubit>().emailChanged(email),
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              style: GoogleFonts.poppins(fontSize: 14, color: Colors.black),
              decoration: InputDecoration(
                hintText: "Masukkan email anda",
                hintStyle: GoogleFonts.poppins(
                  color: Colors.pink.shade200,
                  fontSize: 13,
                ),
                prefixIcon: Icon(Icons.email_outlined, color: Colors.pink.shade300, size: 20),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide(color: Colors.pink.shade300, width: 2),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: const BorderSide(color: AppColors.ffb4c2, width: 2),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: const BorderSide(color: AppColors.b93160, width: 2),
                ),
                errorText: state.email.displayError != null ? "Email tidak valid" : null,
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
