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
      leading: (data["image"] != null &&
          data["image"]!.length > 0)
          ? CircleAvatar(
          backgroundImage:
          NetworkImage(data["image"]!))
          : CircleAvatar(child: Text(data["name"][0])),
      title: Text(data["name"] ?? ""),
      subtitle: Text(data["phone"] ?? ""),
    );
  }
}
