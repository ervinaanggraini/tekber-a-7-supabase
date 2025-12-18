import 'dart:io';
import 'package:flutter_application/features/ocr_receipt/domain/entities/receipt_scan_result.dart';
import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class OcrRemoteDataSource {
  Future<ReceiptScanResult> scanReceipt(File imageFile);
}

@LazySingleton(as: OcrRemoteDataSource)
class OcrRemoteDataSourceImpl implements OcrRemoteDataSource {
  final SupabaseClient supabaseClient;

  OcrRemoteDataSourceImpl(this.supabaseClient);

  @override
  Future<ReceiptScanResult> scanReceipt(File imageFile) async {
    // Upload image to storage first (optional, depending on edge function)
    // Or send as base64
    // For now, let's assume we call the function directly with the file bytes
    
    final bytes = await imageFile.readAsBytes();
    final fileExt = imageFile.path.split('.').last;
    final fileName = '${DateTime.now().toIso8601String()}.$fileExt';

    // Upload to a temporary bucket or pass directly?
    // Let's assume we upload to 'receipts' bucket and pass the path
    
    // Note: You need to ensure 'receipts' bucket exists
    await supabaseClient.storage.from('receipts').uploadBinary(
      fileName,
      bytes,
    );

    final publicUrl = supabaseClient.storage.from('receipts').getPublicUrl(fileName);

    final response = await supabaseClient.functions.invoke(
      'ocr-receipt',
      body: {'imageUrl': publicUrl},
    );

    final data = response.data;
    
    // Parse response
    return ReceiptScanResult(
      merchantName: data['merchant_name'] ?? 'Unknown',
      totalAmount: (data['total_amount'] ?? 0).toDouble(),
      date: DateTime.tryParse(data['date'] ?? '') ?? DateTime.now(),
      items: (data['items'] as List<dynamic>?)?.map((item) => ReceiptItem(
        name: item['name'] ?? '',
        price: (item['price'] ?? 0).toDouble(),
        quantity: item['quantity'] ?? 1,
      )).toList() ?? [],
    );
  }
}
