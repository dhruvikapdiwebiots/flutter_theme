import 'package:flutter_theme/pages/theme_pages/group_chat_message/layouts/group_user_status.dart';

import '../../../../config.dart';

class GroupChatMessageAppBar extends StatelessWidget with PreferredSizeWidget{
  final String? name;
  final GestureTapCallback? callTap;
  const GroupChatMessageAppBar({Key? key,this.name,this.callTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return  AppBar(
        actions: [
          IconButton(
            onPressed: (){},
            icon:  Icon(Icons.video_call,color: appCtrl.appTheme.whiteColor),
          ),
          IconButton(
            onPressed: callTap,
            icon:  Icon(Icons.call,color: appCtrl.appTheme.whiteColor,),
          ),
          IconButton(
            onPressed: () {},
            icon:  Icon(Icons.more_vert,color: appCtrl.appTheme.whiteColor),
          ),
        ],
        title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name ?? "",
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: appCtrl.appTheme.accent,
                    fontWeight: FontWeight.bold,
                    fontSize: 16),
              ),
              const VSpace(Sizes.s6),
             const GroupUserLastSeen()
            ]));
  }


  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
