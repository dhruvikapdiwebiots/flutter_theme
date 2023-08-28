
import 'package:flutter_theme/pages/theme_pages/group_chat_message/layouts/group_profile/group_profile_body.dart';

import '../../../../../config.dart';
import '../../../chat_message/layouts/chat_user_profile/chat_user_app_bar.dart';

class GroupProfile extends StatefulWidget {
  const GroupProfile({Key? key}) : super(key: key);

  @override
  State<GroupProfile> createState() => _GroupProfileState();
}

class _GroupProfileState extends State<GroupProfile> {
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
      body: GetBuilder<GroupChatMessageController>(builder: (chatCtrl) {
        return Stack(alignment: Alignment.center, children: [
          NestedScrollView(
              controller: scrollController,
              physics: const ScrollPhysics(parent: PageScrollPhysics()),
              headerSliverBuilder:
                  (BuildContext context, bool innerBoxIsScrolled) {
                return [
                  ChatUserProfileAppBar(
                      image: chatCtrl.groupImage,
                      isSliverAppBarExpanded: isSliverAppBarExpanded,
                      name: chatCtrl.pName)
                ];
              },
              body: const SingleChildScrollView(child: GroupProfileBody())),
          CenterPositionImage(
            isGroup: true,
              image: chatCtrl.groupImage,
              name: chatCtrl.pName,
              isSliverAppBarExpanded: isSliverAppBarExpanded,
              topAlign: topAlign,onTap:  ()=> chatCtrl.imagePickerOption(context))
        ]);
      }),
    );
  }
}
