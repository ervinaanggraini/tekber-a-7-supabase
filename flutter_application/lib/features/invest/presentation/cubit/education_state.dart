import 'package:equatable/equatable.dart';
import '../../data/models/investment_article_model.dart';

abstract class EducationState extends Equatable {
  @override
  List<Object?> get props => [];
}

class EducationInitial extends EducationState {}

class EducationLoading extends EducationState {}

class EducationLoaded extends EducationState {
  final List<InvestmentArticle> articles;

  EducationLoaded(this.articles);

  @override
  List<Object?> get props => [articles];
}

class EducationError extends EducationState {
  final String message;

  EducationError(this.message);

  @override
  List<Object?> get props => [message];
}
