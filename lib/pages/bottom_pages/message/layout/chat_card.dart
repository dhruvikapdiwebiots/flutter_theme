import 'dart:developer';

import 'package:flutter_theme/controllers/recent_chat_controller.dart';
import 'package:provider/provider.dart';
import 'package:scoped_model/scoped_model.dart';

import '../../../../config.dart';
import '../../../../models/data_model.dart';

class ChatCard extends StatefulWidget {
  const ChatCard({Key? key}) : super(key: key);

  @override
  State<ChatCard> createState() => _ChatCardState();
}

class _ChatCardState extends State<ChatCard> {
  final messageCtrl = Get.find<MessageController>();
  final scrollController = ScrollController();
  int inviteContactsCount = 30;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    scrollController.addListener(scrollListener);

  }

  String? sharedSecret;
  String? privateKey;

  void scrollListener() {
    if (scrollController.offset >=
            scrollController.position.maxScrollExtent / 2 &&
        !scrollController.position.outOfRange) {
      setStateIfMounted(() {
        inviteContactsCount = inviteContactsCount + 250;
      });
    }
  }

  void setStateIfMounted(f) {
    if (mounted) setState(f);
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<MessageController>(builder: (messageCtrl) {
      return GetBuilder<DashboardController>(builder: (dashboardCtrl) {

        return Consumer<RecentChatController>(
            builder: (context, recentChat, _child) {

              return ScopedModel<DataModel>(
                model: recentChat.getModel(appCtrl.user)!,
                child: ScopedModelDescendant<DataModel>(builder: (context, child, _model) {
                  appCtrl.cachedModel = _model;
                    return recentChat.userData.isNotEmpty
                        ? ListView(controller: scrollController, children: [
                      Column(
                        children: [

                          ...recentChat.messageWidgetList.asMap().entries.map((e) => e.value).toList()
                        ],
                      ).marginSymmetric(vertical: Insets.i20, horizontal: Insets.i10)
                    ])
                        : CommonEmptyLayout(
                        gif: gifAssets.message,
                        title: fonts.emptyMessageTitle.tr,
                        desc: fonts.emptyMessageDesc.tr);
                  }
                ),
              );
            }
        );
      });
    });
  }
}
