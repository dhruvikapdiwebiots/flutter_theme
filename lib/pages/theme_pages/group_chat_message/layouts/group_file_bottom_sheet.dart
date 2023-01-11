


import '../../../../../../config.dart';
import 'group_file_row_list.dart';

class GroupBottomSheet extends StatelessWidget {
  const GroupBottomSheet({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 278,
      width: MediaQuery.of(Get.context!).size.width,
      child: Card(
        color: appCtrl.appTheme.whiteColor,
        margin: const EdgeInsets.all(18.0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child:const Padding(
          padding:  EdgeInsets.symmetric(horizontal: 10, vertical: 20),
          child: GroupFileRowList (),
        ),
      ),
    );
  }
}
