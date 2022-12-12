import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_theme/config.dart';

class Message extends StatefulWidget {

  Message({Key? key}) : super(key: key);

  @override
  State<Message> createState() => _MessageState();
}

class _MessageState extends State<Message>   with
    WidgetsBindingObserver,TickerProviderStateMixin{
  final messageCtrl = Get.put(MessageController());


  @override
  void initState() {
    // TODO: implement initState
    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      setIsActive();
    } else {
      setLastSeen();
    }
  }

  void setIsActive() async {
    String userId = appCtrl.storage.read("id");
    await FirebaseFirestore.instance.collection("users").doc(userId).update(
      {"status": "Online","lastSeen": DateTime.now().millisecondsSinceEpoch.toString()},
    );
  }

  void setLastSeen() async {
    String userId = appCtrl.storage.read("id");
    await FirebaseFirestore.instance.collection("users").doc(userId).update(
      {"status": "Offline", "lastSeen": DateTime.now().millisecondsSinceEpoch.toString()},
    );
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<MessageController>(builder: (_) {
      return WillPopScope(
        onWillPop: messageCtrl.onWillPop,
        child: Scaffold(
            key: messageCtrl.scaffoldKey,
            floatingActionButton: FloatingActionButton(
              onPressed: () => messageCtrl.saveContactInChat(),
              backgroundColor: appCtrl.appTheme.primary,
              child: const Icon(Icons.message),
            ),
            body: SafeArea(
                child: Stack(fit: StackFit.expand, children: <Widget>[
               SingleChildScrollView(
                child: Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height - 50,
                    decoration: BoxDecoration(color: appCtrl.appTheme.accent),
                    child: StreamBuilder(
                        stream: FirebaseFirestore.instance
                            .collection('contacts')
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return Center(
                                child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  appCtrl.appTheme.primary),
                            ));
                          } else {
                            log("message : ${(snapshot.data!).docs.length}");
                            return (snapshot.data!).docs.isNotEmpty ? ListView.builder(
                              padding: const EdgeInsets.all(10.0),
                              itemBuilder: (context, index) {

                                return  messageCtrl.loadUser(context,
                                    (snapshot.data!).docs[index]);
                              },
                              itemCount: (snapshot.data!).docs.length,
                            ) : Container();
                          }
                        })),
              ),
            ]))),
      );
    });
  }
}
