import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_theme/config.dart';

class Chat extends StatelessWidget {
  final chatCtrl = Get.put(ChatController());

  Chat({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ChatController>(builder: (_) {
      return WillPopScope(
        onWillPop: chatCtrl.onBackPress,
        child: Scaffold(
          appBar: AppBar(
              title: Text(
                chatCtrl.pName!,
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: appCtrl.appTheme.accent,
                    fontWeight: FontWeight.bold,
                    fontSize: 16),
              ),
              centerTitle: true),
          backgroundColor: Colors.white,
          body: Stack(
            children: [
              Container(
                  decoration: BoxDecoration(
                      image: DecorationImage(
                          image: AssetImage(imageAssets.chatBg),
                          fit: BoxFit.cover))),
              Stack(
                children: <Widget>[
                  Column(
                    children: <Widget>[
                      // List of messages
                      buildmessageBox(),
                      // Sticker
                      Container(),
                      // Input content
                      buildInputBox(),
                    ],
                  ),

                  // Loading
                  buildLoader()
                ],
              ),
            ],
          ),
        ),
      );
    });
  }

// LOADER IS LOADER TILL MESSAGES NOT LOAD
  Widget buildLoader() {
    return GetBuilder<ChatController>(
      builder: (_) {
        return Positioned(
          child: chatCtrl.isLoading!
              ? Container(
                  color: Colors.white.withOpacity(0.8),
                  child: Center(
                    child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                            appCtrl.appTheme.primary)),
                  ),
                )
              : Container(),
        );
      }
    );
  }

// BOTTOM ENTER MESSAGEBOX UI
  Widget buildInputBox() {
    return GetBuilder<ChatController>(
      builder: (_) {
        return Container(
          width: double.infinity,
          height: 50.0,
          decoration: BoxDecoration(
              border: Border(
                  top: BorderSide(color: appCtrl.appTheme.darkGray, width: 0.5)),
              color: Colors.white),
          child: Row(
            children: <Widget>[
              Material(
                color: Colors.white,
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 1.0),
                  child: IconButton(
                    icon: const Icon(Icons.image),
                    onPressed: chatCtrl.getImage,
                    color: appCtrl.appTheme.primary,
                  ),
                ),
              ),
              Flexible(
                child: TextField(
                  style: TextStyle(color: appCtrl.appTheme.primary, fontSize: 15.0),
                  controller: chatCtrl.textEditingController,
                  decoration: InputDecoration.collapsed(
                    hintText: 'Enter your message',
                    hintStyle: TextStyle(color: appCtrl.appTheme.gray),
                  ),
                  focusNode: chatCtrl.focusNode,
                ),
              ),
              Material(
                color: Colors.white,
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: () => chatCtrl.onSendMessage(
                        chatCtrl.textEditingController.text, 0),
                    color: appCtrl.appTheme.primary,
                  ),
                ),
              ),
            ],
          ),
        );
      }
    );
  }

// BUILD MESSAGEBOX
  Widget buildmessageBox() {
    return GetBuilder<ChatController>(
      builder: (_) {
        return Flexible(
          child: chatCtrl.groupId == ''
              ? Center(
                  child: CircularProgressIndicator(
                      valueColor:
                          AlwaysStoppedAnimation<Color>(appCtrl.appTheme.primary)))
              : StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection('messages')
                      .doc(chatCtrl.groupId)
                      .collection(chatCtrl.groupId!)
                      .orderBy('timestamp', descending: true)
                      .limit(20)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return Center(
                          child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  appCtrl.appTheme.primary)));
                    } else {
                      chatCtrl.  message = (snapshot.data!).docs;
                      return ListView.builder(
                        padding: const EdgeInsets.all(10.0),
                        itemBuilder: (context, index) =>
                            chatCtrl.buildItem(index, (snapshot.data!).docs[index]),
                        itemCount: (snapshot.data!).docs.length,
                        reverse: true,
                        controller: chatCtrl.listScrollController,
                      );
                    }
                  },
                ),
        );
      }
    );
  }
}
