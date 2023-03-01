

import 'package:flutter_theme/widgets/common_extension.dart';

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
              .collection(collectionName.users)
              .doc(document!["receiverId"])
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Container();
            } else {
              return ListTile(
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
                  leading:ImageLayout(id: document!["receiverId"]),
                  trailing: TrailingLayout(document: document,currentUserId: currentUserId),
                  title: Text(snapshot.data!["name"],
                      style: AppCss.poppinsblack16
                          .textColor(appCtrl.appTheme.blackColor)),
                  subtitle: document!["lastMessage"] != null
                      ? SubTitleLayout(document: document,name: snapshot.data!["name"],blockBy: blockBy,)
                      : Container()) .paddingSymmetric(horizontal: Insets.i15, vertical: Insets.i5)
                  .commonDecoration()
                  .marginSymmetric(horizontal: Insets.i10);
            }
          });
    });
  }
}
