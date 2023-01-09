import 'package:intl/intl.dart';

import '../../../../config.dart';
import '../../../../models/contact_model.dart';

class MessageCard extends StatelessWidget {
  final DocumentSnapshot? document;
  final String? currentUserId, blockBy;

  const MessageCard({Key? key, this.document, this.currentUserId, this.blockBy})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection("users")
            .doc(document!["senderId"])
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Container();
          } else {
            return Container(
              margin: const EdgeInsets.only(
                  bottom: Insets.i10, left: Insets.i5, right: Insets.i5),
              child: ListTile(
                  onTap: () {
                    UserContactModel userContact = UserContactModel(
                        username: snapshot.data!["name"],
                        uid: document!["senderId"],
                        phoneNumber: snapshot.data!["phone"],
                        image: snapshot.data!["image"],
                        isRegister: true);
                    var data = {
                      "chatId": document!["chatId"],
                      "data": userContact
                    };
                    Get.toNamed(routeName.chat, arguments: data);
                  },
                  contentPadding: EdgeInsets.zero,
                  leading: StreamBuilder(
                      stream: FirebaseFirestore.instance
                          .collection('users')
                          .where("id", isEqualTo: document!["senderId"])
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
                                imageBuilder: (context, imageProvider) =>
                                    CircleAvatar(
                                      backgroundColor: const Color(0xffE6E6E6),
                                      radius: 28,
                                      backgroundImage: NetworkImage(
                                          '${document!["receiver"]['image']}'),
                                    ),
                                placeholder: (context, url) => Image.asset(
                                      imageAssets.user,
                                      color: appCtrl.appTheme.whiteColor,
                                    ).paddingAll(Insets.i15).decorated(
                                        color: appCtrl.appTheme.grey
                                            .withOpacity(.4),
                                        shape: BoxShape.circle),
                                errorWidget: (context, url, error) =>
                                    Image.asset(
                                      imageAssets.user,
                                      color: appCtrl.appTheme.whiteColor,
                                    ).paddingAll(Insets.i15).decorated(
                                        color: appCtrl.appTheme.grey
                                            .withOpacity(.4),
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
                      }),
                  trailing: Text(
                      DateFormat('HH:mm a').format(
                          DateTime.fromMillisecondsSinceEpoch(
                              int.parse(document!['updateStamp']))),
                      style: AppCss.poppinsMedium12
                          .textColor(appCtrl.appTheme.grey)),
                  title: Text(snapshot.data!["name"],
                      style: AppCss.poppinsblack16
                          .textColor(appCtrl.appTheme.blackColor)),
                  subtitle: document!["lastMessage"] != null
                      ? Padding(
                          padding: const EdgeInsets.only(top: 6.0),
                          child: Row(children: [
                            Icon(Icons.done_all,
                                color: document!["isSeen"]
                                    ? appCtrl.appTheme.primary
                                    : appCtrl.appTheme.grey,
                                size: Sizes.s16),
                            const HSpace(Sizes.s10),
                            Expanded(
                              child: Text(
                                  document!["isBlock"] == true &&
                                          document!["isBlock"] == "true"
                                      ? document!["blockBy"] != blockBy
                                          ? document!["blockUserMessage"]
                                          : document!["lastMessage"]
                                              .contains("http")
                                      : document!["lastMessage"]
                                              .contains("http")
                                          ? "Media Share"
                                          : document!["lastMessage"],
                                  style: AppCss.poppinsMedium14
                                      .textColor(appCtrl.appTheme.grey),
                                  overflow: TextOverflow.ellipsis),
                            )
                          ]),
                        )
                      : Container()),
            );
          }
        });
  }
}
