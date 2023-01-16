import 'dart:developer';

import 'package:intl/intl.dart';

import '../../../../config.dart';

class ContactLayout extends StatelessWidget {
  final dynamic document;
  final VoidCallback? onLongPress;

  final bool isReceiver;

  const ContactLayout(
      {Key? key, this.document, this.onLongPress, this.isReceiver = false})
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
                    ? appCtrl.appTheme.white
                    : appCtrl.appTheme.primary,
                borderRadius: BorderRadius.circular(AppRadius.r15),
                boxShadow: [
                  BoxShadow(
                      blurRadius: 15.0,
                      color: appCtrl.appTheme.blackColor.withOpacity(.25),
                      offset: const Offset(-2, 2))
                ]),
            width: Sizes.s280,
            height: Sizes.s140,
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                          child: ContactListTile(
                        document: document,
                      )),
                      Text(
                        DateFormat('HH:mm a').format(
                            DateTime.fromMillisecondsSinceEpoch(
                                int.parse(document!['timestamp']))),
                        style: AppCss.poppinsMedium12.textColor(isReceiver
                            ? appCtrl.appTheme.primary
                            : appCtrl.appTheme.whiteColor),
                      ).marginSymmetric(horizontal: Insets.i10)
                    ],
                  ),
                  Divider(height: 7, color: appCtrl.appTheme.whiteColor),
                  // ignore: deprecated_member_use
                  TextButton(
                      onPressed: ()async {

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
                          style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: appCtrl.appTheme.whiteColor)))
                ])));
  }
}
