import 'dart:developer';

import 'package:flutter_theme/config.dart';

class GroupChatMessage extends StatefulWidget {
  const GroupChatMessage({Key? key}) : super(key: key);

  @override
  State<GroupChatMessage> createState() => _GroupChatMessageState();
}

class _GroupChatMessageState extends State<GroupChatMessage>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  final chatCtrl = Get.put(GroupChatMessageController());

  @override
  void initState() {
    // TODO: implement initState
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      chatCtrl.textEditingController.addListener(() async {
        if (chatCtrl.textEditingController.text.isNotEmpty) {
          chatCtrl.typing = true;
          firebaseCtrl.groupTypingStatus(
              chatCtrl.pId, chatCtrl.documentId, true);
        }
        if (chatCtrl.textEditingController.text.isEmpty &&
            chatCtrl.typing == true) {
          chatCtrl.typing = false;
          firebaseCtrl.groupTypingStatus(
              chatCtrl.pId, chatCtrl.documentId, false);
        }
        chatCtrl.update();
      });
    });
    super.initState();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      firebaseCtrl.setIsActive();
    } else {
      firebaseCtrl.setLastSeen();
    }
  }

  @override
  Widget build(BuildContext context) {
    log("use : ${chatCtrl.getPeerStatus()}");
    return GetBuilder<GroupChatMessageController>(builder: (_) {
      return WillPopScope(
          onWillPop: chatCtrl.onBackPress,
          child: Scaffold(

              appBar: GroupChatMessageAppBar(name: chatCtrl.pName,image: chatCtrl.groupImage,),
              backgroundColor: appCtrl.appTheme.whiteColor,
              body: Stack(children: <Widget>[
                //body layout
                const GroupChatBody(),
                // Loading
                if (chatCtrl.isLoading) const GroupBuildLoader()
              ])));
    });
  }
}
