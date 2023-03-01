import 'package:flutter_theme/widgets/common_extension.dart';

import '../../../../config.dart';

class MessageCard extends StatelessWidget {
  final DocumentSnapshot? document;
  final String? currentUserId, blockBy;

  const MessageCard({Key? key, this.document, this.currentUserId, this.blockBy})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection(collectionName.users)
            .doc(document!["senderId"])
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Container();
          } else {
            return ListTile(
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
                    leading: ImageLayout(id: document!["senderId"]),
                    trailing: TrailingLayout(
                        currentUserId: currentUserId, document: document),
                    title: Text(snapshot.data!["name"],
                        style: AppCss.poppinsblack16
                            .textColor(appCtrl.appTheme.blackColor)),
                    subtitle: document!["lastMessage"] != null
                        ? document!["lastMessage"].contains(".gif")
                            ? const Icon(Icons.gif_box)
                            : MessageCardSubTitle(
                                blockBy: blockBy,
                                name: snapshot.data!["name"],
                                document: document,
                                currentUserId: currentUserId,
                              )
                        : Container())
                .paddingSymmetric(horizontal: Insets.i15, vertical: Insets.i5)
                .commonDecoration()
                .marginSymmetric(horizontal: Insets.i10);
          }
        });
  }
}
