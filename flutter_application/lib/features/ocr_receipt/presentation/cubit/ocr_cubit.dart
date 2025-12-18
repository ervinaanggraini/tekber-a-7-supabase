import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_application/features/ocr_receipt/domain/use_cases/scan_receipt_use_case.dart';
import 'package:flutter_application/features/ocr_receipt/presentation/cubit/ocr_state.dart';
import 'package:injectable/injectable.dart';

@injectable
class OcrCubit extends Cubit<OcrState> {
  final ScanReceiptUseCase scanReceiptUseCase;

  OcrCubit(this.scanReceiptUseCase) : super(OcrInitial());

  Future<void> scanReceipt(File imageFile) async {
    emit(OcrLoading());
    final result = await scanReceiptUseCase(imageFile);
    result.fold(
      (failure) => emit(OcrError(failure.message)),
      (scanResult) => emit(OcrSuccess(scanResult)),
    );
  }
}
