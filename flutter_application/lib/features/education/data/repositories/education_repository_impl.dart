import 'package:dartz/dartz.dart';
import 'package:flutter_application/core/error/failures.dart';
import 'package:flutter_application/features/education/data/data_sources/education_remote_data_source.dart';
import 'package:flutter_application/features/education/domain/entities/course.dart';
import 'package:flutter_application/features/education/domain/entities/education_article.dart';
import 'package:flutter_application/features/education/domain/repositories/education_repository.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: EducationRepository)
class EducationRepositoryImpl implements EducationRepository {
  final EducationRemoteDataSource remoteDataSource;

  EducationRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, List<Course>>> getCourses() async {
    try {
      final result = await remoteDataSource.getCourses();
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<EducationArticle>>> getCourseArticles(String courseId) async {
    try {
      final result = await remoteDataSource.getCourseArticles(courseId);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> markArticleAsRead(String courseId, String articleUrl) async {
    try {
      await remoteDataSource.markArticleAsRead(courseId, articleUrl);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
