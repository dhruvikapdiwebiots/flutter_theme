import 'dart:developer';
import 'dart:io';

import 'package:wechat_assets_picker/wechat_assets_picker.dart';

import '../../../../config.dart';

class StatusFloatingButton extends StatelessWidget {
  const StatusFloatingButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<StatusController>(
      builder: (statusCtrl) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 43,
              margin: const EdgeInsets.only(bottom: 18),
              child: FloatingActionButton(
                  backgroundColor: const Color(0xffebecee),
                  child: Icon(Icons.edit,
                      size: 23.0, color: Colors.blueGrey[700]),
                  onPressed: () => Get.to(const TextStatus())!.then((value) {
                    log("value : $value");
                  })),
            ),
            FloatingActionButton(
                onPressed: () async {
                  final List<AssetEntity>? result =
                  await AssetPicker.pickAssets(
                    context,
                    pickerConfig: AssetPickerConfig(
                      maxAssets: 1,
                      specialPickerType: SpecialPickerType.wechatMoment,
                    ),
                  );
                  File? videoFile = await result![0].file;
                  statusCtrl.addStatus(
                      videoFile!,
                      result[0].title!.contains("mp4")
                          ? StatusType.video
                          : StatusType.image);
                },
                backgroundColor: appCtrl.appTheme.primary,
                child: Icon(Icons.add, color: appCtrl.appTheme.whiteColor))
          ],
        );
      }
    );
  }
}
