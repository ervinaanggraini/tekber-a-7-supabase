import 'package:dartz/dartz.dart';
import 'package:flutter_application/core/error/failures.dart';
import 'package:flutter_application/features/education/domain/entities/course.dart';
import 'package:flutter_application/features/education/domain/repositories/education_repository.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class GetCoursesUseCase {
  final EducationRepository repository;

  GetCoursesUseCase(this.repository);

  Future<Either<Failure, List<Course>>> call() {
    return repository.getCourses();
  }
}
