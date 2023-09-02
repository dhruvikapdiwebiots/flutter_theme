import '../../../config.dart';

class CallerImage extends StatelessWidget {
  final String? imageUrl;
  const CallerImage({Key? key,this.imageUrl}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: Sizes.s100,
      width: Sizes.s100,
      child: CachedNetworkImage(
          imageUrl: imageUrl!,
          imageBuilder: (context, imageProvider) =>
              CircleAvatar(
                backgroundColor:
                appCtrl.appTheme.contactBgGray,
                radius: Sizes.s60,
                backgroundImage: NetworkImage(imageUrl!),
              ),
          placeholder: (context, url) => Image.asset(
            imageAssets.user,
            height: Sizes.s50,
            width: Sizes.s50,
            color: appCtrl.appTheme.whiteColor,
          ).paddingAll(Insets.i12).decorated(
              color: appCtrl.appTheme.grey
                  .withOpacity(.4),
              shape: BoxShape.circle),
          errorWidget: (context, url, error) =>
              Image.asset(
                height: Sizes.s50,
                width: Sizes.s50,
                imageAssets.user,
                color: appCtrl.appTheme.whiteColor,
              ).paddingAll(Insets.i15).decorated(
                  color: appCtrl.appTheme.grey
                      .withOpacity(.4),
                  shape: BoxShape.circle)),
    );
  }
}
