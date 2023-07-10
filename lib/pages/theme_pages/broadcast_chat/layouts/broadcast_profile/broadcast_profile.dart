import 'package:flutter_theme/pages/theme_pages/broadcast_chat/layouts/broadcast_profile/broadcast_profile_body.dart';
import '../../../../../config.dart';
import '../../../chat_message/layouts/chat_user_profile/chat_user_app_bar.dart';

class BroadcastProfile extends StatefulWidget {
  const BroadcastProfile({Key? key}) : super(key: key);

  @override
  State<BroadcastProfile> createState() => _BroadcastProfileState();
}

class _BroadcastProfileState extends State<BroadcastProfile> {
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
          : appCtrl.appTheme.bgColor,
      body: GetBuilder<BroadcastChatController>(builder: (chatCtrl) {
        return Stack(alignment: Alignment.center, children: [
          NestedScrollView(
              controller: scrollController,
              physics: const ScrollPhysics(parent: PageScrollPhysics()),
              headerSliverBuilder:
                  (BuildContext context, bool innerBoxIsScrolled) {
                return [
                  ChatUserProfileAppBar(
                      isBroadcast:true,
                      isSliverAppBarExpanded: isSliverAppBarExpanded,
                      name: chatCtrl.pName),

                ];
              },
              body: const SingleChildScrollView(child: BroadcastProfileBody())),
          Stack(
            alignment: Alignment.topCenter,
            children: [
              if(!isSliverAppBarExpanded)
              Positioned(
                top: MediaQuery.of(context).size.height / 4.3,
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: Sizes.s60,
                  decoration: ShapeDecoration(
                      color: appCtrl.appTheme.bgColor,
                      shape:const SmoothRectangleBorder(
                          borderRadius: SmoothBorderRadius.only(
                            topLeft: SmoothRadius(cornerRadius: 20, cornerSmoothing: 1),
                            topRight: SmoothRadius(cornerRadius: 20, cornerSmoothing: 1),
                          )
                      )
                  ),
                ),
              ),
              CenterPositionImage(

                isBroadcast: true,
                  name: chatCtrl.pName,
                  isSliverAppBarExpanded: isSliverAppBarExpanded,
                  topAlign: topAlign+1,),
            ],
          )
        ]);
      }),
    );
  }
}
