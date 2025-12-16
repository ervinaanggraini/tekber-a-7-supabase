import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_application/core/constants/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_application/core/extensions/build_context_extensions.dart';
import 'package:flutter_application/features/auth/presentation/bloc/register/register_cubit.dart';
import 'package:formz/formz.dart';

class RegisterButton extends StatelessWidget {
  const RegisterButton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RegisterCubit, RegisterState>(
      builder: (context, state) {
        return Container(
          width: double.infinity,
          height: 48,
          decoration: BoxDecoration(
            gradient: AppColors.linier,
            borderRadius: BorderRadius.circular(30),
          ),
          child: ElevatedButton(
            onPressed: state.isValid && !state.status.isInProgress
                ? () {
                    context.closeKeyboard();
                    context.read<RegisterCubit>().submitForm();
                  }
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              disabledBackgroundColor: Colors.grey.shade300,
            ),
            child: state.status.isInProgress
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Text(
                    "Daftar",
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: state.isValid ? Colors.white : Colors.black54,
                    ),
                  ),
          ),
        );
      },
    );
  }
}
