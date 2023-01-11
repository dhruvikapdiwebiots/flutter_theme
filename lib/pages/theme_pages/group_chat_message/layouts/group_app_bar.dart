import 'dart:developer';

import 'package:flutter_theme/pages/theme_pages/group_chat_message/layouts/group_user_status.dart';

import '../../../../config.dart';

class GroupChatMessageAppBar extends StatelessWidget with PreferredSizeWidget {
  final String? name, image;
  final GestureTapCallback? callTap;

  const GroupChatMessageAppBar({Key? key, this.name, this.callTap, this.image})
      : super(key: key);

  @override
  Widget build(BuildContext context) {

    return AppBar(
        automaticallyImplyLeading: false,
        titleSpacing: 0,
        backgroundColor: appCtrl.appTheme.primary,
        leading: Icon(Icons.arrow_back, color: appCtrl.appTheme.white,)
            .inkWell(onTap: () => Get.back()),
        actions: [
          Icon(Icons.video_call, color: appCtrl.appTheme.white,size: Sizes.s20),
          const HSpace(Sizes.s15),
          Icon(
            Icons.call,
            color: appCtrl.appTheme.white,size: Sizes.s20
          ),
          const HSpace(Sizes.s10),
          Icon(Icons.more_vert, color: appCtrl.appTheme.white,size: Sizes.s20).paddingSymmetric(horizontal: Insets.i5),
        ],
        title: Row(
          children: [
            CachedNetworkImage(
                imageUrl: image!,
                imageBuilder: (context, imageProvider) => CircleAvatar(
                      backgroundColor: const Color(0xffE6E6E6),
                      radius: 15,
                      backgroundImage: NetworkImage(image!),
                    ),
                placeholder: (context, url) => CircleAvatar(
                  backgroundColor: const Color(0xffE6E6E6),
                  radius: 15,
                  backgroundImage: NetworkImage(url),
                ),
                errorWidget: (context, url, error) => Image.asset(
                      imageAssets.user,
                  height: Sizes.s15,
                      color: appCtrl.appTheme.white,
                    ).paddingAll(Insets.i15).decorated(
                        color: appCtrl.appTheme.grey.withOpacity(.4),
                        shape: BoxShape.circle)),
            const HSpace(Sizes.s10),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(
                name ?? "",
                textAlign: TextAlign.center,
                style: AppCss.poppinsblack14
                    .textColor(appCtrl.appTheme.white),
              ),
              const VSpace(Sizes.s6),
              const GroupUserLastSeen()
            ]),
          ],
        ));
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
