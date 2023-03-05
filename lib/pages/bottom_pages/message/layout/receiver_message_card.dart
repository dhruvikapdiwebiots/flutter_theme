

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
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      CommonImage(image: (snapshot.data!)["image"],name: (snapshot.data!)["name"],),
                      const HSpace(Sizes.s12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(snapshot.data!["name"],
                              style: AppCss.poppinsblack14
                                  .textColor(appCtrl.appTheme.blackColor)),
                          const VSpace(Sizes.s5),
                           document!["lastMessage"] != null
                              ? SubTitleLayout(document: document,name: snapshot.data!["name"],blockBy: blockBy,)
                              : Container()
                        ],
                      ),
                    ],
                  ),
                  TrailingLayout(document: document,currentUserId: currentUserId).width(Sizes.s55)
                ],
              ).width(MediaQuery.of(context).size.width).paddingSymmetric(horizontal: Insets.i15,vertical: Insets.i12)
                  .commonDecoration()
                  .marginSymmetric(horizontal: Insets.i10).inkWell(onTap: () {
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
              });
            }
          });
    });
  }
}
