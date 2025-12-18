import 'package:equatable/equatable.dart';
import 'package:flutter_application/features/ocr_receipt/domain/entities/receipt_scan_result.dart';

abstract class OcrState extends Equatable {
  const OcrState();

  @override
  List<Object> get props => [];
}

class OcrInitial extends OcrState {}

class OcrLoading extends OcrState {}

class OcrSuccess extends OcrState {
  final ReceiptScanResult result;

  const OcrSuccess(this.result);

  @override
  List<Object> get props => [result];
}

class OcrError extends OcrState {
  final String message;

  const OcrError(this.message);

  @override
  List<Object> get props => [message];
}
