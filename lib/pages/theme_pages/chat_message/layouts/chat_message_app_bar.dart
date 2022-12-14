import '../../../../config.dart';

class ChatMessageAppBar extends StatelessWidget with PreferredSizeWidget{
  final String? name;
  const ChatMessageAppBar({Key? key,this.name}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return  AppBar(
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
             // const UserLastSeen()
            ]));
  }


  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
