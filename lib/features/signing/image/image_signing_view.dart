import 'package:easy_signature/core/widgets/base_statefull_widget.dart';
import 'package:easy_signature/features/signing/sign_file_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ImageSigningView extends StatefulWidget {
  const ImageSigningView({super.key});

  @override
  State<ImageSigningView> createState() => _ImageSigningViewState();
}

class _ImageSigningViewState extends BaseStatefullWidget<ImageSigningView> {
  @override
  Widget build(BuildContext context) {
    final uiState = context.watch<SignFileViewModel>().state;

    return Image.memory(uiState.pickedFile!.bytes!);
  }
}
