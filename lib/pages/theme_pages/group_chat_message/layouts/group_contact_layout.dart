import 'package:intl/intl.dart';

import '../../../../config.dart';

class GroupContactLayout extends StatelessWidget {
  final DocumentSnapshot? document;
  final VoidCallback? onLongPress;
  final String? currentUserId;
  final bool isReceiver;

  const GroupContactLayout(
      {Key? key,
      this.document,
      this.onLongPress,
      this.currentUserId,
      this.isReceiver = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
        onLongPress: onLongPress,
        child: Container(
                padding: const EdgeInsets.symmetric(vertical: Insets.i10),
                margin: const EdgeInsets.symmetric(vertical: Insets.i10),
                decoration: BoxDecoration(
                  color: isReceiver
                      ?  appCtrl.appTheme.lightGray
                      : appCtrl.appTheme.primary,
                  borderRadius: BorderRadius.circular(AppRadius.r15),

                ),
                width: Sizes.s280,
                height: Sizes.s140,
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      if (document!["sender"] != currentUserId)
                        Text(document!['senderName'],
                                style: AppCss.poppinsMedium14
                                    .textColor(appCtrl.appTheme.primary))
                            .alignment(Alignment.bottomLeft)
                            .paddingSymmetric(horizontal: Insets.i25),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                              child: ContactListTile(
                            document: document,
                                isReceiver: true,
                          )),
                          Text(
                                  DateFormat('HH:mm a').format(
                                      DateTime.fromMillisecondsSinceEpoch(
                                          int.parse(document!['timestamp']))),
                                  style: AppCss.poppinsMedium12
                                      .textColor(appCtrl.appTheme.primary))
                              .marginSymmetric(horizontal: Insets.i15)
                        ],
                      ),
                      Divider(
                              height: 5,
                              color: appCtrl.appTheme.primary.withOpacity(.2))
                          .paddingOnly(bottom: Insets.i8),
                      // ignore: deprecated_member_use
                      InkWell(
                          onTap: () async{
                            final uri = Uri(
                              scheme: "sms",
                              path: document!['content'].split('-BREAK-')[1],
                              queryParameters: <String, String>{
                                'body': Uri.encodeComponent('Download the ChatBox App'),
                              },
                            );
                            await launchUrl(uri);
                          },
                          child: Text("Message",
                              style: AppCss.poppinsSemiBold12
                                  .textColor(appCtrl.appTheme.primary)))
                    ]))
           );
  }
}
