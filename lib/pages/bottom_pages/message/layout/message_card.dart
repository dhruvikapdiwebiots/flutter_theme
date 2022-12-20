import 'package:intl/intl.dart';

import '../../../../config.dart';

class MessageCard extends StatelessWidget {
  final DocumentSnapshot? document;
  final String? currentUserId;

  const MessageCard({Key? key, this.document, this.currentUserId})
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
          onTap: () {
            print("se ");
            var data ={
              "data":currentUserId != document!["senderId"]
                  ? document!["sender"]
                  : document!["receiver"],
              "chatId": document!["chatId"]
            };
            print("data : $data");
            Get.toNamed(routeName.chat,
                arguments:data);
          },
          contentPadding: EdgeInsets.zero,
          title: Text(document!["sender"]['name'],
              style: AppCss.poppinsblack16.textColor(appCtrl.appTheme.primary)),
          subtitle: document!["lastMessage"] != null ? Padding(
            padding: const EdgeInsets.only(top: 6.0),
            child: Text(
                document!["lastMessage"].contains("http")
                    ? "Media Share"
                    : document!["lastMessage"],
                style: AppCss.poppinsMedium14.textColor(appCtrl.appTheme.grey)),
          ):Container(),
          leading: document!["sender"]['image'] != null &&
                  document!["sender"]['image'] != ""
              ? CircleAvatar(
                  backgroundImage: NetworkImage(document!["sender"]['image']),
                  radius: 25,
                )
              : CircleAvatar(
                  backgroundImage: AssetImage(imageAssets.user),
                  radius: 25,
                ),
          trailing: Text(
              DateFormat('HH:mm a').format(DateTime.fromMillisecondsSinceEpoch(
                  int.parse(document!['updateStamp']))),
              style:
                  AppCss.poppinsMedium12.textColor(appCtrl.appTheme.primary))),
    );
  }
}
