import '../../../../config.dart';

class ChatMessageAppBar extends StatelessWidget with PreferredSizeWidget{
  final String? name;
  final GestureTapCallback? callTap,moreTap;
  final bool isBlock;
  const ChatMessageAppBar({Key? key,this.name,this.callTap,this.moreTap,this.isBlock = false}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return  AppBar(
        actions: [
          IconButton(
            onPressed: (){},
            icon: const Icon(Icons.video_call),
          ),
          IconButton(
            onPressed: callTap,
            icon: const Icon(Icons.call),
          ),
          PopupMenuButton<int>(
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
                    color: appCtrl.appTheme.accent,
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
