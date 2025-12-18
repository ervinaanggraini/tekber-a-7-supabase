import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:flutter_application/core/error/failures.dart';
import 'package:flutter_application/features/ocr_receipt/data/data_sources/ocr_remote_data_source.dart';
import 'package:flutter_application/features/ocr_receipt/domain/entities/receipt_scan_result.dart';
import 'package:flutter_application/features/ocr_receipt/domain/repositories/ocr_repository.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: OcrRepository)
class OcrRepositoryImpl implements OcrRepository {
  final OcrRemoteDataSource remoteDataSource;

  OcrRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, ReceiptScanResult>> scanReceipt(File imageFile) async {
    try {
      final result = await remoteDataSource.scanReceipt(imageFile);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
