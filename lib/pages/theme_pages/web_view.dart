
import 'package:flutter_theme/controllers/theme_controller/web_controller.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../config.dart';

class CheckoutWebView extends StatefulWidget {
  const CheckoutWebView({Key? key}) : super(key: key);

  @override
  State<CheckoutWebView> createState() => CheckoutWebViewState();
}


class CheckoutWebViewState extends State<CheckoutWebView> {
  String? url;
  String? token;
  int selectedIndex = 1;

  final paymentCtrl = Get.put(WebController());

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<WebController>(
      builder: (_) {
        return Scaffold(
            backgroundColor: appCtrl.appTheme.whiteColor,
            appBar: CommonAppBar(text: fonts.privacyPolicy.tr),
            body: Stack(children: [

                WebViewWidget(controller: paymentCtrl.controller!),

            ]).height(MediaQuery.of(context).size.height));
      }
    );
  }
}