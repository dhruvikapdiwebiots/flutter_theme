import 'package:intl/intl.dart';

import '../../../../../config.dart';

class ReceiverContent extends StatelessWidget {
  final dynamic document;
  final GestureLongPressCallback? onLongPress;

  const ReceiverContent({Key? key,this.document,this.onLongPress}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
      const EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
      width: 220.0,
      decoration: BoxDecoration(
          color: appCtrl.appTheme.gray,
          borderRadius: const BorderRadius.only(
              topRight: Radius.circular(Insets.i20),
              bottomLeft: Radius.circular(Insets.i20),
              bottomRight: Radius.circular(Insets.i20))),
      margin: const EdgeInsets.only(left: 2.0),
      child:  Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(document!['content'],
              style: AppCss.poppinsMedium14
                  .textColor(appCtrl.appTheme.primary)),
          Text(
            DateFormat('HH:mm a').format(
                DateTime.fromMillisecondsSinceEpoch(
                    int.parse(document!['timestamp']))),
            style: AppCss.poppinsMedium12
                .textColor(appCtrl.appTheme.primary),
          )
        ],
      ),
    );
  }
}
