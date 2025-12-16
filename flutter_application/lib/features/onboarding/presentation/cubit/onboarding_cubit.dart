import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_application/features/onboarding/data/repository/onboarding_repository.dart';
import 'package:injectable/injectable.dart';

part 'onboarding_state.dart';

@injectable
class OnboardingCubit extends Cubit<OnboardingState> {
  OnboardingCubit(this._onboardingRepository) : super(OnboardingInitial());

  final OnboardingRepository _onboardingRepository;

  Future<void> completeOnboarding() async {
    await _onboardingRepository.setOnboardingSeen();
    emit(OnboardingCompleted());
  }
}
