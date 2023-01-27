import '../../../../config.dart';

class ImageLayout extends StatelessWidget {
  final String? id;

  const ImageLayout({Key? key, this.id}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection(collectionName.users)
            .where("id", isEqualTo: id)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.data != null) {
            if (!snapshot.data!.docs.isNotEmpty) {
              return Image.asset(
                imageAssets.user,
                color: appCtrl.appTheme.whiteColor,
              ).paddingAll(Insets.i15).decorated(
                  color: appCtrl.appTheme.grey.withOpacity(.4),
                  shape: BoxShape.circle);
            } else {
              return CommonImage(image: (snapshot.data!).docs[0]["image"]);
            }
          } else {
            return Image.asset(
              imageAssets.user,
              color: appCtrl.appTheme.whiteColor,
            ).paddingAll(Insets.i15).decorated(
                color: appCtrl.appTheme.grey.withOpacity(.4),
                shape: BoxShape.circle);
          }
        });
  }
}
