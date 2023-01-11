import '../../../../config.dart';

class BroadCastAppBar extends StatelessWidget with PreferredSizeWidget{
  final String? name,nameList;
  const BroadCastAppBar({Key? key,this.name,this.nameList}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return  AppBar(
      backgroundColor: appCtrl.appTheme.primary,
        automaticallyImplyLeading: false,
        leading: IconButton(
            icon: Icon(Icons.arrow_back,
                color: appCtrl.appTheme.white),
            onPressed: () {
              Get.back();

            }),
        title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name ?? "",
                textAlign: TextAlign.center,
                style: AppCss.poppinsBold16.textColor(appCtrl.appTheme.white),
              ),
              const VSpace(Sizes.s10),
              Text(nameList!,style: AppCss.poppinsMedium14.textColor(appCtrl.appTheme.white),)
            ]));
  }


  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
