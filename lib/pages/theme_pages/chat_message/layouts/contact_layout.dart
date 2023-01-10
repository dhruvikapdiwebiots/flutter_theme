
import 'package:intl/intl.dart';

import '../../../../config.dart';

class ContactLayout extends StatelessWidget {
  final dynamic document;
  final VoidCallback? onLongPress;

  const ContactLayout({Key? key, this.document, this.onLongPress})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
        onLongPress: onLongPress,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: Insets.i8),
            decoration: BoxDecoration(
              color: appCtrl.appTheme.primary.withOpacity(.8),
              borderRadius: BorderRadius.circular(AppRadius.r8),
            ),
            width: Sizes.s280,

            child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(child: ContactListTile(document: document,)),
                      Text(DateFormat('HH:mm a').format(
                          DateTime.fromMillisecondsSinceEpoch(
                              int.parse(document!['timestamp']))),style: AppCss.poppinsMedium12.textColor(appCtrl.appTheme.whiteColor),).marginSymmetric(horizontal: Insets.i10)
                    ],
                  ),
                  Divider(
                      height: 7,
                      color: appCtrl.appTheme.whiteColor),
                  // ignore: deprecated_member_use
                  TextButton(
                      onPressed: () {},
                      child: Text("Message",
                          style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: appCtrl.appTheme.whiteColor)))
                ])));
  }
}
