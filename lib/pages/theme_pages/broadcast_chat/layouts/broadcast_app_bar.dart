import '../../../../config.dart';

class BroadCastAppBar extends StatelessWidget with PreferredSizeWidget{
  final String? name;
  const BroadCastAppBar({Key? key,this.name}) : super(key: key);

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
            ]));
  }


  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
