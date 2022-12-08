
import 'package:flutter_theme/config.dart';

class Chat extends StatelessWidget {
  final chatCtrl = Get.put(ChatController());

  Chat({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ChatController>(builder: (_) {
      return WillPopScope(
        onWillPop: chatCtrl.onBackPress,
        child: Scaffold(
          appBar: AppBar(
              title: Text(
                chatCtrl.pName!,
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: appCtrl.appTheme.accent,
                    fontWeight: FontWeight.bold,
                    fontSize: 16),
              ),
              centerTitle: true),
          backgroundColor: Colors.white,
          body: Stack(
            children: [
              Container(
                  decoration: BoxDecoration(
                      image: DecorationImage(
                          image: AssetImage(imageAssets.chatBg),
                          fit: BoxFit.cover))),
              Stack(
                children: <Widget>[
                  Column(
                    children: <Widget>[
                      // List of messages
                      const MessageBox(),
                      // Sticker
                      Container(),
                      // Input content
                      const InputBox(),
                    ],
                  ),
                  // Loading
                  const BuildLoader()
                ],
              ),
            ],
          ),
        ),
      );
    });
  }
}
