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
        child: Stack(
          alignment: isReceiver ? Alignment.topLeft : Alignment.topRight,
          children: [
            Container(

                decoration: BoxDecoration(
                    color: isReceiver
                        ? appCtrl.appTheme.white
                        : appCtrl.appTheme.primary,
                    borderRadius: BorderRadius.only(
                        bottomLeft: const Radius.circular(AppRadius.r8),
                        bottomRight: const Radius.circular(AppRadius.r8),
                        topLeft: isReceiver
                            ? const Radius.circular(0)
                            : const Radius.circular(AppRadius.r8),
                        topRight: isReceiver
                            ? const Radius.circular(AppRadius.r8)
                            : const Radius.circular(0))),
                width: Sizes.s250,
                height: Sizes.s120,
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          ContactListTile(document: document,isReceiver: isReceiver,).marginOnly(top: Insets.i5),
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
                      const VSpace(Sizes.s8),
                      Divider(
                        thickness: 1.5,
                          color: isReceiver
                              ? const Color(0xFF263238).withOpacity(.2)
                              : appCtrl.appTheme.whiteColor,
                          height: 1),

                      IntrinsicHeight(
                          child: Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                    child: InkWell(
                                      onTap: () {},
                                      child: Text("Message",
                                          textAlign: TextAlign.center,
                                          style: AppCss.poppinsExtraBold12
                                              .textColor(isReceiver
                                              ? const Color(0xFF586780)
                                              : appCtrl.appTheme.whiteColor))
                                          .marginSymmetric(vertical: Insets.i15),
                                    )),
                                VerticalDivider(
                                  endIndent: 10,
                                  indent: 10,
                                  thickness: 1.5,
                                  color: isReceiver
                                      ? const Color(0xFF263238).withOpacity(.2)
                                      : appCtrl.appTheme.whiteColor,
                                ),
                                Expanded(
                                    child: InkWell(
                                      onTap: () {},
                                      child: Text("Add Contact",
                                          textAlign: TextAlign.center,
                                          style: AppCss.poppinsExtraBold12.textColor(
                                              isReceiver
                                                  ? const Color(0xFF586780)
                                                  : appCtrl.appTheme.whiteColor)),
                                    ))
                              ]))
                    ])),
            CustomPaint(
                painter: CustomShape(isReceiver
                    ? appCtrl.appTheme.whiteColor
                    : appCtrl.appTheme.primary)),
          ],
        )
            .decorated(
            color: isReceiver
                ? appCtrl.appTheme.whiteColor
                : appCtrl.appTheme.primary,
            borderRadius: BorderRadius.only(
                bottomRight: const Radius.circular(Insets.i8),
                topRight: isReceiver
                    ? const Radius.circular(Insets.i8)
                    : const Radius.circular(0),
                topLeft: isReceiver
                    ? const Radius.circular(0)
                    : const Radius.circular(Insets.i8),
                bottomLeft: const Radius.circular(Insets.i8)))
            .marginSymmetric(horizontal: Insets.i10, vertical: Insets.i10)
           );
  }
}
