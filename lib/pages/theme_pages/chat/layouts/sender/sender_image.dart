import '../../../../../config.dart';

class SenderImage extends StatelessWidget {
  final String? url;
  final VoidCallback? onPressed, onLongPress;

  const SenderImage({Key? key, this.url, this.onPressed, this.onLongPress})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(0),
      child: TextButton(
        onLongPress: onLongPress,
        onPressed: onPressed,
        child: Material(
          borderRadius: const BorderRadius.only(
              topRight: Radius.circular(Insets.i20),
              topLeft: Radius.circular(Insets.i20),
              bottomLeft: Radius.circular(Insets.i20)),
          clipBehavior: Clip.hardEdge,
          child: CachedNetworkImage(
            placeholder: (context, url) => Container(
                width: Sizes.s220,
                height: Sizes.s200,
                padding: const EdgeInsets.all(70.0),
                decoration: BoxDecoration(
                  color: appCtrl.appTheme.accent,
                  borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(Insets.i20),
                      topLeft: Radius.circular(Insets.i20),
                      bottomLeft: Radius.circular(Insets.i20)),
                ),
                child: CircularProgressIndicator(
                  valueColor:
                      AlwaysStoppedAnimation<Color>(appCtrl.appTheme.accent),
                )),
            imageUrl: url!,
            width: Sizes.s200,
            height: Sizes.s200,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}
