import '../../../../config.dart';

class AllRegisteredContact extends StatelessWidget {
  final GestureTapCallback? onTap;
  final bool? isExist;
  final dynamic data;
  const AllRegisteredContact({Key? key,this.onTap,this.data,this.isExist}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      trailing: Container(
          decoration: BoxDecoration(
            border: Border.all(
                color: appCtrl.appTheme.borderGray,
                width: 1),
            borderRadius: BorderRadius.circular(5),
          ),
          child: Icon(
            isExist!
                ? Icons.check
                : null,
            size: 19.0,
          )),
      leading: CachedNetworkImage(
          imageUrl:   data["image"],
          imageBuilder: (context, imageProvider) => CircleAvatar(
            backgroundColor: const Color(0xffE6E6E6),
            radius: 32,
            backgroundImage:
            NetworkImage(data["image"]),
          ),
          placeholder: (context, url) => const CircularProgressIndicator(strokeWidth: 2,).width(Sizes.s20).height(Sizes.s20).paddingAll(Insets.i15).decorated(
              color: appCtrl.appTheme.grey.withOpacity(.4),
              shape: BoxShape.circle),
          errorWidget: (context, url, error) => Image.asset(
            imageAssets.user,
            color: appCtrl.appTheme.whiteColor,
          ).paddingAll(Insets.i15).decorated(
              color: appCtrl.appTheme.grey.withOpacity(.4),
              shape: BoxShape.circle)),
      title: Text(data["name"] ?? ""),
      subtitle: Text(data["phone"] ?? ""),
    );
  }
}
