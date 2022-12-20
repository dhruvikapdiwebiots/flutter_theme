import 'package:intl/intl.dart';

import '../../../../config.dart';

class GroupMessageCard extends StatelessWidget {
  final DocumentSnapshot? document;
  final String? currentUserId;

  const GroupMessageCard({Key? key, this.document, this.currentUserId})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
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
            document!["group"]['name'],
            style: AppCss.poppinsblack16
                .textColor(appCtrl.appTheme.primary)
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6.0),
          child: Text(
              document!["lastMessage"] == ""?   currentUserId == document!["senderId"]
                ? "You Create this group ${document!["group"]['name']}"
                : "${document!["sender"]['name']} added you":document!["lastMessage"],
            style: AppCss.poppinsMedium14
                .textColor(appCtrl.appTheme.grey)
          ),
        ),
        leading:document!["group"]['image'] != null && document!["group"]['image'] != "" ?  CircleAvatar(
          backgroundImage: NetworkImage(
              document!["group"]['image']
          ) ,
          radius: 25,
        ): CircleAvatar(backgroundImage: AssetImage(imageAssets.user), radius: 25,),
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
