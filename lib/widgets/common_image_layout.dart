import 'package:flutter_theme/config.dart';

class CommonImage extends StatelessWidget {
  final String? image;
  const CommonImage({Key? key,this.image}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
        imageUrl: image!,
        imageBuilder: (context, imageProvider) =>
            CircleAvatar(
              backgroundColor:
              appCtrl.appTheme.contactBgGray,
              radius: Sizes.s24,
              backgroundImage: NetworkImage(
                  '$image'),
            ),
        placeholder: (context, url) => Image.asset(
          imageAssets.user,
          color: appCtrl.appTheme.blackColor,
        ).paddingAll(Insets.i15).decorated(
            color: appCtrl.appTheme.grey
                .withOpacity(.4),
            shape: BoxShape.circle),
        errorWidget: (context, url, error) =>
            Image.asset(
              imageAssets.user,
              height: Sizes.s28,
              color: appCtrl.appTheme.whiteColor,
            ).paddingAll(Insets.i10).decorated(
                color: appCtrl.appTheme.grey
                    .withOpacity(.4),
                shape: BoxShape.circle));
  }
}
