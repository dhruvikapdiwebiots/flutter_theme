import '../../../../../config.dart';

class ReceiverImage extends StatelessWidget {
  final String? image;
  const ReceiverImage({Key? key,this.image}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(0),
      margin: const EdgeInsets.only(left: Insets.i10),
      child: TextButton(
          onPressed: () {},
          child: Material(
              borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(Insets.i20),
                  bottomLeft: Radius.circular(Insets.i20),
                  bottomRight: Radius.circular(Insets.i20)),
              child: CachedNetworkImage(
                placeholder: (context, url) => Container(
                  width: 200.0,
                  height: 200.0,
                  padding: const EdgeInsets.all(Insets.i70),
                  decoration: BoxDecoration(
                    color: appCtrl.appTheme.primary,
                    borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(AppRadius.r20),
                        bottomLeft: Radius.circular(AppRadius.r20),
                        bottomRight: Radius.circular(AppRadius.r20)),
                  ),
                  child: CircularProgressIndicator(
                    valueColor:
                        AlwaysStoppedAnimation<Color>(appCtrl.appTheme.primary),
                  ),
                ),
                errorWidget: (context, url, error) => Material(
                  borderRadius: const BorderRadius.all(
                    Radius.circular(8.0),
                  ),
                  clipBehavior: Clip.hardEdge,
                  child: Image.asset(
                    'images/img_not_available.jpeg',
                    width: Sizes.s200,
                    height: Sizes.s200,
                    fit: BoxFit.cover,
                  ),
                ),
                imageUrl: image!,
                width: 200.0,
                height: 200.0,
                fit: BoxFit.cover,
              ))),
    );
  }
}
