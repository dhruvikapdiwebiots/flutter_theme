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
              return Stack(
                children: [
                  Image.asset(
                    imageAssets.user,
                    color: appCtrl.appTheme.whiteColor,
                  ).paddingAll(Insets.i15).decorated(
                      color: appCtrl.appTheme.grey.withOpacity(.4),
                      borderRadius: BorderRadius.circular(AppRadius.r8)),
                  Icon(Icons.circle,color: appCtrl.appTheme.txtColor,)
                ],
              );
            } else {
              return Stack(
                alignment: Alignment.bottomRight,
                children: [
                  CommonImage(image: (snapshot.data!).docs[0]["image"]),
                  Positioned(right: -3,child: Icon(Icons.circle,color: appCtrl.appTheme.txtColor,))
                ],
              ).height(Sizes.s55).width(Sizes.s55).backgroundColor(Colors.cyan);
            }
          } else {
            return Image.asset(
              imageAssets.user,
              color: appCtrl.appTheme.whiteColor,
            ).paddingAll(Insets.i15).decorated(
                color: appCtrl.appTheme.grey.withOpacity(.4),
                borderRadius: BorderRadius.circular(AppRadius.r8));
          }
        });
  }
}
