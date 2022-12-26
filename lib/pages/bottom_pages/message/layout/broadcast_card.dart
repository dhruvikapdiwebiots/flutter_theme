import 'package:intl/intl.dart';

import '../../../../config.dart';

class BroadCastMessageCard extends StatelessWidget {
  final DocumentSnapshot? document;
  final String? currentUserId;

  const BroadCastMessageCard({Key? key, this.document, this.currentUserId})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    List selectedContact =document!["selectedContact"];
    return Container(
      decoration:
      const BoxDecoration(border: Border(bottom: BorderSide(width: 0.2))),
      padding: const EdgeInsets.symmetric(vertical: Insets.i10),
      margin: const EdgeInsets.only(
          bottom: Insets.i10, left: Insets.i5, right: Insets.i5),

      child: ListTile(
        onTap: ()=> Get.toNamed(routeName.groupChatMessage,arguments: document!["group"]),
        contentPadding: EdgeInsets.zero,
        title: Text(
            "${selectedContact.length} recipient",
            style: AppCss.poppinsblack16
                .textColor(appCtrl.appTheme.primary)
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6.0),
          child: Text(
              currentUserId == document!["senderPhone"]
                  ? "You Create this broadcast":"",
              style: AppCss.poppinsMedium14
                  .textColor(appCtrl.appTheme.grey)
          ),
        ),
        leading:CircleAvatar(backgroundImage: AssetImage(imageAssets.user), radius: 25,),
        trailing: Text(
            DateFormat('HH:mm a').format(
                DateTime.fromMillisecondsSinceEpoch(
                    int.parse(document!['updateStamp']))),
            style:  AppCss.poppinsMedium12
                .textColor(appCtrl.appTheme.primary)
        ),
      ),
    );
  }
}
