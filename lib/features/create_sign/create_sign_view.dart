import 'package:easy_signature/common/widgets/app_scaffold.dart';
import 'package:easy_signature/core/widgets/base_statefull_widget.dart';
import 'package:easy_signature/features/create_sign/create_sign_view_model.dart';
import 'package:easy_signature/features/create_sign/widget/sign_drawing_canvas.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CreateSignView extends StatefulWidget {
  const CreateSignView({super.key});

  @override
  State<CreateSignView> createState() => _CreateSignViewState();
}

class _CreateSignViewState extends BaseStatefullWidget<CreateSignView> {
  @override
  Widget build(BuildContext context) {
    final uiState = context.watch<CreateSignViewModel>().state;

    return AppScaffold(
      topbarTitle: 'Create Sign',
      child: Column(
        children: [
          const SignDrawingCanvas(),
          Row(
            children: DrawingSignColorOptions.values
                .map(
                  (option) => GestureDetector(
                    onTap: () {
                      context.read<CreateSignViewModel>().onAction(OnChangeColor(color: option));
                    },
                    child: DecoratedBox(
                      decoration: BoxDecoration(border: option == uiState.selectedColor ? Border.all() : null),
                      child: CircleAvatar(
                        child: ColoredBox(color: option.color),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}
