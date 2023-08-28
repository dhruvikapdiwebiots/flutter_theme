import 'dart:developer';

import 'package:intl/intl.dart';

import '../../../../config.dart';

class BroadCastMessageCard extends StatelessWidget {
  final DocumentSnapshot? document;
  final String? currentUserId;

  const BroadCastMessageCard({Key? key, this.document, this.currentUserId})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    String nameList ="";
    List selectedContact = document!["receiverId"];
    selectedContact.asMap().forEach((key, value) {
      if (nameList != "") {
        nameList = "$nameList, ${value["name"]}";
      } else {
        nameList = value["name"];
      }
    });

    return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
          Row(children: [
            Container(
                height: Sizes.s45,
                width: Sizes.s45,
                padding:const EdgeInsets.symmetric(horizontal: Insets.i8),
                decoration: ShapeDecoration(
                    color:const Color(0xFFF5F5F6),
                    shape: SmoothRectangleBorder(
                      borderRadius: SmoothBorderRadius(
                          cornerRadius: 12, cornerSmoothing: 1),
                    )),
                child: SvgPicture.asset(svgAssets.volume,height: Sizes.s16,width: Sizes.s20,)),
            const HSpace(Sizes.s12),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Text(nameList,
                      overflow: TextOverflow.ellipsis,
                      style: AppCss.poppinsblack14
                          .textColor(appCtrl.appTheme.blackColor)),
                  Text(
                      DateFormat('HH:mm a').format(
                          DateTime.fromMillisecondsSinceEpoch(
                              int.parse(document!['updateStamp']))),
                      style: AppCss.poppinsMedium12
                          .textColor(appCtrl.appTheme.txtColor))
                ],
              ).width(MediaQuery.of(context).size.width/1.5),
              const VSpace(Sizes.s5),
              Text( document!["lastMessage"] != ""? decryptMessage(document!["lastMessage"]) : "",
                  overflow: TextOverflow.ellipsis,
                  style: AppCss.poppinsMedium14
                      .textColor(appCtrl.appTheme.txtColor))
            ])
          ]),


        ])
        .paddingSymmetric(vertical: Insets.i10)
        .paddingSymmetric(horizontal: Insets.i15, vertical: Insets.i5)
        .commonDecoration()
        .marginSymmetric(horizontal: Insets.i10)
        .inkWell(onTap: () {
      log("ALLL : ${document!.data()}");
      var data = {

        "broadcastId": document!["broadcastId"],
        "data": document!.data(),
      };
      Get.toNamed(routeName.broadcastChat, arguments: data);
      final chatCtrl = Get.isRegistered<BroadcastChatController>()
          ? Get.find<BroadcastChatController>()
          : Get.put(BroadcastChatController());
     log("CHAT :: ${chatCtrl.pId}");

    });
  }
}
