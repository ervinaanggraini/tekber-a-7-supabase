import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:flutter_application/core/error/failures.dart';
import 'package:flutter_application/features/ocr_receipt/domain/entities/receipt_scan_result.dart';
import 'package:flutter_application/features/ocr_receipt/domain/repositories/ocr_repository.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class ScanReceiptUseCase {
  final OcrRepository repository;

  ScanReceiptUseCase(this.repository);

  Future<Either<Failure, ReceiptScanResult>> call(File imageFile) {
    return repository.scanReceipt(imageFile);
  }
}
