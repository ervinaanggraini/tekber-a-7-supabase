import 'package:equatable/equatable.dart';
import 'package:flutter_application/features/savings_goal/domain/entities/savings_goal.dart';

abstract class SavingsGoalState extends Equatable {
  const SavingsGoalState();

  @override
  List<Object> get props => [];
}

class SavingsGoalInitial extends SavingsGoalState {}

class SavingsGoalLoading extends SavingsGoalState {}

class SavingsGoalLoaded extends SavingsGoalState {
  final List<SavingsGoal> goals;

  const SavingsGoalLoaded(this.goals);

  @override
  List<Object> get props => [goals];
}

class SavingsGoalError extends SavingsGoalState {
  final String message;

  const SavingsGoalError(this.message);

  @override
  List<Object> get props => [message];
}

class SavingsGoalOperationSuccess extends SavingsGoalState {
  final String message;

  const SavingsGoalOperationSuccess(this.message);

  @override
  List<Object> get props => [message];
}
