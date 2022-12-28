


import '../../../../../../config.dart';
import 'common_file_row_list.dart';

class FileBottomSheet extends StatelessWidget {
  const FileBottomSheet({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 278,
      width: MediaQuery.of(Get.context!).size.width,
      child: Card(
        color: appCtrl.appTheme.whiteColor,
        margin: const EdgeInsets.all(Insets.i18),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.r15)),
        child:const Padding(
          padding:  EdgeInsets.symmetric(horizontal: Insets.i10, vertical: Insets.i20),
          child: CommonFileRowList (),
        ),
      ),
    );
  }
}
