import 'package:intl/intl.dart';

import '../../../../config.dart';

class TrailingLayout extends StatelessWidget {
  final DocumentSnapshot? document;
  final String? currentUserId;
  const TrailingLayout({Key? key,this.document,this.currentUserId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<MessageController>(
      builder: (msgCtrl) {
        return Column(
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
            ]);
      }
    );
  }
}
