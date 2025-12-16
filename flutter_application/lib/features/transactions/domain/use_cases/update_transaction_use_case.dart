import 'package:equatable/equatable.dart';
import 'package:flutter_application/core/use_cases/async_use_case.dart';
import 'package:flutter_application/features/transactions/domain/entities/transaction.dart';
import 'package:flutter_application/features/transactions/domain/entities/category.dart';
import 'package:flutter_application/features/transactions/domain/repositories/transaction_repository.dart';
import 'package:injectable/injectable.dart';
import 'package:flutter_application/features/gamification/services/gamification_service.dart';

@injectable
class UpdateTransactionUseCase implements AsyncUseCase<Transaction, UpdateTransactionParams> {
  final TransactionRepository _repository;
  
  // 1. Tambahkan service ini
  final GamificationService _gamificationService; 

  // 2. Masukkan ke constructor
  UpdateTransactionUseCase(this._repository, this._gamificationService);

  @override
  Future<Transaction> execute(UpdateTransactionParams params) async { // Ubah jadi async/await
    final transaction = Transaction(
      id: params.transactionId,
      userId: params.userId,
      category: params.category,
      type: params.type,
      amount: params.amount,
      description: params.description,
      notes: params.notes,
      transactionDate: params.transactionDate,
      inputMethod: params.inputMethod,
      createdAt: params.createdAt,
    );
    
    // 3. Simpan update ke database
    final result = await _repository.updateTransaction(transaction);

    // 4. TRIGGER GAMIFIKASI (Hanya jika update berhasil)
    // Misal: Cek misi tipe 'update_transaction'
    try {
      await _gamificationService.updateMissionProgress('update_transaction');
    } catch (e) {
      // Jangan sampai error gamifikasi membatalkan transaksi utama
      print('Gamification error: $e');
    }

    return result;
  }
}

class UpdateTransactionParams extends Equatable {
  final String transactionId;
  final String userId;
  final Category category;
  final String type;
  final double amount;
  final String description;
  final String? notes;
  final DateTime transactionDate;
  final String inputMethod;
  final DateTime createdAt;

  const UpdateTransactionParams({
    required this.transactionId,
    required this.userId,
    required this.category,
    required this.type,
    required this.amount,
    required this.description,
    this.notes,
    required this.transactionDate,
    required this.inputMethod,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        transactionId,
        userId,
        category,
        type,
        amount,
        description,
        notes,
        transactionDate,
        inputMethod,
        createdAt,
      ];
}

