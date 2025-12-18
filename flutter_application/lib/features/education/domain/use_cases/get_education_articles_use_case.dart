import 'package:dartz/dartz.dart';
import 'package:flutter_application/core/error/failures.dart';
import 'package:flutter_application/features/education/domain/entities/education_article.dart';
import 'package:flutter_application/features/education/domain/repositories/education_repository.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class GetEducationArticlesUseCase {
  final EducationRepository repository;

  GetEducationArticlesUseCase(this.repository);

  Future<Either<Failure, List<EducationArticle>>> call(String courseId) {
    return repository.getCourseArticles(courseId);
  }
}
