import 'dart:developer';

import 'package:flutter_theme/config.dart';

class AgoraToken extends StatelessWidget {
  final Widget? scaffold;

  const AgoraToken({Key? key, this.scaffold}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var user = appCtrl.storage.read(session.user);
    return user != null && user != ""
        ? StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection(collectionName.config)
                .doc(session.agoraToken)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasData && snapshot.data!.data()!.isNotEmpty) {
                appCtrl.storage
                    .write(session.agoraToken, snapshot.data!.data());
                log("token con : ${snapshot.data!.data()}");
              }
              return StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection(collectionName.users)
                      .doc(appCtrl.user["id"])
                      .collection(collectionName.registerUser)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      final contactCtrl =
                          Get.isRegistered<ContactListController>()
                              ? Get.find<ContactListController>()
                              : Get.put(ContactListController());
                      //contactCtrl.getAllData(snapshot);
                    }
                    return StreamBuilder(
                        stream: FirebaseFirestore.instance
                            .collection(collectionName.users)
                            .doc(appCtrl.user["id"])
                            .collection(collectionName.unRegisterUser)
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            final contactCtrl =
                                Get.isRegistered<ContactListController>()
                                    ? Get.find<ContactListController>()
                                    : Get.put(ContactListController());
                          //  contactCtrl.getAllUnRegisterUser(snapshot);
                          }
                          return scaffold!;
                        });
                  });
            },
          )
        : scaffold!;
  }
}
