import 'package:flutter/material.dart';

class GlobalLoaderWidget extends StatefulWidget {
  const GlobalLoaderWidget({
    required this.loading,
    super.key,
    this.message,
    this.customIndicator,
    this.onLoading,
    this.onLoaded,
    this.child,
  });
  final bool loading;
  final String? message;
  final Widget? customIndicator;
  final VoidCallback? onLoading;
  final VoidCallback? onLoaded;
  final Widget? child;

  @override
  State<GlobalLoaderWidget> createState() => _GlobalLoaderWidgetState();
}

class _GlobalLoaderWidgetState extends State<GlobalLoaderWidget> {
  OverlayEntry? _overlayEntry;

  @override
  void didUpdateWidget(covariant GlobalLoaderWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.loading && _overlayEntry == null) {
      _showOverlay();
      widget.onLoading?.call();
    } else if (!widget.loading && _overlayEntry != null) {
      _hideOverlay();
      widget.onLoaded?.call();
    }
  }

  void _showOverlay() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && widget.loading) {
        _overlayEntry = OverlayEntry(
          builder: (_) => _LoaderOverlay(
            message: widget.message,
            customIndicator: widget.customIndicator,
          ),
        );
        Overlay.of(context).insert(_overlayEntry!);
        widget.onLoading?.call();
      }
    });
  }

  void _hideOverlay() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && !widget.loading) {
        _overlayEntry?.remove();
        _overlayEntry = null;
        widget.onLoaded?.call();
      }
    });
  }

  @override
  void dispose() {
    _hideOverlay();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child ?? const SizedBox.shrink();
  }
}

class _LoaderOverlay extends StatelessWidget {
  const _LoaderOverlay({this.message, this.customIndicator});
  final String? message;
  final Widget? customIndicator;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          color: Colors.black.withValues(alpha: 0.5),
        ),
        Center(
          child: customIndicator ?? const CircularProgressIndicator(),
        ),
      ],
    );
  }
}
