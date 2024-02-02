import 'package:flutter_theme/config.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebController extends GetxController{
  bool isPayment = false, isLoading = true;

  dynamic data;

  WebViewController? controller;

 @override
  void onReady() {
    // TODO: implement onReady
   dynamic url = Get.arguments;
   data = url;

   controller = WebViewController()
     ..setJavaScriptMode(JavaScriptMode.unrestricted)
     ..loadRequest(Uri.parse(data))
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