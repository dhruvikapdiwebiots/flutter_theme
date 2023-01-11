import '../../../../config.dart';

class ChatMessageAppBar extends StatelessWidget with PreferredSizeWidget{
  final String? name;
  final GestureTapCallback? callTap,moreTap;
  final bool isBlock;
  const ChatMessageAppBar({Key? key,this.name,this.callTap,this.moreTap,this.isBlock = false}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return  AppBar( backgroundColor: appCtrl.appTheme.primary,
automaticallyImplyLeading: false,
        leading: Icon(Icons.arrow_back,color: appCtrl.appTheme.white,).inkWell(onTap: ()=>Get.back()),
        actions: [
          IconButton(
            onPressed: (){},
            icon:  Icon(Icons.video_call,color: appCtrl.appTheme.white),
          ),
          IconButton(
            onPressed: callTap,
            icon:  Icon(Icons.call,color: appCtrl.appTheme.white),
          ),
          PopupMenuButton<int>(
            icon: Icon(Icons.more_vert,color: appCtrl.appTheme.white),
            itemBuilder: (context) {
              return <PopupMenuEntry<int>>[
                PopupMenuItem(value: 0,onTap: moreTap,child: Text(isBlock ? fonts.unblock.tr : fonts.block.tr),),
              ];
            },
          ),
        ],
        title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name ?? "",
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: appCtrl.appTheme.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16),
              ),
              const VSpace(Sizes.s10),
              const UserLastSeen()
            ]));
  }


  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
