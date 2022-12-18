import '../../../../config.dart';

class MessageBox extends StatelessWidget {
  const MessageBox({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ChatController>(builder: (chatCtrl) {
      return Flexible(
        child: chatCtrl.groupId == ''
            ? Center(
                child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                        appCtrl.appTheme.primary)))
            : chatCtrl.chatId != null? StreamBuilder(
              stream: chatCtrl.getMessage(),
              builder: (context, snapshot) {
                print("sna : ${snapshot.data}");
                if (!snapshot.hasData) {
                  return Center(
                      child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                              appCtrl.appTheme.primary)));
                } else {
                  chatCtrl.message = (snapshot.data!);
                  print("object : ${(snapshot.data!).length}");
                  return ListView.builder(
                    padding: const EdgeInsets.all(10.0),
                    itemBuilder: (context, index) => chatCtrl.buildItem(
                        index, (snapshot.data!)[index]),
                    itemCount: (snapshot.data!).length,
                    reverse: true,
                    controller: chatCtrl.listScrollController,
                  );
                }
              },
            ): Container(),
      );
    });
  }
}
