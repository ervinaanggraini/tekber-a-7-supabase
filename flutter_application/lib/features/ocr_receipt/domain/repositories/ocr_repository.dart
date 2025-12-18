import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:flutter_application/core/error/failures.dart';
import 'package:flutter_application/features/ocr_receipt/domain/entities/receipt_scan_result.dart';


abstract class OcrRepository {
  Future<Either<Failure, ReceiptScanResult>> scanReceipt(File imageFile);
}
