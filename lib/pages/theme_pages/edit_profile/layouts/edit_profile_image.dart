import '../../../../config.dart';

class EditProfileImage extends StatelessWidget {
  const EditProfileImage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<EditProfileController>(
      builder: (editCtrl) {
        return CachedNetworkImage(
            imageUrl: editCtrl.user["image"],
            imageBuilder:
                (context, imageProvider) =>
                CircleAvatar(
                  backgroundColor: appCtrl
                      .appTheme.contactBgGray,
                  radius: 60,
                  backgroundImage: NetworkImage(
                      '${editCtrl.user["image"]}'),
                ),
            placeholder: (context, url) =>
                Container(
                  height: Sizes.s120,
                  width: Sizes.s120,
                  alignment: Alignment.center,
                  padding: const EdgeInsets.all(
                      Insets.i15),
                  decoration: BoxDecoration(
                      color: appCtrl.appTheme.gray
                          .withOpacity(.3),
                      image: DecorationImage(
                          image: AssetImage(
                              imageAssets.user)),
                      shape: BoxShape.circle),
                ),
            errorWidget: (context, url, error) =>
                Container(
                  height: Sizes.s120,
                  width: Sizes.s120,
                  alignment: Alignment.center,
                  padding: const EdgeInsets.all(
                      Insets.i15),
                  decoration: BoxDecoration(
                      color: appCtrl.appTheme.gray
                          .withOpacity(.3),
                      image: DecorationImage(
                          image: AssetImage(
                              imageAssets.user)),
                      shape: BoxShape.circle),
                ));
      }
    );
  }
}
