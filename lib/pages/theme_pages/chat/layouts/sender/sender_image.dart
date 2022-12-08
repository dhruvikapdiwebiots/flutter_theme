import '../../../../../config.dart';

class SenderImage extends StatelessWidget {
  final String? url;
  const SenderImage({Key? key,this.url}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(0),
      child: TextButton(
        child: Material(
          borderRadius: const BorderRadius.only(
              topRight: Radius.circular(Insets.i20),
              topLeft: Radius.circular(Insets.i20),
              bottomLeft: Radius.circular(Insets.i20)),
          clipBehavior: Clip.hardEdge,
          child: CachedNetworkImage(
            placeholder: (context, url) => Container(
              width: 220.0,
              height: 200.0,
              padding: const EdgeInsets.all(70.0),
              decoration: BoxDecoration(
                color: appCtrl.appTheme.accent,
                borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(Insets.i20),
                    topLeft: Radius.circular(Insets.i20),
                    bottomLeft: Radius.circular(Insets.i20)),
              ),
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                    appCtrl.appTheme.accent),
              ),
            ),
            imageUrl: url!,
            width: 200.0,
            height: 200.0,
            fit: BoxFit.cover,
          ),
        ),
        onLongPress: () {},
        onPressed: () {},
      ),
    );
  }
}
