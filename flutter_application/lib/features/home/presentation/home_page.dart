import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_application/core/router/routes.dart';
import 'package:flutter_application/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:flutter_application/features/home/presentation/widgets/home_content.dart';

class HomePage extends StatelessWidget {
  const HomePage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthUserUnauthenticated) {
          context.go(Routes.onboarding.path);
        }
      },
      child: const Scaffold(
        body: SafeArea(
          child: HomeContent(),
        ),
      ),
    );
  }
}
