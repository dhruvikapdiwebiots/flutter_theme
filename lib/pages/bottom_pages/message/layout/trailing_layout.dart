import 'dart:developer';

import 'package:intl/intl.dart';

import '../../../../config.dart';

class TrailingLayout extends StatelessWidget {
  final DocumentSnapshot? document;
  final String? currentUserId, unSeenMessage;
final dynamic data;
  const TrailingLayout(
      {Key? key, this.document, this.currentUserId, this.unSeenMessage,this.data})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<MessageController>(builder: (msgCtrl) {
      return Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [

              StreamBuilder(
                  stream: FirebaseFirestore.instance.collection(collectionName.users).doc(appCtrl.user["id"])
                      .collection(collectionName.messages)
                      .doc(document!["chatId"])
                      .collection(collectionName.chat).where("receiver",isEqualTo:  appCtrl.user["id"])
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      int number = getUnseenMessagesNumber(snapshot.data!.docs);

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                          data["time"],
                              style: AppCss.poppinsMedium12.textColor(document!["senderId"] == currentUserId ? appCtrl.appTheme.txtColor: number == 0? appCtrl.appTheme.txtColor : appCtrl.appTheme.primary)),
                          if(document!["senderId"] != currentUserId)
                            number == 0
                              ? Container()
                              : Container(
                                  height: Sizes.s20,
                                  width: Sizes.s20,alignment: Alignment.center,
                                  margin: const EdgeInsets.only(top: Insets.i5),
                                  decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: RadialGradient(
                                        colors: [
                                          appCtrl.appTheme.lightPrimary,
                                          appCtrl.appTheme.primary
                                        ],
                                      )),
                                  child: Text(number.toString(),
                                          textAlign: TextAlign.center,
                                          style: AppCss.poppinsSemiBold10.textColor(
                                              appCtrl.appTheme.whiteColor).textHeight(1.3))
                                ),
                        ],
                      );
                    } else {
                      return Container();
                    }
                  })
          ]).marginOnly(top: Insets.i8);
    });
  }
}
