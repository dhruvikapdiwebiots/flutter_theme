import 'package:intl/intl.dart';

import '../../../../config.dart';

class GroupMessageCard extends StatelessWidget {
  final DocumentSnapshot? document;
  final String? currentUserId;

  const GroupMessageCard({Key? key, this.document, this.currentUserId})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection("groups")
            .doc(document!["groupId"])
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
                    Get.toNamed(routeName.groupChatMessage,
                        arguments: snapshot.data);
                  },
                  contentPadding: EdgeInsets.zero,
                  leading: CachedNetworkImage(
                      imageUrl: (snapshot.data!)["image"],
                      imageBuilder: (context, imageProvider) => CircleAvatar(
                            backgroundColor: const Color(0xffE6E6E6),
                            radius: 28,
                            backgroundImage:
                                NetworkImage('${(snapshot.data!)['image']}'),
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
                              shape: BoxShape.circle)),
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
                          child: (document!["lastMessage"].contains(".gif"))
                              ?  const Icon(Icons.gif_box,size: Sizes.s20,).alignment(Alignment.centerLeft)

                              : Text(
                                  (document!["lastMessage"].contains(".pdf") ||
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
                                      : document!["lastMessage"] == ""
                                          ? currentUserId ==
                                                  document!["senderId"]
                                              ? "You Create this group ${document!["group"]['name']}"
                                              : "${document!["sender"]['name']} added you"
                                          : document!["lastMessage"],
                                  style: AppCss.poppinsMedium12
                                      .textColor(appCtrl.appTheme.grey)
                                      .letterSpace(.2)),
                        )
                      : Container()),
            );
          }
        });
  }
}
