import '../../../../config.dart';

class SettingListCard extends StatelessWidget {
  final dynamic data;
  final int? index;
  const SettingListCard({Key? key,this.data,this.index}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SettingController>(
      builder: (settingCtrl) {
        return ListTile(
            onTap: () async {
              if (index == 0) {
                Get.toNamed(routeName.otherSetting);
              } else if(index ==1){
                settingCtrl.deleteUser();

              }else if (index == 2) {
                var user = appCtrl.storage.read(session.user);

                await FirebaseFirestore.instance
                    .collection(collectionName.users)
                    .doc(user["id"])
                    .update({
                  "status": "Offline",
                  "lastSeen": DateTime.now()
                      .millisecondsSinceEpoch
                      .toString()
                });
                FirebaseAuth.instance.signOut();
                await appCtrl.storage.remove(session.user);
                await appCtrl.storage.remove(session.id);
                await appCtrl.storage.remove(session.isDarkMode);
                await appCtrl.storage.remove(session.isRTL);
                await appCtrl.storage.remove(session.languageCode);
                await appCtrl.storage.remove(session.languageCode);
                Get.offAllNamed(routeName.phone);
              }
            },
            minLeadingWidth: 0,
            title: Text(trans(data["title"]),
                style: AppCss.poppinsMedium14
                    .textColor(appCtrl.appTheme.blackColor)),
            leading: Icon( data["icon"], color: data["title"] == "logout" ?  appCtrl.appTheme.redColor :appCtrl.appTheme.txt,));
      }
    );
  }
}
