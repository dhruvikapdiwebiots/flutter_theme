import 'dart:io';


import 'package:flutter_theme/config.dart';
import 'package:flutter_theme/pages/bottom_pages/status/layouts/current_user_status.dart';
import 'package:flutter_theme/pages/bottom_pages/status/layouts/status_list.dart';


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
      appCtrl.firebaseCtrl.setIsActive();
    } else {
      appCtrl.firebaseCtrl.setLastSeen();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<StatusController>(builder: (_) {
      return Scaffold(
          backgroundColor: appCtrl.appTheme.accent,
          floatingActionButton: FloatingActionButton(
            onPressed: () async {
              File? pickedImage = await pickImageFromGallery(context);
              if (pickedImage != null) {
                Get.toNamed(routeName.confirmationScreen,
                    arguments: pickedImage);
              }
            },
            backgroundColor: appCtrl.appTheme.primary,
            child: const Icon(Icons.add),
          ),
          body: SafeArea(
              child: SingleChildScrollView(
            child: Column(children: <Widget>[
             CurrentUserStatus(currentUserId: statusCtrl.currentUserId,)
                  .decorated(color: appCtrl.appTheme.accent)
                  .marginSymmetric(vertical: Insets.i10),
              const Divider().decorated(color: appCtrl.appTheme.accent),
             const StatusListLayout(),
            ]),
          )));
    });
  }
}


