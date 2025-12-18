import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_application/features/ocr_receipt/presentation/cubit/ocr_cubit.dart';
import 'package:flutter_application/features/ocr_receipt/presentation/cubit/ocr_state.dart';
import 'package:get_it/get_it.dart';
import 'package:image_picker/image_picker.dart';

class OcrPage extends StatefulWidget {
  const OcrPage({super.key});

  @override
  State<OcrPage> createState() => _OcrPageState();
}

class _OcrPageState extends State<OcrPage> {
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => GetIt.I<OcrCubit>(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Scan Receipt'),
        ),
        body: BlocConsumer<OcrCubit, OcrState>(
          listener: (context, state) {
            if (state is OcrError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message)),
              );
            }
          },
          builder: (context, state) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (_imageFile != null)
                    Expanded(
                      child: Image.file(_imageFile!),
                    )
                  else
                    const Expanded(
                      child: Center(
                        child: Icon(Icons.receipt_long, size: 100, color: Colors.grey),
                      ),
                    ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () => _pickImage(ImageSource.camera),
                        icon: const Icon(Icons.camera_alt),
                        label: const Text('Camera'),
                      ),
                      ElevatedButton.icon(
                        onPressed: () => _pickImage(ImageSource.gallery),
                        icon: const Icon(Icons.photo_library),
                        label: const Text('Gallery'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (_imageFile != null)
                    ElevatedButton(
                      onPressed: state is OcrLoading
                          ? null
                          : () {
                              context.read<OcrCubit>().scanReceipt(_imageFile!);
                            },
                      child: state is OcrLoading
                          ? const CircularProgressIndicator()
                          : const Text('Scan Receipt'),
                    ),
                  if (state is OcrSuccess) ...[
                    const SizedBox(height: 24),
                    const Text(
                      'Scan Result:',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text('Merchant: ${state.result.merchantName}'),
                    Text('Total: ${state.result.totalAmount}'),
                    Text('Date: ${state.result.date}'),
                    const SizedBox(height: 8),
                    const Text('Items:'),
                    ...state.result.items.map((item) => Text('- ${item.name}: ${item.price} x ${item.quantity}')),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
