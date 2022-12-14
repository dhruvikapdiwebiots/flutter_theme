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
            : StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('messages')
                    .orderBy('timestamp', descending: true)
                    .limit(20)
                    .snapshots(),
                builder: (context, snapshot) {
                  print("sna : ${snapshot.hasData}");
                  if (!snapshot.hasData) {
                    return Center(
                        child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                                appCtrl.appTheme.primary)));
                  } else {
                    chatCtrl.message = (snapshot.data!).docs;
                    print("object : ${(snapshot.data!).docs.length}");
                    return ListView.builder(
                      padding: const EdgeInsets.all(10.0),
                      itemBuilder: (context, index) => chatCtrl.buildItem(
                          index, (snapshot.data!).docs[index]),
                      itemCount: (snapshot.data!).docs.length,
                      reverse: true,
                      controller: chatCtrl.listScrollController,
                    );
                  }
                },
              ),
      );
    });
  }
}