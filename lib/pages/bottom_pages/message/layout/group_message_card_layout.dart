import 'package:intl/intl.dart';

import '../../../../config.dart';

class GroupMessageCardLayout extends StatelessWidget {
  final DocumentSnapshot? document;
  final String? currentUserId;
  final AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>>? userSnapShot,snapshot;
  const GroupMessageCardLayout({Key? key,this.document,this.currentUserId,this.userSnapShot,this.snapshot}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(children: [
            CommonImage(
                image:  (snapshot!.data!)["image"],
                name: (snapshot!.data!)["name"]),
            const HSpace(Sizes.s12),
            Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  Text(snapshot!.data!["name"],
                      style: AppCss.poppinsblack14
                          .textColor(
                          appCtrl.appTheme.blackColor)),
                  const VSpace(Sizes.s5),
                  document!["lastMessage"] != null
                      ? GroupCardSubTitle(
                      currentUserId: currentUserId,
                      name: userSnapShot!.data!["name"],
                      document: document,
                      hasData: userSnapShot!.hasData)
                      : Container(height: Sizes.s15)
                ])
          ]),
          Text(
              DateFormat('HH:mm a').format(
                  DateTime.fromMillisecondsSinceEpoch(
                      int.parse(
                          document!['updateStamp']))),
              style: AppCss.poppinsMedium12
                  .textColor(appCtrl.appTheme.txtColor))
              .paddingOnly(top: Insets.i8)
        ]).paddingSymmetric(vertical: Insets.i10);
  }
}
