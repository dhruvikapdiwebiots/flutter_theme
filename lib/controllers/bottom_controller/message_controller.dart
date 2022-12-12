import 'dart:developer';

import 'package:flutter_theme/config.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class MessageController extends GetxController {
  String? currentUserId;
  GoogleSignIn googleSignIn = GoogleSignIn();
  User? currentUser;
  bool isHomePageSelected = true;
  List contactList = [];
  FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  String? groupId;
  PhoneContact? phoneContact;
  EmailContact? emailContact;
  FullContact? contact;
  Image? contactPhoto;

  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void onReady() {
    // TODO: implement onReady
    currentUserId = appCtrl.storage.read("id");
    update();
    final FirebaseAuth auth = FirebaseAuth.instance;
    final User user = auth.currentUser!;
    currentUser = user;
    update();
    fetch();
    configLocalNotification();
    registerNotification();
    getUser();
    update();
    super.onReady();
  }

// NOTIFICATION REGISTRATION
  void registerNotification() {
    firebaseMessaging.requestPermission();
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _showNotificationWithDefaultSound();

      return;
    });
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      return;
    });
    firebaseMessaging.getToken().then((token) {
      FirebaseFirestore.instance
          .collection('users')
          .doc(currentUserId)
          .update({'pushToken': token});
    }).catchError((err) {
      Fluttertoast.showToast(msg: err.message.toString());
    });
  }

  Future _showNotificationWithDefaultSound() async {
    var androidPlatformChannelSpecifics = const AndroidNotificationDetails(
        'your channel id', 'your channel name',
        importance: Importance.max, priority: Priority.high);
    var platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );
    await flutterLocalNotificationsPlugin.show(
      0,
      'New Post',
      'How to Show Notification in Flutter',
      platformChannelSpecifics,
      payload: 'Default_Sound',
    );
  }

  Future onSelectNotification(String payload) async {
    showDialog(
      context: Get.context!,
      builder: (_) {
        return AlertDialog(
          title: const Text("PayLoad"),
          content: Text("Payload : $payload"),
        );
      },
    );
  }

  // LOCAL CONFIGRATION OF NOTIFICATION
  void configLocalNotification() {
    var initializationSettingsAndroid =
        const AndroidInitializationSettings('@mipmap/ic_launcher');

    var initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );
    flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  // BOTTOM TABLAYOUT ICON CLICKED
  void onBottomIconPressed(int index) {
    if (index == 0 || index == 1) {
      isHomePageSelected = true;
      update();
    } else {
      isHomePageSelected = false;
      update();
    }
  }

  //on back
  Future<bool> onWillPop() async {
    return (await showDialog(
          context: Get.context!,
          builder: (context) => const AlertBack(),
        )) ??
        false;
  }

  // LOAD USERDATA LIST
  Widget loadUser(BuildContext context, DocumentSnapshot document) {
    return MessageCard(
      document: document,
      currentUserId: currentUserId,
    );
  }

  //fetch data
  Future<User?> fetch() async {
    String groupChatId = "";
    String lastSeen = "";
    // Wait for all documents to arrive, first.
    final result =
        await FirebaseFirestore.instance.collection('messages').get();
    result.docs.map((doc) async {
      String id = doc.data()['id'];
      groupChatId = '$currentUserId-$id';
      final m = await FirebaseFirestore.instance
          .collection('messages')
          .doc(groupChatId)
          .collection(groupChatId)
          .get();
      if (m.docs.isNotEmpty) {
        lastSeen = m.docs.first.data()['content'];
        // lastSeen = m.docs.first.data['content'];
      }
    });

    return null;
  }

  getUser() async {
    final contactLists =
        await FirebaseFirestore.instance.collection("users").get();

    for (int i = 0; i < contactLists.docs.length; i++) {
      if (contactLists.docs[i].id != currentUserId) {
        print(contactLists.docs[i]["id"]);
        print(currentUserId);
        final msgList = await FirebaseFirestore.instance
            .collection("messages")
            .doc("$currentUserId-${contactLists.docs[i]["id"]}")
            .get();
        print(msgList);
        if (msgList.exists) {
          contactList.add(contactLists.docs[i]);
        }
      }
    }
    update();
    print("contactLists : $contactList");
  }

  //pick up contact and check if mobile exist
  saveContactInChat() async {
    // Add your onPressed code here!
    final granted = await FlutterContactPicker.hasPermission();

    if (granted) {
      final FullContact contactPick =
          (await FlutterContactPicker.pickFullContact());
      contact = contactPick;
      contactPhoto = contactPick.photo?.asWidget();

      update();
    } else {
      await FlutterContactPicker.requestPermission().then((value) async {
        final FullContact contactPick =
            (await FlutterContactPicker.pickFullContact());
        contact = contactPick;
        contactPhoto = contactPick.photo?.asWidget();
        update();
      });
    }
    String phone = contact!.phones[0].number!;
    if (phone.length > 10) {
      if (phone.contains("-")) {
        phone = phone.replaceAll("-", "");
      } else if (phone.contains(" ")) {
        phone = phone.replaceAll(" ", "");
      }
      if (phone.length > 10) {
        phone = phone.substring(3);
      }
    }
    update();

    final m = await FirebaseFirestore.instance
        .collection('users')
        .where('phone', isEqualTo: phone)
        .limit(1)
        .get();
    if (m.docs.isEmpty) {
      log('No User');
    } else {
      var data = {"pId": m.docs[0].id, "pName": m.docs[0].data()["name"]};
      print(m.docs[0].data());
      Get.toNamed(routeName.chat, arguments: m.docs[0].data());
    }
  }
}
