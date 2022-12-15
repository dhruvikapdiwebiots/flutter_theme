import 'package:intl/intl.dart';

import '../../../../config.dart';

class ReceiverMessageCard extends StatelessWidget {
  final DocumentSnapshot? document;
  final String? currentUserId;

  const ReceiverMessageCard({Key? key, this.document, this.currentUserId})
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
          onTap: () => Get.toNamed(routeName.chat,
              arguments: currentUserId != document!["receiverId"]
                  ? document!["receiver"]
                  : document!["receiver"]),
          contentPadding: EdgeInsets.zero,
          title: Text( document!["receiver"]['name'],
              style: AppCss.poppinsblack16.textColor(appCtrl.appTheme.primary)),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 6.0),
            child: Text(
                document!["lastMessage"].contains("http")
                    ? "Media Share"
                    : document!["lastMessage"],
                style: AppCss.poppinsMedium14.textColor(appCtrl.appTheme.grey)),
          ),
          leading: document!["receiver"]['image'] != null &&
              document!["receiver"]['image'] != ""
              ? CircleAvatar(
            backgroundImage: NetworkImage(document!["receiver"]['image']),
            radius: 25,
          )
              : CircleAvatar(
            backgroundImage: AssetImage(imageAssets.user),
            radius: 25,
          ),
          trailing: Text(
              DateFormat('HH:mm a').format(DateTime.fromMillisecondsSinceEpoch(
                  int.parse(document!['timestamp']))),
              style:
              AppCss.poppinsMedium12.textColor(appCtrl.appTheme.primary))),
    );
  }
}
