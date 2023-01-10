import 'dart:io';

import 'package:wechat_assets_picker/wechat_assets_picker.dart';

import '../../../../config.dart';

class CurrentUserStatus extends StatelessWidget {
  final String? currentUserId;
final StatusController? statusCtrl;
  const CurrentUserStatus({Key? key, this.currentUserId,this.statusCtrl}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('status')
            .where("phoneNumber", isEqualTo: currentUserId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.data != null) {
            if (!snapshot.data!.docs.isNotEmpty) {
              return CurrentUserEmptyStatus(onTap: () async {
                final List<AssetEntity>? result =
                await AssetPicker.pickAssets(
                  context,
                  pickerConfig: AssetPickerConfig(
                    maxAssets: 1,
                    specialPickerType: SpecialPickerType.wechatMoment,
                  ),
                );
                File? videoFile = await result![0].file;
                statusCtrl!.addStatus(videoFile!,result[0].title!.contains("mp4")? StatusType.video :StatusType.image);
              });
            } else {
              return StatusLayout(snapshot: snapshot);
            }
          } else {
            return CurrentUserEmptyStatus(onTap: () async {
              final List<AssetEntity>? result =
              await AssetPicker.pickAssets(
                context,
                pickerConfig: AssetPickerConfig(
                  maxAssets: 1,
                  specialPickerType: SpecialPickerType.wechatMoment,
                ),
              );
              File? videoFile = await result![0].file;
              statusCtrl!.addStatus(videoFile!,result[0].title!.contains("mp4")? StatusType.video :StatusType.image);
            });
          }
        });
  }
}
