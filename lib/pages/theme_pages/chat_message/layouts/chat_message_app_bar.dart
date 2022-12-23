import '../../../../config.dart';

class ChatMessageAppBar extends StatelessWidget with PreferredSizeWidget{
  final String? name;
  final GestureTapCallback? callTap,moreTap;
  const ChatMessageAppBar({Key? key,this.name,this.callTap,this.moreTap}) : super(key: key);

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
                PopupMenuItem(child: Text('Block'), value: 0,onTap: moreTap,),
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
