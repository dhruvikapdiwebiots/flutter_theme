import 'dart:developer';

import '../../../../../config.dart';
import 'chat_user_app_bar.dart';

class ChatUserProfile extends StatefulWidget {
  const ChatUserProfile({Key? key}) : super(key: key);

  @override
  State<ChatUserProfile> createState() => _ChatUserProfileState();
}

class _ChatUserProfileState extends State<ChatUserProfile> {
  var scrollController = ScrollController();
  int topAlign = 5;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    scrollController = ScrollController()
      ..addListener(() {
        setState(() {});
      });
  }

//----------
  bool get isSliverAppBarExpanded {
    return scrollController.hasClients &&
        scrollController.offset > (130 - kToolbarHeight);
  }

  @override
  Widget build(BuildContext context) {
    if (isSliverAppBarExpanded) {
      topAlign = topAlign + 1;
    } else {
      topAlign = 5;
    }
    return Scaffold(
      backgroundColor: isSliverAppBarExpanded
          ? appCtrl.appTheme.bgColor
          : appCtrl.appTheme.primary,
      body: GetBuilder<ChatController>(builder: (chatCtrl) {
        return Stack(alignment: Alignment.center, children: [
          NestedScrollView(
              controller: scrollController,
              physics: const ScrollPhysics(parent: PageScrollPhysics()),
              headerSliverBuilder:
                  (BuildContext context, bool innerBoxIsScrolled) {
                return [
                  ChatUserProfileAppBar(
                      image: chatCtrl.pData["image"],
                      isSliverAppBarExpanded: isSliverAppBarExpanded,
                      name: chatCtrl.pData["name"])
                ];
              },
              body: const SingleChildScrollView(child: ChatUserProfileBody())),
          CenterPositionImage(
              image: chatCtrl.pData["image"],
              name: chatCtrl.pData["name"],
              isSliverAppBarExpanded: isSliverAppBarExpanded,
              topAlign: topAlign)
        ]);
      }),
    );
  }
}
