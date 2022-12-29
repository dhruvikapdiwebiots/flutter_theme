import 'package:flutter_theme/config.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class PdfViewerLayout extends StatelessWidget {
  final String? url;
  const PdfViewerLayout({Key? key,this.url}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final GlobalKey<SfPdfViewerState> pdfViewerKey = GlobalKey();
    return Scaffold(
      body: SfPdfViewer.network(
        url!,
        key: pdfViewerKey,
      ),
    );
  }
}
