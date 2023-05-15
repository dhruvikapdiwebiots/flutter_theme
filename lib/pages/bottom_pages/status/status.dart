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
    firebaseCtrl.statusDeleteAfter24Hours();
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
            backgroundColor: appCtrl.appTheme.bgColor,
            floatingActionButton: const StatusFloatingButton(),
            body: SafeArea(
                child: Stack(
              children: [
                StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection(collectionName.users).doc(statusCtrl.currentUserId).snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return CommonEmptyLayout(gif: gifAssets.status,title: fonts.emptyStatusTitle.tr,desc: fonts.emptyStatusDesc);
                    } else {
                      return SingleChildScrollView(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              //current user status
                              CurrentUserStatus(
                                  currentUserId: statusCtrl.user != null
                                      ? statusCtrl.user["phone"]
                                      : "")
                                  .marginSymmetric(vertical: Insets.i10),
                              const VSpace(Sizes.s5),
                              Row(
                                children: [
                                  Text(fonts.recentUpdates.tr,
                                      style: AppCss.poppinsblack16
                                          .textColor(
                                          appCtrl.appTheme.txtColor)),
                                  const HSpace(Sizes.s12),
                                  Expanded(child: Divider(
                                    color: appCtrl.appTheme.primary.withOpacity(
                                        .2), thickness: 1,))
                                ],
                              ).paddingSymmetric(horizontal: Insets.i12),
                              const VSpace(Sizes.s10),
                              //all contacts user status list
                              const StatusListLayout(),
                            ]).paddingSymmetric(horizontal: Insets.i10),
                      );
                    }
                  }
                ),
                if (statusCtrl.isLoading)
                  CommonLoader(isLoading: statusCtrl.isLoading)
              ],
            ))),
      );
    });
  }
}

