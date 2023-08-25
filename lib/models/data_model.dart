
import 'dart:developer';
import 'dart:io';

import 'package:async/async.dart' show StreamGroup;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_theme/common/config.dart';
import 'package:flutter_theme/config.dart';
import 'package:localstorage/localstorage.dart';
import 'package:scoped_model/scoped_model.dart';

class DataModel extends Model {
  List<QueryDocumentSnapshot<Map<String, dynamic>>> userData =
 [];

  Map<String, Future> _messageStatus = new Map<String, Future>();

  _getMessageKey(String? peerNo, int? timestamp) => '$peerNo$timestamp';

  getMessageStatus(String? peerNo, int? timestamp) {
    final key = _getMessageKey(peerNo, timestamp);
    return _messageStatus[key] ?? true;
  }

  bool _loaded = false;

  LocalStorage _storage = LocalStorage('model');

  addMessage(String? peerNo, int? timestamp, Future future) {
    final key = _getMessageKey(peerNo, timestamp);
    future.then((_) {
      _messageStatus.remove(key);
    });
    _messageStatus[key] = future;
  }

  updateItem(String key, Map<String, dynamic> value) {
    Map<String, dynamic> old = _storage.getItem(key) ?? Map<String, dynamic>();
    old.addAll(value);
    log("STORAGE :: ${_storage}");
    _storage.setItem(key, old);
  }


  bool get loaded => _loaded;

  Map<String, dynamic>? get currentUser => _currentUser;

  Map<String, dynamic>? _currentUser;

  Map<String?, int?> get lastSpokenAt => _lastSpokenAt;

  Map<String?, int?> _lastSpokenAt = {};

  getChatOrder(List<String> chatsWith, String? currentUserNo) {
    List<Stream<QuerySnapshot>> messages = [];
    chatsWith.forEach((otherNo) {
      String chatId = otherNo;
      messages.add(FirebaseFirestore.instance
          .collection(collectionName.users)
          .doc(appCtrl.user["id"])
          .collection(collectionName.chat).where("chatId",isEqualTo: chatId)
          .snapshots());
    });

    StreamGroup.merge(messages).listen((snapshot) {
      if (snapshot.docs.isNotEmpty) {
        DocumentSnapshot message = snapshot.docs.last;
        _lastSpokenAt[message["senderId"] == currentUserNo
            ? message["receiverId"]
            : message["senderId"]] = message["timestamp"];

        notifyListeners();
        log("_lastSpokenAt :: $_lastSpokenAt");
      }
    });

  }

  DataModel(String? currentUserNo) {
    FirebaseFirestore.instance
        .collection(collectionName.users)
        .doc(appCtrl.user["id"])
        .snapshots()
        .listen((user) {
          log("ISERR");
      _currentUser = user.data();
      notifyListeners();
    });

    _storage.ready.then((ready) {
      if (ready) {
        debugPrint("STORAGE sss:: $ready");
        FirebaseFirestore.instance
            .collection(collectionName.users)
            .doc(appCtrl.user["id"])
            .collection(collectionName.chats) .orderBy("updateStamp", descending: true)
            .snapshots()
            .listen((_chatsWith) {
          debugPrint("_chatsWithexists : ${_chatsWith.docs.length}");
          if (_chatsWith.docs.isNotEmpty) {
            List<QueryDocumentSnapshot<Map<String, dynamic>>> users = [];
            List<QueryDocumentSnapshot<Map<String, dynamic>>> peers = [];

            _chatsWith.docs.asMap().entries.forEach((element) {
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
          if (!_loaded) {
            _loaded = true;
            notifyListeners();
          }
        });
      }
    });
  }
}