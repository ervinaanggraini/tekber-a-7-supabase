import 'package:equatable/equatable.dart';
import 'package:flutter_application/features/education/domain/entities/course.dart';
import 'package:flutter_application/features/education/domain/entities/education_article.dart';

abstract class EducationState extends Equatable {
  const EducationState();

  @override
  List<Object> get props => [];
}

class EducationInitial extends EducationState {}

class EducationLoading extends EducationState {}

class CoursesLoaded extends EducationState {
  final List<Course> courses;

  const CoursesLoaded(this.courses);

  @override
  List<Object> get props => [courses];
}

class CourseArticlesLoaded extends EducationState {
  final List<EducationArticle> articles;
  final String courseId;

  const CourseArticlesLoaded(this.articles, this.courseId);

  @override
  List<Object> get props => [articles, courseId];
}

class EducationError extends EducationState {
  final String message;

  const EducationError(this.message);

  @override
  List<Object> get props => [message];
}
