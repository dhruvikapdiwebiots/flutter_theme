import 'package:flutter_theme/config.dart';

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
  //  firebaseCtrl.statusDeleteAfter24Hours();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<StatusController>(builder: (_) {
      return NotificationListener<OverscrollIndicatorNotification>(
        onNotification: (OverscrollIndicatorNotification overscroll) {
          overscroll.disallowIndicator();
          return false;
        },
        child: Scaffold(
            backgroundColor: appCtrl.appTheme.whiteColor,
            floatingActionButton: const StatusFloatingButton(),
            body: SafeArea(
                child: SingleChildScrollView(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    //current user status
                    CurrentUserStatus(
                            statusCtrl: statusCtrl,
                            currentUserId: statusCtrl.user != null
                                ? statusCtrl.user["phone"]
                                : "")
                        .marginSymmetric(vertical: Insets.i10),
                    const Divider(),
                    const VSpace(Sizes.s15),
                    Text(fonts.recentUpdates.tr,
                        style: AppCss.poppinsblack14
                            .textColor(appCtrl.appTheme.txt)),
                    const VSpace(Sizes.s10),
                    //all contacts user status list
                    const StatusListLayout(),
                  ]).paddingAll(Insets.i10),
            ))),
      );
    });
  }
}
