import 'package:intl/intl.dart';

import '../../../../../config.dart';

class GroupSenderImage extends StatelessWidget {
  final DocumentSnapshot? document;
  final VoidCallback? onPressed, onLongPress;

  const GroupSenderImage(
      {Key? key, this.document, this.onPressed, this.onLongPress})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    /*return TextButton(
      onLongPress: onLongPress,
      onPressed: onPressed,
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          Material(
            borderRadius: BorderRadius.circular(AppRadius.r8),
            clipBehavior: Clip.hardEdge,
            child: CachedNetworkImage(
              placeholder: (context, url) => Container(
                  width: Sizes.s220,
                  height: Sizes.s200,
                  padding: const EdgeInsets.all(70.0),
                  decoration: BoxDecoration(
                    color: appCtrl.isTheme
                        ? appCtrl.appTheme.white
                        : appCtrl.appTheme.accent,
                    borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(Insets.i20),
                        topLeft: Radius.circular(Insets.i20),
                        bottomLeft: Radius.circular(Insets.i20)),
                  ),
                  child: Container()),
              imageUrl: document!['content'],
              width: Sizes.s200,
              height: Sizes.s200,
              fit: BoxFit.cover,
            ),
          ),
          Text(
            DateFormat('HH:mm a').format(DateTime.fromMillisecondsSinceEpoch(
                int.parse(document!['timestamp']))),
            style:
                AppCss.poppinsBold12.textColor(appCtrl.appTheme.whiteColor)
          ).marginSymmetric(horizontal: Insets.i10, vertical: Insets.i10).boxShadow( blurRadius: 15.0,
            color: appCtrl.appTheme.blackColor.withOpacity(.25),offset:const Offset(-2, 2))
        ],
      ),
    );*/
    return InkWell(
        onLongPress: onLongPress,
        onTap: onPressed,
        child: Stack(alignment: Alignment.bottomRight, children: [
          Material(
            borderRadius: BorderRadius.circular(AppRadius.r8),
            clipBehavior: Clip.hardEdge,
            child: CachedNetworkImage(
              placeholder: (context, url) => Container(
                  width: Sizes.s220,
                  height: Sizes.s200,
                  decoration: BoxDecoration(
                    color: appCtrl.appTheme.accent,
                    borderRadius: BorderRadius.circular(AppRadius.r8),
                  ),
                  child: Container()),
              imageUrl: document!['content'],
              width: Sizes.s200,
              height: Sizes.s200,
              fit: BoxFit.cover,
            ),
          ),
          Text(
              DateFormat('HH:mm a').format(DateTime.fromMillisecondsSinceEpoch(
                  int.parse(document!['timestamp']))),
              style:
              AppCss.poppinsBold12.textColor(appCtrl.appTheme.whiteColor)
          ).marginSymmetric(horizontal: Insets.i10, vertical: Insets.i10).boxShadow( blurRadius: 15.0,
              color: appCtrl.appTheme.blackColor.withOpacity(.25),offset:const Offset(-2, 2))
        ]).paddingAll(Insets.i5).decorated(color: appCtrl.appTheme.primary,borderRadius: BorderRadius.circular(AppRadius.r8)).marginSymmetric(vertical: Insets.i10,horizontal: Insets.i15)
    );
  }
}
