import 'package:intl/intl.dart';

import '../../../../config.dart';

class MessageCard extends StatelessWidget {
  final DocumentSnapshot? document;
  final String? currentUserId, blockBy;

  const MessageCard({Key? key, this.document, this.currentUserId, this.blockBy})
      : super(key: key);

  @override
  Widget build(BuildContext context) {

    return Container(
      margin: const EdgeInsets.only(
          bottom: Insets.i10, left: Insets.i5, right: Insets.i5),
      child: ListTile(
          onTap: () {
            FirebaseFirestore.instance
                .collection("contacts")
                .doc(document!.id)
                .update({"isSeen": true});
            var data = {
              "data": currentUserId != document!["senderPhone"]
                  ? document!["sender"]
                  : document!["receiver"],
              "chatId": document!["chatId"],
              "allData": document!
            };
            Get.toNamed(routeName.chat, arguments: data);
          },
          contentPadding: EdgeInsets.zero,
          title: Text(document!["sender"]['name'],
              style: AppCss.poppinsblack16.textColor(appCtrl.appTheme.blackColor)),
          subtitle: document!["lastMessage"] != null
              ? Padding(
                  padding: const EdgeInsets.only(top: Insets.i6),
                  child: Row(
                    children: [
                      currentUserId != document!["senderPhone"]
                          ? Container()
                          : Icon(Icons.done_all,
                              color: document!["isSeen"]
                                  ? appCtrl.appTheme.primary
                                  : appCtrl.appTheme.grey,
                              size: Sizes.s16),
                      currentUserId != document!["senderPhone"]
                          ? Container()
                          : const HSpace(Sizes.s10),
                      Text(
                          document!["lastMessage"].contains("http")
                              ? "Media Share"
                              : document!["lastMessage"],
                          style: AppCss.poppinsMedium14
                              .textColor(appCtrl.appTheme.grey)),
                    ],
                  ),
                )
              : Container(),
          leading: document!["sender"]['image'] != null ||
                  document!["sender"]['image'] != ""
              ? StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .where("phone", isEqualTo: document!["senderPhone"])
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.data != null) {
                  if (!snapshot.data!.docs.isNotEmpty) {
                    return Image.asset(
                      imageAssets.user,
                      color: appCtrl.appTheme.whiteColor,
                    ).paddingAll(Insets.i15).decorated(
                        color: appCtrl.appTheme.grey.withOpacity(.4),
                        shape: BoxShape.circle);
                  } else {
                    return CachedNetworkImage(
                        imageUrl: (snapshot.data!).docs[0]["image"],
                        imageBuilder: (context, imageProvider) => CircleAvatar(
                          backgroundColor: const Color(0xffE6E6E6),
                          radius: 28,
                          backgroundImage: NetworkImage(
                              '${document!["receiver"]['image']}'),
                        ),
                        placeholder: (context, url) => Image.asset(
                          imageAssets.user,
                          color: appCtrl.appTheme.whiteColor,
                        ).paddingAll(Insets.i15).decorated(
                            color: appCtrl.appTheme.grey.withOpacity(.4),
                            shape: BoxShape.circle),
                        errorWidget: (context, url, error) => Image.asset(
                          imageAssets.user,
                          color: appCtrl.appTheme.whiteColor,
                        ).paddingAll(Insets.i15).decorated(
                            color: appCtrl.appTheme.grey.withOpacity(.4),
                            shape: BoxShape.circle));
                  }
                } else {
                  return Image.asset(
                    imageAssets.user,
                    color: appCtrl.appTheme.whiteColor,
                  ).paddingAll(Insets.i15).decorated(
                      color: appCtrl.appTheme.grey.withOpacity(.4),
                      shape: BoxShape.circle);
                }
              })
              : Image.asset(
                  imageAssets.user,
                  color: appCtrl.appTheme.whiteColor,
                ).paddingAll(Insets.i15).decorated(
                  color: appCtrl.appTheme.grey.withOpacity(.4),
                  shape: BoxShape.circle),
          trailing: Text(
              DateFormat('HH:mm a').format(DateTime.fromMillisecondsSinceEpoch(
                  int.parse(document!['updateStamp']))),
              style:
                  AppCss.poppinsMedium12.textColor(appCtrl.appTheme.primary))),
    );
  }
}
