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
              const Color(0xffE6E6E6),
              radius: Sizes.s28,
              backgroundImage: NetworkImage(
                  '$image'),
            ),
        placeholder: (context, url) => Image.asset(
          imageAssets.user,
          color: appCtrl.appTheme.whiteColor,
        ).paddingAll(Insets.i15).decorated(
            color: appCtrl.appTheme.grey
                .withOpacity(.4),
            shape: BoxShape.circle),
        errorWidget: (context, url, error) =>
            Image.asset(
              imageAssets.user,
              color: appCtrl.appTheme.whiteColor,
            ).paddingAll(Insets.i15).decorated(
                color: appCtrl.appTheme.grey
                    .withOpacity(.4),
                shape: BoxShape.circle));
  }
}
