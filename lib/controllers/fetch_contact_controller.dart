import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:typed_data';
import 'package:async/async.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter_theme/config.dart';
import 'package:localstorage/localstorage.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalUserData {
  final lastnotifyListenersd, userType;
  final Int8List? photoBytes;
  final String id, name, photoURL, aboutUser;
  final String idVariants;

  LocalUserData({
    required this.id,
    required this.idVariants,
    required this.userType,
    required this.aboutUser,
    required this.lastnotifyListenersd,
    required this.name,
    required this.photoURL,
    this.photoBytes,
  });

  factory LocalUserData.fromJson(Map<String, dynamic> jsonData) {
    return LocalUserData(
      id: jsonData['id'],
      aboutUser: jsonData['about'],
      idVariants: jsonData['idVars'],
      name: jsonData['name'],
      photoURL: jsonData['url'],
      photoBytes: jsonData['bytes'],
      userType: jsonData['type'],
      lastnotifyListenersd: jsonData['time'],
    );
  }

  Map<String, dynamic> toMapp(LocalUserData user) {
    return {
      'id': user.id,
      'about': user.aboutUser,
      'idVars': user.idVariants,
      'name': user.name,
      'url': user.photoURL,
      'bytes': user.photoBytes,
      'type': user.userType,
      'time': user.lastnotifyListenersd,
    };
  }

  static Map<String, dynamic> toMap(LocalUserData user) =>
      {
        'id': user.id,
        'about': user.aboutUser,
        'idVars': user.idVariants,
        'name': user.name,
        'url': user.photoURL,
        'bytes': user.photoBytes,
        'type': user.userType,
        'time': user.lastnotifyListenersd,
      };

  static String encode(List<LocalUserData> users) =>
      json.encode(
        users
            .map<Map<String, dynamic>>((user) => LocalUserData.toMap(user))
            .toList(),
      );

  static List<LocalUserData> decode(String users) =>
      (json.decode(users) as List<dynamic>)
          .map<LocalUserData>((item) => LocalUserData.fromJson(item))
          .toList();
}

class FetchContactController with ChangeNotifier {
  int daysTonotifyListenersCache = 7;
  var usersDocsRefinServer =
  FirebaseFirestore.instance.collection("users");
  List<LocalUserData> localUsersLIST = [];
  String localUsersSTRING = "";

  addORnotifyListenersLocalUserDataMANUALLY({required SharedPreferences prefs,
    required LocalUserData localUserData,
    required bool isNotifyListener}) {
    int ind =
    localUsersLIST.indexWhere((element) => element.id == localUserData.id);
    if (ind >= 0) {
      if (localUsersLIST[ind].name.toString() !=
          localUserData.name.toString() ||
          localUsersLIST[ind].photoURL.toString() !=
              localUserData.photoURL.toString()) {
        localUsersLIST.removeAt(ind);
        localUsersLIST.insert(ind, localUserData);
        localUsersLIST.sort(
                (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
        if (isNotifyListener == true) {
          notifyListeners();
        }
        saveFetchedLocalUsersInPrefs(prefs);
      }
    } else {
      localUsersLIST.add(localUserData);
      localUsersLIST
          .sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
      if (isNotifyListener == true) {
        notifyListeners();
      }
      saveFetchedLocalUsersInPrefs(prefs);
    }
  }

  Future<LocalUserData?> fetchUserDataFromnLocalOrServer(
      SharedPreferences prefs, String userid) async {
    log("userid : $userid");
    int ind = localUsersLIST.indexWhere((element) =>
    element.idVariants == userid);
    if (ind >= 0) {
      // print("LOADED ${localUsersLIST[ind].id} LOCALLY ");
      LocalUserData localUser = localUsersLIST[ind];

      if (DateTime
          .now()
          .difference(
          DateTime.fromMillisecondsSinceEpoch(localUser.lastnotifyListenersd))
          .inDays >
          daysTonotifyListenersCache) {
        QuerySnapshot<Map<String, dynamic>> doc =
        await usersDocsRefinServer.where("phone", isEqualTo: localUser.id)
            .get();
        if (doc.docs.isNotEmpty) {
          var notifyListenersdUserData = LocalUserData(
              aboutUser: doc.docs[0].data()["statusDesc"] ?? "",
              idVariants: doc.docs[0].data()["phone"] ?? [userid],
              id: doc.docs[0].data()["id"],
              userType: 0,
              lastnotifyListenersd: DateTime
                  .now()
                  .millisecondsSinceEpoch,
              name: doc.docs[0].data()["name"],
              photoURL: doc.docs[0].data()["image"] ?? "");
          // print("notifyListenersD ${localUser.id} LOCALLY AFTER EXPIRED");
          addORnotifyListenersLocalUserDataMANUALLY(
              prefs: prefs,
              isNotifyListener: false,
              localUserData: notifyListenersdUserData);
          return Future.value(notifyListenersdUserData);
        } else {
          return Future.value(localUser);
        }
      } else {
        return Future.value(localUser);
      }
    } else {
      QuerySnapshot<Map<String, dynamic>> doc =
      await usersDocsRefinServer.where("phone", isEqualTo: userid).get();
      if (doc.docs.isNotEmpty) {
        // print("LOADED ${doc.data()![Dbkeys.phone]} SERVER ");
        var notifyListenersdUserData = LocalUserData(
            aboutUser: doc.docs[0].data()["statusDesc"] ?? "",
            idVariants: doc.docs[0].data()["phone"] ?? [userid],
            id: doc.docs[0].data()["id"],
            userType: 0,
            lastnotifyListenersd: DateTime
                .now()
                .millisecondsSinceEpoch,
            name: doc.docs[0].data()["name"],
            photoURL: doc.docs[0].data()["image"] ?? "");

        addORnotifyListenersLocalUserDataMANUALLY(
            prefs: prefs,
            isNotifyListener: false,
            localUserData: notifyListenersdUserData);
        return Future.value(notifyListenersdUserData);
      } else {
        return Future.value(null);
      }
    }
  }

  fetchFromFiretsoreAndReturnData(SharedPreferences prefs, String userid,
      Function(DocumentSnapshot<Map<String, dynamic>> doc) onReturnData) async {
    var doc = await usersDocsRefinServer.doc(userid).get();
    if (doc.exists && doc.data() != null) {
      onReturnData(doc);
      addORnotifyListenersLocalUserDataMANUALLY(
          isNotifyListener: true,
          prefs: prefs,
          localUserData: LocalUserData(
              id: doc.data()!["id"],
              idVariants: doc.data()!["phone"],
              userType: 0,
              aboutUser: doc.data()!["statusDesc"],
              lastnotifyListenersd: DateTime
                  .now()
                  .millisecondsSinceEpoch,
              name: doc.data()!["name"],
              photoURL: doc.data()!["image"] ?? ""));
    }
  }

  Future<bool?> fetchLocalUsersFromPrefs(SharedPreferences prefs) async {
    localUsersSTRING = prefs.getString('localUsersSTRING') ?? "";
    // String? localUsersDEVICECONTACT =
    //     prefs.getString('localUsersDEVICECONTACT') ?? "";

    if (localUsersSTRING != "") {
      localUsersLIST = LocalUserData.decode(localUsersSTRING);

      localUsersLIST
          .sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
      for (var user in localUsersLIST) {
        log("USER:: ${user}");
        alreadyJoinedSavedUsersPhoneNameAsInServer = [];
        if (user.idVariants != appCtrl.user["phone"]) {
          alreadyJoinedSavedUsersPhoneNameAsInServer
              .add(DeviceContactIdAndName(phone: user.idVariants,
              name: user.name,
              id: user.id,
              image: user.photoURL,
              statusDesc: user.aboutUser));
        }
      }
      notifyListeners();

      return true;
    } else {
      return true;
    }

    // if (localUsersDEVICECONTACT != "") {
    //   alreadyJoinedSavedUsersPhoneNameAsInServer =
    //       DeviceContactIdAndName.decode(localUsersDEVICECONTACT);
    //   alreadyJoinedSavedUsersPhoneNameAsInServer.sort((a, b) =>
    //       (a.name ?? "").toLowerCase().compareTo((b.name ?? "").toLowerCase()));
    // }
  }

  saveFetchedLocalUsersInPrefs(SharedPreferences prefs) async {
    if (searchingcontactsindatabase == false) {
      localUsersSTRING = LocalUserData.encode(localUsersLIST);
      await prefs.setString('localUsersSTRING', localUsersSTRING);

      // print("SAVED ${localUsersLIST.length} LOCAL USERS - at end");
    }
  }

  //********---DEVICE CONTACT FETCH STARTS BELOW::::::::-----

  List<DeviceContactIdAndName> previouslyFetchedKEYPhoneInSharedPrefs = [];
  List<DeviceContactIdAndName> alreadyJoinedSavedUsersPhoneNameAsInServer = [];

//-------
  Map<String?, String?>? contactsBookContactList = new Map<String, String>();
  bool searchingcontactsindatabase = true;
  bool isLoading = true;

  List<dynamic> currentUserPhoneNumberVariants = [];

  fetchContacts(BuildContext context, String currentuserphone,
      SharedPreferences prefs, bool isForceFetch,
      {List<dynamic>? currentuserphoneNumberVariants}) async {
    if (currentuserphoneNumberVariants != null) {
      currentUserPhoneNumberVariants = currentuserphoneNumberVariants;
    }
    await getContacts(context, prefs).then((value) async {
      final List<DeviceContactIdAndName> decodedPhoneStrings =
      prefs.getString('availablePhoneString') == null ||
          prefs.getString('availablePhoneString') == ''
          ? []
          : DeviceContactIdAndName.decode(
          prefs.getString('availablePhoneString')!);
      final List<DeviceContactIdAndName> decodedPhoneAndNameStrings =
      prefs.getString('availablePhoneAndNameString') == null ||
          prefs.getString('availablePhoneAndNameString') == ''
          ? []
          : DeviceContactIdAndName.decode(
          prefs.getString('availablePhoneAndNameString')!);
      previouslyFetchedKEYPhoneInSharedPrefs = decodedPhoneStrings;
      alreadyJoinedSavedUsersPhoneNameAsInServer = decodedPhoneAndNameStrings;

      var a = alreadyJoinedSavedUsersPhoneNameAsInServer;
      var b = previouslyFetchedKEYPhoneInSharedPrefs;

      alreadyJoinedSavedUsersPhoneNameAsInServer = a;
      previouslyFetchedKEYPhoneInSharedPrefs = b;

      await fetchLocalUsersFromPrefs(prefs).then((b) async {
        if (b == true) {
          await searchAvailableContactsInDb(
              context, currentuserphone, prefs, isForceFetch);
        }
      });
    });
    notifyListeners();
  }

  setIsLoading(bool val) {
    searchingcontactsindatabase = val;
    notifyListeners();
  }

  Future<Map<String?, String?>> getContacts(BuildContext context,
      SharedPreferences prefs,
      {bool refresh = false}) async {
    Completer<Map<String?, String?>> completer =
    new Completer<Map<String?, String?>>();
    LocalStorage storage = LocalStorage("cachedContacts");

    Map<String?, String?> _cachedContacts = {};

    completer.future.then((c) {
      this.contactsBookContactList = c;
      if (this.contactsBookContactList!.isEmpty) {
        searchingcontactsindatabase = false;
        notifyListeners();
      }
    });

    checkAndRequestPermission(Permission.contacts).then((res) {
      if (res) {
        storage.ready.then((ready) async {
          if (ready) {
            String? getNormalizedNumber(String? number) {
              if (number == null) return null;
              return number.replaceAll(new RegExp('[^0-9+]'), '');
            }

            FlutterContacts.getContacts(
                withPhoto: true, withProperties: true, withThumbnail: true)
                .then((Iterable<Contact> contacts) async {
              for (Contact p in contacts.where((c) => c.phones.isNotEmpty)) {
                if (p.phones.isNotEmpty) {
                  List<String?> numbers = p.phones
                      .map((number) {
                    String? _phone = phoneNumberExtension(
                        number.normalizedNumber);

                    return _phone;
                  })
                      .toList()
                      .where((s) => s.isNotEmpty)
                      .toList();
                  for (var number in numbers) {
                    if (!(_cachedContacts[number] == p.displayName)) {
                      _cachedContacts[number] = p.displayName;
                    }
                  }
                }
              }

              completer.complete(_cachedContacts);
            });
            notifyListeners();
          }
          // }
        });
      } else {
        /*Navigator.pushReplacement(
            context,
            new MaterialPageRoute(
                builder: (context) => OpenSettings(
                      permtype: 'contact',
                      prefs: prefs,
                    )));*/
      }
      notifyListeners();
    }).catchError((onError) {
      //  Fiberchat.showRationale('Error occured: $onError');
    });
    //notifyListeners();
    return completer.future;
  }


  static Future<bool> checkAndRequestPermission(Permission permission) {
    Completer<bool> completer = new Completer<bool>();
    permission.request().then((status) {
      if (status != PermissionStatus.granted) {
        permission.request().then((_status) {
          bool granted = _status == PermissionStatus.granted;
          completer.complete(granted);
        });
      } else
        completer.complete(true);
    });
    return completer.future;
  }

  String getInitials(String name) {
    try {
      List<String> names = name
          .trim()
          .replaceAll(new RegExp(r'[\W]'), '')
          .toUpperCase()
          .split(' ');
      names.retainWhere((s) =>
      s
          .trim()
          .isNotEmpty);
      if (names.length >= 2)
        return names.elementAt(0)[0] + names.elementAt(1)[0];
      else if (names
          .elementAt(0)
          .length >= 2)
        return names.elementAt(0).substring(0, 2);
      else
        return names.elementAt(0)[0];
    } catch (e) {
      return '?';
    }
  }

  String? getNormalizedNumber(String number) {
    if (number.isEmpty) {
      return null;
    }

    return number.replaceAll(new RegExp('[^0-9+]'), '');
  }


  Future<List<QueryDocumentSnapshot>?> getUsersUsingChunks(chunks) async {
    QuerySnapshot result = await FirebaseFirestore.instance
        .collection("users")
        .where("phone", isEqualTo: chunks)
        .get();
    if (result.docs.isNotEmpty) {
      return result.docs;
    } else {
      return null;
    }
  }

  searchAvailableContactsInDb(BuildContext context,
      String currentuserphone,
      SharedPreferences existingPrefs,
      bool isForceFetch,) async {
    if (existingPrefs.getString('lastTimeCheckedContactBookSavedCopy') ==
        contactsBookContactList.toString() &&
        isForceFetch == false) {
      searchingcontactsindatabase = false;
      notifyListeners();
      if (previouslyFetchedKEYPhoneInSharedPrefs.length == 0 ||
          alreadyJoinedSavedUsersPhoneNameAsInServer.length == 0) {
        final List<DeviceContactIdAndName> decodedPhoneStrings =
        existingPrefs.getString('availablePhoneString') == null ||
            existingPrefs.getString('availablePhoneString') == ''
            ? []
            : DeviceContactIdAndName.decode(
            existingPrefs.getString('availablePhoneString')!);
        final List<DeviceContactIdAndName> decodedPhoneAndNameStrings =
        existingPrefs.getString('availablePhoneAndNameString') == null ||
            existingPrefs.getString('availablePhoneAndNameString') == ''
            ? []
            : DeviceContactIdAndName.decode(
            existingPrefs.getString('availablePhoneAndNameString')!);
        previouslyFetchedKEYPhoneInSharedPrefs = decodedPhoneStrings;
        alreadyJoinedSavedUsersPhoneNameAsInServer = decodedPhoneAndNameStrings;
      }

      notifyListeners();

      // print(
      //     '11. SKIPPED SEARCHING - AS ${contactsBookContactList!.entries.length} CONTACTS ALREADY CHECKED IN DATABASE, ${alreadyJoinedSavedUsersPhoneNameAsInServer.length} EXISTS');
    } else {
      // print(


      List<String> myArray = contactsBookContactList!.entries
          .toList()
          .map((e) => e.key.toString())
          .toList();

      var futureGroup = FutureGroup();

      for (var chunk in myArray) {
        futureGroup.add(
            getUsersUsingChunks(chunk.toString().replaceAll("+91", "")));
      }

      futureGroup.close();
      var p = await futureGroup.future;
      for (var batch in p) {
        if (batch != null) {
          for (QueryDocumentSnapshot<Map<String, dynamic>> registeredUser
          in batch) {

            if (alreadyJoinedSavedUsersPhoneNameAsInServer.indexWhere(
                    (element) =>
                element.phone == registeredUser.data()["phone"]) <
                0 &&
                registeredUser.data()["phone"] != currentuserphone) {
              alreadyJoinedSavedUsersPhoneNameAsInServer.add(
                  DeviceContactIdAndName(
                      phone: registeredUser.data()["phone"] ?? '',
                      name: registeredUser.data()["name"],
                      image: registeredUser.data()["image"],
                      statusDesc: registeredUser.data()["statusDesc"],
                      id: registeredUser.data()["id"]));
              // print('INSERTED $key IN LOCAL USER DATA LIST');
              addORnotifyListenersLocalUserDataMANUALLY(
                  prefs: existingPrefs,
                  localUserData: LocalUserData(
                      aboutUser:
                      registeredUser.data()["statusDesc"] ?? "",
                      id: registeredUser.data()["id"],
                      idVariants:
                      registeredUser.data()["phone"],

                      userType: 0,
                      lastnotifyListenersd: DateTime
                          .now()
                          .millisecondsSinceEpoch,
                      name: registeredUser.data()["name"],
                      photoURL:
                      registeredUser.data()["image"] ?? ""),
                  isNotifyListener: true);
            }
          }
        }
      }
      notifyListeners();
      int i = alreadyJoinedSavedUsersPhoneNameAsInServer
          .indexWhere((element) => element.phone == currentuserphone);
      if (i >= 0) {
        alreadyJoinedSavedUsersPhoneNameAsInServer.removeAt(i);
        previouslyFetchedKEYPhoneInSharedPrefs.removeAt(i);
      }
      notifyListeners();
      finishLoadingTasks(context, existingPrefs, currentuserphone,
          "24. SEARCHING STOPPED as users search completed in database.");
    }
  }

  finishLoadingTasks(BuildContext context, SharedPreferences existingPrefs,
      String currentuserphone, String printStatement,
      {bool isrealyfinish = true}) async {
    if (isrealyfinish == true) {
      searchingcontactsindatabase = false;
    }

    final String encodedavailablePhoneString =
    DeviceContactIdAndName.encode(previouslyFetchedKEYPhoneInSharedPrefs);

    await existingPrefs.setString(
        'availablePhoneString', encodedavailablePhoneString);

    final String encodedalreadyJoinedSavedUsersPhoneNameAsInServer =
    DeviceContactIdAndName.encode(
        alreadyJoinedSavedUsersPhoneNameAsInServer);
    await existingPrefs.setString('availablePhoneAndNameString',
        encodedalreadyJoinedSavedUsersPhoneNameAsInServer);

    if (isrealyfinish == true) {
      await existingPrefs.setString('lastTimeCheckedContactBookSavedCopy',
          contactsBookContactList.toString());
      notifyListeners();
    }
  }

  String getUserNameOrIdQuickly(String userid) {
    if (localUsersLIST.indexWhere((element) => element.id == userid) >= 0) {
      return localUsersLIST[
      localUsersLIST.indexWhere((element) => element.id == userid)]
          .name;
    } else {
      return 'User';
    }
  }
}

class DeviceContactIdAndName {
  final String? phone;
  final String? name;
  final String id;
  final String? image;
  final String? statusDesc;

  DeviceContactIdAndName({
    this.phone,
    this.name,
    required this.id, this.image, this.statusDesc
  });

  factory DeviceContactIdAndName.fromJson(Map<String, dynamic> jsonData) {
    return DeviceContactIdAndName(
      id: jsonData['id'],
      name: jsonData['name'],
      phone: jsonData['phone'],
      statusDesc: jsonData['statusDesc'],
      image: jsonData['image'],
    );
  }

  static Map<String, dynamic> toMap(DeviceContactIdAndName contact) =>
      {
        'id': contact.id,
        'name': contact.name,
        'phone': contact.phone,
        'image': contact.image,
        'statusDesc': contact.statusDesc,
      };

  static String encode(List<DeviceContactIdAndName> contacts) =>
      json.encode(
        contacts
            .map<Map<String, dynamic>>(
                (contact) => DeviceContactIdAndName.toMap(contact))
            .toList(),
      );

  static List<DeviceContactIdAndName> decode(String contacts) =>
      (json.decode(contacts) as List<dynamic>)
          .map<DeviceContactIdAndName>(
              (item) => DeviceContactIdAndName.fromJson(item))
          .toList();
}
