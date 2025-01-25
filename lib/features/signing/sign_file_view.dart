import 'package:easy_signature/features/load_files/load_file_view.dart';
import 'package:easy_signature/features/signing/data/signable_file.dart';
import 'package:easy_signature/features/signing/pdf/pdf_signing_view.dart';
import 'package:easy_signature/features/signing/sign_file_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SignFileView extends StatefulWidget {
  const SignFileView({super.key});

  @override
  State<SignFileView> createState() => _SignFileViewState();
}

class _SignFileViewState extends State<SignFileView> {
  final String signatureImageAssetPath = 'assets/signature.png';

  final signImageWidgetKey = GlobalKey();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await context.read<SignFileViewModel>().initSignImage(signatureImageAssetPath, const Size(120, 50), context);
    });
  }

  @override
  Widget build(BuildContext context) {
    final uiState = context.watch<SignFileViewModel>().state;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: const Icon(Icons.arrow_back_ios_new),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            if (uiState.pickedFile == null) ...{
              const Center(
                child: CircularProgressIndicator(),
              ),
            } else ...{
              Expanded(
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: switch (uiState.pickedFile!.signableFileExtension!) {
                        SignableFileExtension.pdf => const PdfSigningView(),
                        SignableFileExtension.jpg => const SizedBox.shrink(),
                        SignableFileExtension.png => const SizedBox.shrink(),
                      },
                    ),
                    Positioned(
                      left: uiState.signImage!.offset.dx,
                      top: uiState.signImage!.offset.dy,
                      width: 120,
                      height: 50,
                      child: GestureDetector(
                        onPanUpdate: (details) {
                          context.read<SignFileViewModel>().updateSignImageOffset(details.globalPosition);
                        },
                        onTapDown: (details) {
                          if (context.read<SignFileViewModel>().state.signImage?.offset == Offset.zero) {
                            context.read<SignFileViewModel>().updateSignImageOffset(details.globalPosition);
                          }
                        },
                        child: SignImageAsset(path: signatureImageAssetPath, globalKey: signImageWidgetKey),
                      ),
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  final newPath = await context.read<SignFileViewModel>().saveFile();

                  if (context.mounted && newPath != null) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Signature added and saved to $newPath')));
                  }
                },
                child: const Text('Save'),
              ),
            },
          ],
        ),
      ),
    );
  }
}
