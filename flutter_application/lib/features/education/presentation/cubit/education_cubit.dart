import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_application/features/education/domain/use_cases/get_courses_use_case.dart';
import 'package:flutter_application/features/education/domain/use_cases/get_education_articles_use_case.dart';
import 'package:flutter_application/features/education/domain/use_cases/mark_article_read_use_case.dart';
import 'package:flutter_application/features/education/presentation/cubit/education_state.dart';
import 'package:injectable/injectable.dart';

@injectable
class EducationCubit extends Cubit<EducationState> {
  final GetCoursesUseCase getCoursesUseCase;
  final GetEducationArticlesUseCase getEducationArticlesUseCase;
  final MarkArticleReadUseCase markArticleReadUseCase;

  EducationCubit(
    this.getCoursesUseCase,
    this.getEducationArticlesUseCase,
    this.markArticleReadUseCase,
  ) : super(EducationInitial());

  Future<void> loadCourses() async {
    emit(EducationLoading());
    final result = await getCoursesUseCase();
    result.fold(
      (failure) => emit(EducationError(failure.message)),
      (courses) => emit(CoursesLoaded(courses)),
    );
  }

  Future<void> loadCourseArticles(String courseId) async {
    emit(EducationLoading());
    final result = await getEducationArticlesUseCase(courseId);
    result.fold(
      (failure) => emit(EducationError(failure.message)),
      (articles) => emit(CourseArticlesLoaded(articles, courseId)),
    );
  }

  Future<void> markArticleAsRead(String courseId, String articleUrl) async {
    await markArticleReadUseCase(courseId, articleUrl);
  }
}
