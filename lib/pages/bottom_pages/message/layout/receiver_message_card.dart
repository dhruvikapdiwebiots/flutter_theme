import 'dart:developer';

import 'package:flutter_theme/models/contact_model.dart';
import 'package:intl/intl.dart';

import '../../../../config.dart';

class ReceiverMessageCard extends StatelessWidget {
  final DocumentSnapshot? document;
  final String? currentUserId, blockBy;

  const ReceiverMessageCard(
      {Key? key, this.currentUserId, this.blockBy, this.document})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<MessageController>(builder: (msgCtrl) {
      return StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection("users")
              .doc(document!["receiverId"])
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
                          uid: document!["receiverId"],
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
                            .where("id", isEqualTo: document!["receiverId"])
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
                                        backgroundColor:
                                            const Color(0xffE6E6E6),
                                        radius: 28,
                                        backgroundImage: NetworkImage(
                                            '${(snapshot.data!).docs[0]["image"]}'),
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
                    trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Text(
                              DateFormat('HH:mm a').format(
                                  DateTime.fromMillisecondsSinceEpoch(
                                      int.parse(document!['updateStamp']))),
                              style: AppCss.poppinsMedium12
                                  .textColor(appCtrl.appTheme.grey)),
                          if (currentUserId == document!["senderId"])
                            if (msgCtrl.unSeen != 0)
                              CircleAvatar(
                                backgroundColor: appCtrl.appTheme.redColor,
                                radius: AppRadius.r10,
                                child: Text(msgCtrl.unSeen.toString(),
                                        textAlign: TextAlign.center,
                                        style: AppCss.poppinsMedium12.textColor(
                                            appCtrl.appTheme.whiteColor))
                                    .paddingSymmetric(vertical: Insets.i5),
                              )
                        ]),
                    title: Text(snapshot.data!["name"],
                        style: AppCss.poppinsblack16
                            .textColor(appCtrl.appTheme.blackColor)),
                    subtitle: document!["lastMessage"] != null
                        ? Padding(
                            padding: const EdgeInsets.only(top: 6.0),
                            child: Row(
                              children: [
                                Icon(Icons.done_all,
                                    color: document!["isSeen"]
                                        ? appCtrl.isTheme ?appCtrl.appTheme.white : appCtrl.appTheme.primary
                                        : appCtrl.appTheme.grey,
                                    size: Sizes.s16),
                                const HSpace(Sizes.s10),
                                document!["lastMessage"].contains(".gif") ?const Icon(Icons.gif_box) :
                                Expanded(
                                  child:  Text(
                                      (document!["lastMessage"].contains("media")) ? "${snapshot.data!["name"]} Media Share" :   document!["isBlock"] == true &&
                                              document!["isBlock"] == "true"
                                          ? document!["blockBy"] != blockBy
                                              ? document!["blockUserMessage"]
                                              : document!["lastMessage"]
                                                  .contains("http")
                                          :  (document!["lastMessage"].contains(".pdf") ||
                                          document!["lastMessage"]
                                              .contains(".docx") ||
                                          document!["lastMessage"]
                                              .contains(".mp3") ||
                                          document!["lastMessage"]
                                              .contains(".mp4") ||
                                          document!["lastMessage"]
                                              .contains(".xlsx") ||
                                          document!["lastMessage"]
                                              .contains(".ods"))
                                          ? document!["lastMessage"]
                                          .split("-BREAK-")[0]
                                              : document!["lastMessage"],
                                      style: AppCss.poppinsMedium14
                                          .textColor(appCtrl.appTheme.grey),
                                      overflow: TextOverflow.ellipsis),
                                ),
                              ],
                            ),
                          )
                        : Container()),
              );
            }
          });
    });
  }
}
