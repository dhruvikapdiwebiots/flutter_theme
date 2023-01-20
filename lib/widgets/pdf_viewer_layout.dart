import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:flutter_theme/config.dart';
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';


class PdfViewerLayout extends StatelessWidget {
  final String? url;
  const PdfViewerLayout({Key? key,this.url}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final GlobalKey<SfPdfViewerState> pdfViewerKey = GlobalKey();
    return  SfPdfViewer.network(
      url!,
      key: pdfViewerKey,
    );
  }
}
