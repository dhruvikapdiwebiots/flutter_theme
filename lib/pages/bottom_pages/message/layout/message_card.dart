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
      /*child: TextButton(
        child: currentUserId != document!["senderId"] ? Row(
          children: <Widget>[
            Material(
              borderRadius: const BorderRadius.all(Radius.circular(AppRadius.r25)),
              clipBehavior: Clip.hardEdge,
              child: document!["sender"]['image'] != null && document!["sender"]['image'] != ""
                  ? CachedNetworkImage(
                placeholder: (context, url) => Container(
                  width: Sizes.s50,
                  height: Sizes.s50,
                  padding: const EdgeInsets.all(10.0),
                  child: CircularProgressIndicator(
                      strokeWidth: 1.0,
                      valueColor: AlwaysStoppedAnimation<Color>(
                          appCtrl.appTheme.primary)
                  ),
                ),
                imageUrl: document!["sender"]['image'],
                width: Sizes.s40,
                height: Sizes.s40,
                fit: BoxFit.cover,
              )
                  : Icon(Icons.account_circle,
                  size: 50.0, color: appCtrl.appTheme.grey),
            ),
            Flexible(
              child: Container(
                  margin: const EdgeInsets.only(left: 10.0),
                  child: Column(children: <Widget>[
                    Container(
                        alignment: Alignment.centerLeft,
                        margin: const EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 5.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(document!["sender"]['name'],
                                style: AppCss.poppinsblack16
                                    .textColor(appCtrl.appTheme.primary)),
                            const VSpace(Sizes.s6),
                            Text(
                              document!["lastMessage"].contains("http") ?"Media Share" :document!["lastMessage"],
                              style: AppCss.poppinsMedium14
                                  .textColor(appCtrl.appTheme.grey),
                            )
                          ],
                        ))
                  ])),
            )
          ],
        ):  Row(
          children: <Widget>[
            Material(
              borderRadius: const BorderRadius.all(Radius.circular(AppRadius.r25)),
              clipBehavior: Clip.hardEdge,
              child: document!["receiver"]['image'] != null && document!["receiver"]['image'] != ""
                  ? CachedNetworkImage(
                placeholder: (context, url) => Container(
                  width: Sizes.s50,
                  height: Sizes.s50,
                  padding: const EdgeInsets.all(10.0),
                  child: CircularProgressIndicator(
                      strokeWidth: 1.0,
                      valueColor: AlwaysStoppedAnimation<Color>(
                          appCtrl.appTheme.primary)
                  ),
                ),
                imageUrl: document!["receiver"]['image'],
                width: Sizes.s40,
                height: Sizes.s40,
                fit: BoxFit.cover,
              )
                  : Icon(Icons.account_circle,
                  size: 50.0, color: appCtrl.appTheme.grey),
            ),
            Flexible(
              child: Container(
                  margin: const EdgeInsets.only(left: 10.0),
                  child: Column(children: <Widget>[
                    Container(
                        alignment: Alignment.centerLeft,
                        margin: const EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 5.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(document!["receiver"]['name'],
                                style: AppCss.poppinsblack16
                                    .textColor(appCtrl.appTheme.primary)),
                            const VSpace(Sizes.s6),
                            Text(
                              document!["lastMessage"].contains("http") ?"Media Share" :document!["lastMessage"],
                              style: AppCss.poppinsMedium14
                                  .textColor(appCtrl.appTheme.grey),
                            )
                          ],
                        ))
                  ])),
            )
          ],
        ),
        onPressed: () {


        },
      ),*/
      child: ListTile(
          onTap: () => Get.toNamed(routeName.chat,
              arguments: currentUserId != document!["senderId"]
                  ? document!["sender"]
                  : document!["receiver"]),
          contentPadding: EdgeInsets.zero,
          title: Text(document!["sender"]['name'],
              style: AppCss.poppinsblack16.textColor(appCtrl.appTheme.primary)),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 6.0),
            child: Text(
                document!["lastMessage"].contains("http")
                    ? "Media Share"
                    : document!["lastMessage"],
                style: AppCss.poppinsMedium14.textColor(appCtrl.appTheme.grey)),
          ),
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
                  int.parse(document!['timestamp']))),
              style:
                  AppCss.poppinsMedium12.textColor(appCtrl.appTheme.primary))),
    );
  }
}
