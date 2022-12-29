import '../../../../config.dart';

class SettingListCard extends StatelessWidget {
  final dynamic data;
  final int? index;
  const SettingListCard({Key? key,this.data,this.index}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
        onTap: () async {
          if (index == 0) {
            Get.toNamed(routeName.otherSetting);
          } else if(index ==1){
            var user = appCtrl.storage.read("user");

            await FirebaseFirestore.instance
                .collection("users")
                .doc(user["id"]).delete();
            FirebaseAuth.instance.signOut();
            await appCtrl.storage.remove("user");
            await appCtrl.storage.remove("id");
            Get.offAllNamed(routeName.phone);
          }else if (index == 2) {
            var user = appCtrl.storage.read("user");

            await FirebaseFirestore.instance
                .collection("users")
                .doc(user["id"])
                .update({
              "status": "Offline",
              "lastSeen": DateTime.now()
                  .millisecondsSinceEpoch
                  .toString()
            });
            FirebaseAuth.instance.signOut();
            await appCtrl.storage.remove("user");
            await appCtrl.storage.remove("id");
            Get.offAllNamed(routeName.phone);
          }
        },
        minLeadingWidth: 0,
        title: Text(trans(data["title"]),
            style: AppCss.poppinsMedium14
                .textColor(appCtrl.appTheme.blackColor)),
        leading: Icon(data["icon"]));
  }
}
