import 'package:alh_pdf_view/alh_pdf_view.dart';
import 'package:flutter/material.dart';

class PdfControllerButons extends StatelessWidget {
  const PdfControllerButons({required this.pdfControllerNotifier, super.key});

  final ValueNotifier<AlhPdfViewController?> pdfControllerNotifier;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: pdfControllerNotifier,
      builder: (context, controller, _) {
        return FutureBuilder(
          future: controller?.getPageCount(),
          builder: (context, snapshot) {
            if (snapshot.data == null || snapshot.requireData == 1) return const SizedBox.shrink();

            return Column(
              children: [
                Row(
                  children: [
                    IconButton.filled(
                      onPressed: () {
                        controller?.goToPreviousPage();
                      },
                      icon: const Icon(
                        Icons.chevron_left,
                      ),
                    ),
                    IconButton.filled(
                      onPressed: () {
                        controller?.goToNextPage();
                      },
                      icon: const Icon(Icons.chevron_right),
                    ),
                  ],
                ),
                FutureBuilder(
                  future: controller?.getCurrentPage(),
                  builder: (context, currentPageSnapshot) {
                    if (currentPageSnapshot.data == null) return const SizedBox.shrink();

                    return Text(
                      '${currentPageSnapshot.requireData + 1}/${snapshot.requireData}',
                    );
                  },
                )
              ],
            );
          },
        );
      },
    );
  }
}
