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

class UserData {
  final int time, userType;
  final Int8List? photoBytes;
  final String id, name, photoURL, aboutUser;
  final String idVariants;
  final List<dynamic>? dialCodePhoneList;

  UserData({
    required this.id,
    required this.idVariants,
    required this.userType,
    required this.aboutUser,
    required this.time,
    required this.name,
    required this.photoURL,
    this.photoBytes,
    this.dialCodePhoneList,
  });

  factory UserData.fromJson(Map<String, dynamic> jsonData) {
    return UserData(
      id: jsonData['id'],
      aboutUser: jsonData['about'],
      idVariants: jsonData['idVars'],
      name: jsonData['name'],
      photoURL: jsonData['url'],
      photoBytes: jsonData['bytes'],
      userType: jsonData['type'],
      time: jsonData['time'],
      dialCodePhoneList: jsonData['dialCodePhoneList'],
    );
  }

  static Map<String, dynamic> toMap(UserData user) => {
    'id': user.id,
    'about': user.aboutUser,
    'idVars': user.idVariants,
    'name': user.name,
    'url': user.photoURL,
    'bytes': user.photoBytes,
    'type': user.userType,
    'time': user.time,
    'dialCodePhoneList': user.dialCodePhoneList,
  };

  static String encode(List<UserData> users) => json.encode(
    users
        .map<Map<String, dynamic>>((user) => UserData.toMap(user))
        .toList(),
  );

  static List<UserData> decode(String users) =>
      (json.decode(users) as List<dynamic>)
          .map<UserData>((item) => UserData.fromJson(item))
          .toList();
}

class FetchContactController with ChangeNotifier {
  int cacheDays = 2;
  var userRef = FirebaseFirestore.instance.collection("users");
  List<UserData> storageUserList = [];
  String storageUserString = "";

  addData(
      {required SharedPreferences prefs,
        required UserData localUserData,
        required bool isListener}) {
    int ind =
    storageUserList.indexWhere((element) => element.id == localUserData.id);
    if (ind >= 0) {
      if (storageUserList[ind].name.toString() !=
          localUserData.name.toString() ||
          storageUserList[ind].photoURL.toString() !=
              localUserData.photoURL.toString()) {
        storageUserList.removeAt(ind);
        storageUserList.insert(ind, localUserData);
        storageUserList.sort(
                (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
        if (isListener == true) {
          notifyListeners();
        }
        getAndSaveUserInLocalStorage(prefs);
      }
    } else {
      storageUserList.add(localUserData);
      storageUserList
          .sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
      if (isListener == true) {
        notifyListeners();
      }
      getAndSaveUserInLocalStorage(prefs);
    }
  }

  Future<UserData?> getUserDataFromStorageAndFirebase(
      SharedPreferences prefs, String userid) async {
    int ind =
    storageUserList.indexWhere((element) => element.idVariants == userid);
    if (ind >= 0) {
      // print("LOADED ${storageUserList[ind].id} LOCALLY ");
      UserData localUser = storageUserList[ind];

      if (DateTime.now()
          .difference(DateTime.fromMillisecondsSinceEpoch(
          localUser.time))
          .inDays >
          cacheDays) {
        QuerySnapshot<Map<String, dynamic>> doc = await userRef
            .where("phone", isEqualTo: localUser.id)
            .get();
        if (doc.docs.isNotEmpty) {
          if (doc.docs[0].data()["isActive"] == true) {
            var userDataModel = UserData(
                aboutUser: doc.docs[0].data()["statusDesc"] ?? "",
                idVariants: doc.docs[0].data()["phone"] ?? [userid],
                id: doc.docs[0].data()["id"],
                userType: 0,
                time: DateTime.now().millisecondsSinceEpoch,
                name: doc.docs[0].data()["name"],
                photoURL: doc.docs[0].data()["image"] ?? "");
            // print("notifyListenersD ${localUser.id} LOCALLY AFTER EXPIRED");
            addData(
                prefs: prefs,
                isListener: false,
                localUserData: userDataModel);
            return Future.value(userDataModel);
          }else {
            return Future.value(localUser);
          }
        } else {
          return Future.value(localUser);
        }
      } else {
        return Future.value(localUser);
      }
    } else {
      QuerySnapshot<Map<String, dynamic>> doc =
      await userRef.where("phone", isEqualTo: userid).get();
      if (doc.docs.isNotEmpty) {
        // print("LOADED ${doc.data()![Dbkeys.phone]} SERVER ");
        if(doc.docs[0].data()["isActive"] == true){
          var userDataModel = UserData(
              aboutUser: doc.docs[0].data()["statusDesc"] ?? "",
              idVariants: doc.docs[0].data()["phone"] ,
              id: doc.docs[0].data()["id"],
              dialCodePhoneList: doc.docs[0].data()["dialCodePhoneList"] ?? [userid],
              userType: 0,
              time: DateTime.now().millisecondsSinceEpoch,
              name: doc.docs[0].data()["name"],
              photoURL: doc.docs[0].data()["image"] ?? "");

          addData(
              prefs: prefs,
              isListener: false,
              localUserData: userDataModel);
          return Future.value(userDataModel);
        } else {
          return Future.value(null);
        }
      } else {
        return Future.value(null);
      }
    }
  }

  getDataFromFirebase(SharedPreferences prefs, String userid,
      Function(DocumentSnapshot<Map<String, dynamic>> doc) onReturnData) async {
    var doc = await userRef.doc(userid).get();
    if (doc.exists && doc.data() != null  && doc.data()!["isActive"] == true) {
      onReturnData(doc);
      addData(
          isListener: true,
          prefs: prefs,
          localUserData: UserData(
              id: doc.data()!["id"],
              idVariants: doc.data()!["phone"],
              userType: 0,
              dialCodePhoneList: doc.data()!["dialCodePhoneList"] ?? [userid],
              aboutUser: doc.data()!["statusDesc"],
              time: DateTime.now().millisecondsSinceEpoch,
              name: doc.data()!["name"],
              photoURL: doc.data()!["image"] ?? ""));
    }
  }

  Future<bool?> getDataFromLocal(SharedPreferences prefs) async {
    storageUserString = prefs.getString('storageUserString') ?? "";
    // String? localUsersDEVICECONTACT =
    //     prefs.getString('localUsersDEVICECONTACT') ?? "";

    if (storageUserString != "") {
      storageUserList = UserData.decode(storageUserString);

      storageUserList
          .sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
      for (var user in storageUserList) {
        registerContactUser = [];
        if (user.idVariants != appCtrl.user["phone"]) {
          registerContactUser.add(RegisterContactDetail(
              phone: user.idVariants,
              dialCode: appCtrl.user["dialCode"] ?? "",
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
  }

  getAndSaveUserInLocalStorage(SharedPreferences prefs) async {
    if (searchContact == false) {
      storageUserString = UserData.encode(storageUserList);
      await prefs.setString('storageUserString', storageUserString);
    }
  }

  List<RegisterContactDetail> oldPhoneData = [];
  List<RegisterContactDetail> registerContactUser = [];

  Map<String?, String?>? contactList =  <String, String>{};
  bool searchContact = true;
  bool isLoading = true;

  List<dynamic> currentUser = [];

  fetchContacts(BuildContext context, String phone,
      SharedPreferences prefs, bool isForceFetch,
      {List<dynamic>? currentUserVariants}) async {
    if (currentUserVariants != null) {
      currentUser = currentUserVariants;
    }
    await getContacts(context, prefs).then((value) async {
      final List<RegisterContactDetail> decodedPhoneStrings =
      prefs.getString('registerUserPhoneString') == null ||
          prefs.getString('registerUserPhoneString') == ''
          ? []
          : RegisterContactDetail.decode(
          prefs.getString('registerUserPhoneString')!);
      final List<RegisterContactDetail> decodedPhoneAndNameStrings =
      prefs.getString('registerUserPhoneAndNameString') == null ||
          prefs.getString('registerUserPhoneAndNameString') == ''
          ? []
          : RegisterContactDetail.decode(
          prefs.getString('registerUserPhoneAndNameString')!);
      oldPhoneData = decodedPhoneStrings;
      registerContactUser = decodedPhoneAndNameStrings;

      var a = registerContactUser;
      var b = oldPhoneData;

      registerContactUser = a;
      oldPhoneData = b;

      await getDataFromLocal(prefs).then((b) async {
        if (b == true) {
          await searchRegisterUserFromFirebase(
              context, phone, prefs, isForceFetch);
        }
      });
    });
    notifyListeners();
  }

  setIsLoading(bool val) {
    searchContact = val;
    notifyListeners();
  }

  Future<Map<String?, String?>> getContacts(
      BuildContext context, SharedPreferences prefs,
      {bool refresh = false}) async {
    Completer<Map<String?, String?>> completer =
    Completer<Map<String?, String?>>();
    LocalStorage storage = LocalStorage("cachedContacts");

    Map<String?, String?> cachedContacts = {};

    completer.future.then((c) {
      contactList = c;
      if (contactList!.isEmpty) {
        searchContact = false;
        notifyListeners();
      }
    });

    checkAndRequestPermission(Permission.contacts).then((res) {
      if (res) {
        storage.ready.then((ready) async {
          if (ready) {

            FlutterContacts.getContacts(
                withPhoto: true, withProperties: true, withThumbnail: true)
                .then((Iterable<Contact> contacts) async {
              for (Contact p in contacts.where((c) => c.phones.isNotEmpty)) {
                appCtrl.contactList.add(p);

                if (p.phones.isNotEmpty) {
                  List<String?> numbers = p.phones
                      .map((number) {
                    String? phoneNumber =
                    phoneNumberExtension(number.normalizedNumber);

                    return phoneNumber;
                  })
                      .toList()
                      .where((s) => s.isNotEmpty)
                      .toList();
                  for (var number in numbers) {
                    if (!(cachedContacts[number] == p.displayName)) {
                      cachedContacts[number] = p.displayName;
                    }
                  }
                }
              }
              appCtrl.update();
              completer.complete(cachedContacts);
            });
            notifyListeners();
          }
          // }
        });
      }
      notifyListeners();
    }).catchError((onError) {
      //  Fiberchat.showRationale('Error occured: $onError');
    });

    return completer.future;
  }

  static Future<bool> checkAndRequestPermission(Permission permission) {
    Completer<bool> completer =  Completer<bool>();
    permission.request().then((status) {
      if (status != PermissionStatus.granted) {
        permission.request().then((status) {
          bool granted = status == PermissionStatus.granted;
          completer.complete(granted);
        });
      } else {
        completer.complete(true);
      }
    });
    return completer.future;
  }

  String getInitials(String name) {
    try {
      List<String> names = name
          .trim()
          .replaceAll( RegExp(r'\W'), '')
          .toUpperCase()
          .split(' ');
      names.retainWhere((s) => s.trim().isNotEmpty);
      if (names.length >= 2) {
        return names.elementAt(0)[0] + names.elementAt(1)[0];
      } else if (names.elementAt(0).length >= 2) {
        return names.elementAt(0).substring(0, 2);
      } else {
        return names.elementAt(0)[0];
      }
    } catch (e) {
      return '?';
    }
  }

  String? getNormalizedNumber(String number) {
    if (number.isEmpty) {
      return null;
    }

    return number.replaceAll( RegExp('[^0-9+]'), '');
  }

  Future<List<QueryDocumentSnapshot>?> getUsersUsingChunks(chunks) async {

    QuerySnapshot result = await FirebaseFirestore.instance
        .collection("users")
        .where('dialCodePhoneList', arrayContainsAny: chunks)
        .get();
    if (result.docs.isNotEmpty) {
      log("result.docs : ${result.docs.length}");
      return result.docs;
    } else {
      return null;
    }
  }

  searchRegisterUserFromFirebase(
      BuildContext context,
      String currentUserPhone,
      SharedPreferences existingPrefs,
      bool isForceFetch,
      ) async {
    if (existingPrefs.getString('lastTimeCheckedContactBookSavedCopy') ==
        contactList.toString() &&
        isForceFetch == false) {
      searchContact = false;
      notifyListeners();
      if (oldPhoneData.isEmpty ||
          registerContactUser.isEmpty) {
        final List<RegisterContactDetail> decodedPhoneStrings =
        existingPrefs.getString('registerUserPhoneString') == null ||
            existingPrefs.getString('registerUserPhoneString') == ''
            ? []
            : RegisterContactDetail.decode(
            existingPrefs.getString('registerUserPhoneString')!);
        final List<RegisterContactDetail> decodedPhoneAndNameStrings =
        existingPrefs.getString('registerUserPhoneAndNameString') == null ||
            existingPrefs.getString('registerUserPhoneAndNameString') == ''
            ? []
            : RegisterContactDetail.decode(
            existingPrefs.getString('registerUserPhoneAndNameString')!);
        oldPhoneData = decodedPhoneStrings;
        registerContactUser = decodedPhoneAndNameStrings;
      }

      notifyListeners();

      // print(
      //     '11. SKIPPED SEARCHING - AS ${contactsBookContactList!.entries.length} CONTACTS ALREADY CHECKED IN DATABASE, ${registerContactUser.length} EXISTS');
    } else {
      // print(

      List<String> myArray =
      contactList!.entries.toList().map((e) => e.key.toString()).toList();
      List<List<String>> chunkList = divideIntoChuncks(myArray, 10);

      List<List<List<String>>> chunkgroups = divideIntoChuncksGroup(
          chunkList, 150);
      for (var chunks in chunkgroups) {
        var futureGroup = FutureGroup();

        for (var chunk in chunks) {
          futureGroup
              .add(getUsersUsingChunks(chunk));
        }

        futureGroup.close();
        var p = await futureGroup.future;
        for (var batch in p) {
          if (batch != null) {
            for (QueryDocumentSnapshot<Map<String, dynamic>> registeredUser
            in batch) {
              if (registeredUser.data()["isActive"] == true) {
                if (registerContactUser.indexWhere((element) =>
                element.phone == registeredUser.data()["phone"]) <
                    0 &&
                    registeredUser.data()["phone"] != currentUserPhone) {

                  for (var phone in registeredUser
                      .data()["dialCodePhoneList"]
                      .toList()) {
                    oldPhoneData.add(RegisterContactDetail(
                        phone: phone,
                        name: registeredUser.data()["name"],
                        image: registeredUser.data()["image"],
                        dialCode: registeredUser.data()["dialCode"] ?? "",

                        statusDesc: registeredUser.data()["statusDesc"],
                        id: registeredUser.data()["id"]));
                  }

                  registerContactUser.add(RegisterContactDetail(
                      phone: registeredUser.data()["phone"] ?? '',
                      dialCode: registeredUser.data()["dialCode"] ?? '',
                      name: registeredUser.data()["name"],
                      image: registeredUser.data()["image"],
                      statusDesc: registeredUser.data()["statusDesc"],
                      id: registeredUser.data()["id"]));

                  addData(
                      prefs: existingPrefs,
                      localUserData: UserData(
                          aboutUser: registeredUser.data()["statusDesc"] ?? "",
                          id: registeredUser.data()["id"],
                          idVariants: registeredUser.data()["phone"],
                          userType: 0,
                          time:
                          DateTime
                              .now()
                              .millisecondsSinceEpoch,
                          dialCodePhoneList: registeredUser
                              .data()["dialCodePhoneList"] ??
                              [registeredUser.data()["phone"]],
                          name: registeredUser.data()["name"],
                          photoURL: registeredUser.data()["image"] ?? ""),
                      isListener: true);
                }
              }
            }
          }
        }
      }
      notifyListeners();
      int i = registerContactUser
          .indexWhere((element) => element.phone == currentUserPhone);
      if (i >= 0) {
        registerContactUser.removeAt(i);
        oldPhoneData.removeAt(i);
      }
      notifyListeners();
      finishLoadingTasks( existingPrefs, currentUserPhone,
          fonts.done);
    }
  }

  static List<List<String>> divideIntoChuncks(List<String> array, int size) {
    List<List<String>> chunks = [];
    int i = 0;
    while (i < array.length) {
      int j = i + size;
      chunks.add(array.sublist(i, j > array.length ? array.length : j));
      i = j;
    }
    return chunks;
  }

  static List<List<List<String>>> divideIntoChuncksGroup(
      List<List<String>> array, int size) {
    List<List<List<String>>> chunks = [];
    int i = 0;
    while (i < array.length) {
      int j = i + size;
      chunks.add(array.sublist(i, j > array.length ? array.length : j));
      i = j;
    }
    return chunks;
  }

  finishLoadingTasks(SharedPreferences existingPrefs,
      String currentUserPhone, String printStatement,
      {bool isFinish = true}) async {
    if (isFinish == true) {
      searchContact = false;
    }

    final String availablePhoneEncoded =
    RegisterContactDetail.encode(oldPhoneData);

    await existingPrefs.setString(
        'registerUserPhoneString', availablePhoneEncoded);

    final String registerContactUserEncode =
    RegisterContactDetail.encode(registerContactUser);
    await existingPrefs.setString(
        'registerUserPhoneAndNameString', registerContactUserEncode);

    if (isFinish == true) {
      await existingPrefs.setString(
          'lastTimeCheckedContactBookSavedCopy', contactList.toString());
      notifyListeners();
    }
  }

  String getUserNameOrIdQuickly(String userid) {
    if (storageUserList.indexWhere((element) => element.id == userid) >= 0) {
      return storageUserList[
      storageUserList.indexWhere((element) => element.id == userid)]
          .name;
    } else {
      return 'User';
    }
  }
}

class RegisterContactDetail {
  final String? phone,dialCode;
  final String? name;
  final String id;
  final String? image;
  final String? statusDesc;

  RegisterContactDetail(
      {this.phone, this.name, required this.id, this.image, this.statusDesc, this.dialCode});

  factory RegisterContactDetail.fromJson(Map<String, dynamic> jsonData) {
    return RegisterContactDetail(
      id: jsonData['id'],
      name: jsonData['name'],
      phone: jsonData['phone'],
      statusDesc: jsonData['statusDesc'],
      image: jsonData['image'],
    );
  }

  static Map<String, dynamic> toMap(RegisterContactDetail contact) => {
    'id': contact.id,
    'name': contact.name,
    'phone': contact.phone,
    'image': contact.image,
    'statusDesc': contact.statusDesc,
  };

  static String encode(List<RegisterContactDetail> contacts) => json.encode(
    contacts
        .map<Map<String, dynamic>>(
            (contact) => RegisterContactDetail.toMap(contact))
        .toList(),
  );

  static List<RegisterContactDetail> decode(String contacts) =>
      (json.decode(contacts) as List<dynamic>)
          .map<RegisterContactDetail>(
              (item) => RegisterContactDetail.fromJson(item))
          .toList();
}