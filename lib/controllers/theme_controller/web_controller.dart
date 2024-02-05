import 'package:flutter_theme/config.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebController extends GetxController{
  bool isPolicy = false, isLoading = true;

String url ="";

  WebViewController? controller;

 @override
  void onReady() {
    // TODO: implement onReady
   dynamic  data = Get.arguments;
   url = data["url"];
isPolicy = data["isPolicy"];
update();
   controller = WebViewController()
     ..setJavaScriptMode(JavaScriptMode.unrestricted)
     ..loadRequest(Uri.parse(url))
     ..setNavigationDelegate(NavigationDelegate(
       onNavigationRequest: (NavigationRequest request) {
         return NavigationDecision.navigate;
       },
       onPageFinished: (url) {

       },

     ));
   update();
    super.onReady();
  }
}