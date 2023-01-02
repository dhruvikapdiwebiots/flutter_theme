import '../../../../config.dart';

class UserImage extends StatelessWidget {
  final String? image;
  const UserImage({Key? key,this.image}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return  Hero(
      tag: "user",
      child:
          image != ""
          ? Container(
        height: Sizes.s60,
        width: Sizes.s60,
        alignment: Alignment.center,
        padding: const EdgeInsets.all(Insets.i15),
        decoration: BoxDecoration(
            color: appCtrl.appTheme.gray.withOpacity(.2),
            image: DecorationImage(
                image:
                NetworkImage(image!),
                fit: BoxFit.fill),
            shape: BoxShape.circle),
      )
          : Container(
        height: Sizes.s60,
        width: Sizes.s60,
        alignment: Alignment.center,
        padding: const EdgeInsets.all(Insets.i15),
        decoration: BoxDecoration(
            color: appCtrl.appTheme.gray.withOpacity(.2),
            image: DecorationImage(
              image: AssetImage(imageAssets.user),
            ),
            shape: BoxShape.circle),
      ),
    );
  }
}
