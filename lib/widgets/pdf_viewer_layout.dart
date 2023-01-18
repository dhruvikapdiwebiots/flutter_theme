import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:flutter_theme/config.dart';
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class PdfViewerLayout extends StatefulWidget {
  final String? url;
  const PdfViewerLayout({Key? key,this.url}) : super(key: key);

  @override
  State<PdfViewerLayout> createState() => _PdfViewerLayoutState();
}

class _PdfViewerLayoutState extends State<PdfViewerLayout> {
  String remotePDFpath = "";

  @override
  void initState() {
    super.initState();

    createFileOfPdfUrl().then((f) {
      setState(() {

      });
    });


  }

  Future<File> createFileOfPdfUrl() async {
    Completer<File> completer = Completer();
    print("Start download file from internet!");
    try {
      // "https://berlin2017.droidcon.cod.newthinking.net/sites/global.droidcon.cod.newthinking.net/files/media/documents/Flutter%20-%2060FPS%20UI%20of%20the%20future%20%20-%20DroidconDE%2017.pdf";
      // final url = "https://pdfkit.org/docs/guide.pdf";
      final url = widget.url;
      final filename = url?.substring(url.lastIndexOf("/") + 1);
      var request = await HttpClient().getUrl(Uri.parse(url!));
      var response = await request.close();
      var bytes = await consolidateHttpClientResponseBytes(response);
      var dir = await getApplicationDocumentsDirectory();
      print("Download files");
      print("${dir.path}/$filename");
      File file = File("${dir.path}/$filename");

      await file.writeAsBytes(bytes, flush: true);
      completer.complete(file);

      remotePDFpath = file.path;
      setState(() {

      });
      log("remotePDFpath : ${file.path}");
    } catch (e) {
      throw Exception('Error parsing asset file!');
    }

    return completer.future;
  }

  @override
  Widget build(BuildContext context) {
    final GlobalKey<SfPdfViewerState> pdfViewerKey = GlobalKey();
    return Scaffold(
      body:  PDFView(
        filePath: remotePDFpath,
        enableSwipe: true,
        swipeHorizontal: true,
        autoSpacing: false,
        pageFling: true,
        pageSnap: true,
        defaultPage: 0,
        fitPolicy: FitPolicy.BOTH,
        preventLinkNavigation:
        false, // if set to true the link is handled in flutter

        onLinkHandler: (String? uri) {
          print('goto uri: $uri');
        },

      ),
    );
  }
}
