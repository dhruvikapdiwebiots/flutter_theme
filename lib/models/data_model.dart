
import 'dart:developer';
import 'dart:io';

import 'package:async/async.dart' show StreamGroup;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_theme/common/config.dart';
import 'package:flutter_theme/config.dart';
import 'package:localstorage/localstorage.dart';
import 'package:scoped_model/scoped_model.dart';

class ContactModel extends Model {
  List<QueryDocumentSnapshot<Map<String, dynamic>>> userData =
 [];

  Map<String, Future> messageStatus = <String, Future>{};

  _getMessageKey(String? peerNo, int? timestamp) => '$peerNo$timestamp';

  getMessageStatus(String? peerNo, int? timestamp) {
    final key = _getMessageKey(peerNo, timestamp);
    return messageStatus[key] ?? true;
  }

  bool loaded = false;

  LocalStorage storage = LocalStorage('model');

  addMessage(String? peerNo, int? timestamp, Future future) {
    final key = _getMessageKey(peerNo, timestamp);
    future.then((_) {
      messageStatus.remove(key);
    });
    messageStatus[key] = future;
  }

  updateItem(String key, Map<String, dynamic> value) {
    Map<String, dynamic> old = storage.getItem(key) ?? <String, dynamic>{};
    old.addAll(value);
    storage.setItem(key, old);
  }


  bool get loader => loaded;

  Map<String, dynamic>? get currentUser => _currentUser;

  Map<String, dynamic>? _currentUser;

  Map<String?, int?> get lastRecentMessage => lastRecentMessageData;

  Map<String?, int?> lastRecentMessageData = {};

  ContactModel(String? currentUserNo) {
    FirebaseFirestore.instance
        .collection(collectionName.users)
        .doc(appCtrl.user["id"])
        .snapshots()
        .listen((user) {
          log("ISERR");
      _currentUser = user.data();
      notifyListeners();
    });

    storage.ready.then((ready) {
      if (ready) {
        debugPrint("STORAGE sss:: $ready");
        FirebaseFirestore.instance
            .collection(collectionName.users)
            .doc(appCtrl.user["id"])
            .collection(collectionName.chats) .orderBy("updateStamp", descending: true)
            .snapshots()
            .listen((chat) {
          debugPrint("_chatsWithexists : ${chat.docs.length}");
          if (chat.docs.isNotEmpty) {
            List<QueryDocumentSnapshot<Map<String, dynamic>>> users = [];
            List<QueryDocumentSnapshot<Map<String, dynamic>>> peers = [];

            chat.docs.asMap().entries.forEach((element) {
              debugPrint("_chatsWith : ${element.value.data()}");
              if(!peers.contains(element.value)) {
                peers.add(element.value);
              }
            });

            users = peers;
            notifyListeners();
            List<QueryDocumentSnapshot<Map<String, dynamic>>> newData =
            [];
            users.asMap().entries.forEach((element) {
              newData.add(element.value);
            });

            userData= newData;
            notifyListeners();
            log("LOG :: $newData");
          }
          if (!loaded) {
            loaded = true;
            notifyListeners();
          }
        });
      }
    });
  }
}