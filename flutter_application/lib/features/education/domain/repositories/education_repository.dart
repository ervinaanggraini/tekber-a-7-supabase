import 'package:dartz/dartz.dart';
import 'package:flutter_application/core/error/failures.dart';
import 'package:flutter_application/features/education/domain/entities/course.dart';
import 'package:flutter_application/features/education/domain/entities/education_article.dart';

abstract class EducationRepository {
  Future<Either<Failure, List<Course>>> getCourses();
  Future<Either<Failure, List<EducationArticle>>> getCourseArticles(String courseId);
  Future<Either<Failure, void>> markArticleAsRead(String courseId, String articleUrl);
}
