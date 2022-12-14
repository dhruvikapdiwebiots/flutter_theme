import 'package:intl/intl.dart';

import '../../../../../config.dart';

class GroupReceiverContent extends StatelessWidget {
  final DocumentSnapshot? document;
  final GestureLongPressCallback? onLongPress;

  const GroupReceiverContent({Key? key, this.document, this.onLongPress})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection("users")
            .doc(document!['sender'])
            .snapshots(),
        builder: (context, snapshot) {
          return Container(

            padding: const EdgeInsets.fromLTRB(Insets.i15, 10.0, Insets.i15, 10.0),
            width: 220.0,
            decoration:  BoxDecoration(
                color:appCtrl.isTheme ?appCtrl.appTheme.white :  const Color(0xffF2F2F2),
                borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(Insets.i20),
                    bottomLeft: Radius.circular(Insets.i20),
                    bottomRight: Radius.circular(Insets.i20))),
            margin: const EdgeInsets.symmetric(vertical: Insets.i10,horizontal: Insets.i5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(document!['senderName'],
                          style: AppCss.poppinsMedium14
                              .textColor(appCtrl.appTheme.blackColor)),
                      if (snapshot.hasData)
                        Text(snapshot.data!.data()!["phone"],
                            style: AppCss.poppinsMedium12
                                .textColor(appCtrl.appTheme.accent)),
                    ]),
                const VSpace(Sizes.s10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Text(document!['content'],
                          style: AppCss.poppinsMedium14
                              .textColor(appCtrl.appTheme.blackColor)
                              .letterSpace(.2)
                              .textHeight(1.2)),
                    ),
                    Text(
                      DateFormat('HH:mm a').format(
                          DateTime.fromMillisecondsSinceEpoch(
                              int.parse(document!['timestamp']))),
                      style: AppCss.poppinsMedium12
                          .textColor(appCtrl.appTheme.primary),
                    )
                  ]
                )
              ],
            ),
          );
        });
  }
}
