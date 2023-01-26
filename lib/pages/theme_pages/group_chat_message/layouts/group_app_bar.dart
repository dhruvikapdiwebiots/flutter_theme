import '../../../../config.dart';

class GroupChatMessageAppBar extends StatelessWidget with PreferredSizeWidget {
  final String? name, image;
  final VoidCallback? callTap,moreTap,videoTap;

  const GroupChatMessageAppBar({Key? key, this.name, this.callTap, this.image,this.videoTap,this.moreTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
        automaticallyImplyLeading: false,
        titleSpacing: 0,
        backgroundColor: appCtrl.appTheme.primary,
        leading: Icon(
          Icons.arrow_back,
          color: appCtrl.appTheme.white,
        ).inkWell(onTap: () => Get.back()),
        actions: [
          IconButton(
            onPressed: videoTap,
            icon:  Icon(Icons.video_call,color: appCtrl.appTheme.white),
          ),
          IconButton(
            onPressed: callTap,
            icon:  Icon(Icons.call,color: appCtrl.appTheme.white),
          ),

        ],
        title: Row(
          children: [
            CachedNetworkImage(
                imageUrl: image!,
                imageBuilder: (context, imageProvider) => CircleAvatar(
                      backgroundColor: appCtrl.appTheme.contactBgGray,
                      radius: 15,
                      backgroundImage: NetworkImage(image!),
                    ),
                placeholder: (context, url) => CircleAvatar(
                      backgroundColor: appCtrl.appTheme.contactBgGray,
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
                style: AppCss.poppinsblack14.textColor(appCtrl.appTheme.white),
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
