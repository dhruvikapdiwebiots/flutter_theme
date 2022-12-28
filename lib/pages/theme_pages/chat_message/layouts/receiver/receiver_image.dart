import 'package:intl/intl.dart';

import '../../../../../config.dart';

class ReceiverImage extends StatelessWidget {
  final dynamic document;
  final GestureLongPressCallback? onLongPress;
  const ReceiverImage({Key? key,this.document,this.onLongPress}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(      decoration: BoxDecoration( borderRadius: BorderRadius.circular(AppRadius.r10), color: appCtrl.appTheme.primary,),
      margin: const EdgeInsets.symmetric(horizontal: Insets.i10,vertical: Insets.i5),

      child: TextButton(
          onPressed: onLongPress,
          child: Stack(
            alignment: Alignment.bottomRight,
            children: [
              Material(
                borderRadius:  BorderRadius.circular(AppRadius.r8),
                clipBehavior: Clip.hardEdge,
                child: CachedNetworkImage(
                  placeholder: (context, url) => Container(
                      width: Sizes.s220,
                      height: Sizes.s200,
                     
                      decoration: BoxDecoration(
                        color: appCtrl.appTheme.accent,
                        borderRadius:  BorderRadius.circular(AppRadius.r8),
                      ),
                      child: CircularProgressIndicator(
                        valueColor:
                        AlwaysStoppedAnimation<Color>(appCtrl.appTheme.accent),
                      )),
                  imageUrl: document!['content'],
                  width: Sizes.s200,
                  height: Sizes.s200,
                  fit: BoxFit.cover,
                ),
              ),
              Text(DateFormat('HH:mm a').format(
                  DateTime.fromMillisecondsSinceEpoch(
                      int.parse(document!['timestamp']))),style: AppCss.poppinsBold12.textColor(appCtrl.appTheme.whiteColor),).marginSymmetric(horizontal: Insets.i10,vertical: Insets.i10)
            ],
          )),
    );
  }
}
