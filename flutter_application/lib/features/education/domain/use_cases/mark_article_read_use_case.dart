import 'package:dartz/dartz.dart';
import 'package:flutter_application/core/error/failures.dart';
import 'package:flutter_application/features/education/domain/repositories/education_repository.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class MarkArticleReadUseCase {
  final EducationRepository repository;

  MarkArticleReadUseCase(this.repository);

  Future<Either<Failure, void>> call(String courseId, String articleUrl) {
    return repository.markArticleAsRead(courseId, articleUrl);
  }
}
