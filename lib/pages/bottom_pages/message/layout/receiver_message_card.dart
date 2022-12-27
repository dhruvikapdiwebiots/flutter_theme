import 'package:intl/intl.dart';

import '../../../../config.dart';

class ReceiverMessageCard extends StatelessWidget {
  final DocumentSnapshot? document;
  final String? currentUserId, blockBy;

  const ReceiverMessageCard(
      {Key? key, this.document, this.currentUserId, this.blockBy})
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
            var data = {
              "data": currentUserId != document!["receiverPhone"]
                  ? document!["receiver"]
                  : document!["receiver"],
              "chatId": document!["chatId"],
              "allData": document!
            };

            Get.toNamed(routeName.chat, arguments: data);
          },
          contentPadding: EdgeInsets.zero,
          title: Text(document!["receiver"]['name'],
              style: AppCss.poppinsblack16.textColor(appCtrl.appTheme.primary)),
          subtitle: document!["lastMessage"] != null
              ? Padding(
                  padding: const EdgeInsets.only(top: 6.0),
                  child: Row(
                    children: [
                      Icon(Icons.done_all,color: document!["isSeen"] ? appCtrl.appTheme.primary: appCtrl.appTheme.grey,size: Sizes.s16),
                      const HSpace(Sizes.s10),
                      Text(
                          document!["isBlock"] == true && document!["isBlock"] == "true"
                              ? document!["blockBy"] != blockBy
                              ? document!["blockUserMessage"]
                              : document!["lastMessage"].contains("http")
                              : document!["lastMessage"].contains("http")
                              ? "Media Share"
                              : document!["lastMessage"],
                          style: AppCss.poppinsMedium14
                              .textColor(appCtrl.appTheme.grey)),
                    ],
                  ),
                )
              : Container(),
          leading: document!["receiver"]['image'] != null &&
                  document!["receiver"]['image'] != ""
              ? CircleAvatar(
                  backgroundImage: NetworkImage(document!["receiver"]['image']),
                  radius: Sizes.s25)
              : CircleAvatar(
                  backgroundImage: AssetImage(imageAssets.user),
                  radius: Sizes.s25),
          trailing: Text(
              DateFormat('HH:mm a').format(DateTime.fromMillisecondsSinceEpoch(
                  int.parse(document!['updateStamp']))),
              style:
                  AppCss.poppinsMedium12.textColor(appCtrl.appTheme.primary))),
    );
  }
}
