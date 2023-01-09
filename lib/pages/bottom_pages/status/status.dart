import 'dart:developer';
import 'dart:io';

import 'package:flutter_theme/config.dart';
import 'package:flutter_theme/pages/bottom_pages/status/layouts/text_status.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';

class StatusList extends StatefulWidget {
  const StatusList({Key? key}) : super(key: key);

  @override
  State<StatusList> createState() => _StatusListState();
}

class _StatusListState extends State<StatusList>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  final statusCtrl = Get.put(StatusController());

  @override
  void initState() {
    // TODO: implement initState
    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      firebaseCtrl.setIsActive();
    } else {
      firebaseCtrl.setLastSeen();
    }
    firebaseCtrl.statusDeleteAfter24Hours();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<StatusController>(builder: (_) {
      return Scaffold(
          backgroundColor: appCtrl.appTheme.whiteColor,
          floatingActionButton: Column(
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
                    statusCtrl.addStatus(videoFile!,result[0].title!.contains("mp4")? StatusType.video :StatusType.image);

                  },
                  backgroundColor: appCtrl.appTheme.primary,
                  child: Icon(Icons.add, color: appCtrl.appTheme.whiteColor))
            ],
          ),
          body: SafeArea(
              child: SingleChildScrollView(
            child: Column(children: <Widget>[
              CurrentUserStatus(
                currentUserId:
                    statusCtrl.user != null ? statusCtrl.user["phone"] : "",
              ).marginSymmetric(vertical: Insets.i10),
              const Divider(),
              const StatusListLayout(),
            ]).paddingAll(Insets.i10),
          )));
    });
  }
}
