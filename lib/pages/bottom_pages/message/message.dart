import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_theme/config.dart';

class Message extends StatelessWidget {
  final messageCtrl = Get.put(MessageController());

  Message({Key? key}) : super(key: key);

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
                        .collection('users')
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                                appCtrl.appTheme.primary),
                          ),
                        );
                      } else {
                        return StreamBuilder(
                          stream: FirebaseFirestore.instance
                              .collection('users')
                              .snapshots(),
                          builder: (context,snapShot) {
                            return ListView.builder(
                              padding: const EdgeInsets.all(10.0),
                              itemBuilder: (context, index) => messageCtrl.loadUser(
                                  context, (snapshot.data!).docs[index]),
                              itemCount: (snapshot.data!).docs.length,
                            );

                          }
                        );
                      }
                    },
                  ),
                ),
              ),
            ]))),
      );
    });
  }
}
