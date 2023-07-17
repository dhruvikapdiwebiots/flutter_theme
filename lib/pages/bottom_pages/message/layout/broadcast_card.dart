import 'package:intl/intl.dart';

import '../../../../config.dart';

class BroadCastMessageCard extends StatelessWidget {
  final DocumentSnapshot? document;
  final String? currentUserId;

  const BroadCastMessageCard({Key? key, this.document, this.currentUserId})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    List selectedContact = document!["receiverId"];
    return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
          Row(children: [
            Container(
                height: Sizes.s45,
                width: Sizes.s45,
                decoration: ShapeDecoration(
                    color: appCtrl.appTheme.grey.withOpacity(.4),
                    shape: SmoothRectangleBorder(
                      borderRadius: SmoothBorderRadius(
                          cornerRadius: 12, cornerSmoothing: 1),
                    )),
                child: Icon(Icons.volume_down,
                    color: appCtrl.appTheme.blackColor)),
            const HSpace(Sizes.s12),
            SizedBox(
              width: Sizes.s150,
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text("${selectedContact.length} recipient",
                    style: AppCss.poppinsblack14
                        .textColor(appCtrl.appTheme.blackColor)),
                const VSpace(Sizes.s5),
                Text(decryptMessage(document!["lastMessage"]),
                    overflow: TextOverflow.ellipsis,
                    style: AppCss.poppinsMedium14
                        .textColor(appCtrl.appTheme.txtColor))
              ]),
            )
          ]),
          Text(
                  DateFormat('HH:mm a').format(
                      DateTime.fromMillisecondsSinceEpoch(
                          int.parse(document!['updateStamp']))),
                  style: AppCss.poppinsMedium12
                      .textColor(appCtrl.appTheme.txtColor))
              .paddingOnly(top: Insets.i8)
        ])
        .paddingSymmetric(vertical: Insets.i10)
        .paddingSymmetric(horizontal: Insets.i15, vertical: Insets.i5)
        .commonDecoration()
        .marginSymmetric(horizontal: Insets.i10)
        .inkWell(onTap: () {
      var data = {
        "broadcastId": document!["broadcastId"],
        "data": document!.data(),
      };
      Get.toNamed(routeName.broadcastChat, arguments: data);
    });
  }
}
