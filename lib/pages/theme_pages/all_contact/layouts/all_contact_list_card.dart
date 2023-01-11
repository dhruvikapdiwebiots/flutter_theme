import '../../../../config.dart';

class AllContactListCard extends StatelessWidget {
  final Contact? item;
  final int? index;
  const AllContactListCard({Key? key,this.item,this.index}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return  ListTile(
      onTap: () {
        Get.back(result: item);
      },
      leading: item!.photo != null
          ? CircleAvatar(
          backgroundImage:
          MemoryImage(item!.photo!))
          : CircleAvatar(
          child: Text(
              item!.displayName.isNotEmpty?    item!.displayName
                  .length >
                  2
                  ? item!.displayName
                  .replaceAll(" ", "")
                  .substring(0, 2)
                  .toUpperCase()
                  : item!.displayName[index!]
              [0]: "",
              style: AppCss.poppinsMedium12
                  .textColor(appCtrl
                  .appTheme
                  .whiteColor))),
      title: Text(item!.displayName ),

    );
  }
}
