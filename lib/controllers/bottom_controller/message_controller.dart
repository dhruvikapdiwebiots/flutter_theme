import 'dart:developer';
import 'dart:io';
import 'package:flutter_theme/pages/bottom_pages/message/layout/group_message_card.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_theme/config.dart';

class MessageController extends GetxController {
  String? currentUserId;
  GoogleSignIn googleSignIn = GoogleSignIn();
  User? currentUser;
  bool isHomePageSelected = true;
  List contactList = [];
  FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;

  String? groupId;
  Image? contactPhoto;
  XFile? imageFile;
  File? image;
  List selectedContact = [];
  final permissionHandelCtrl = Get.isRegistered<PermissionHandlerController>()
      ? Get.find<PermissionHandlerController>()
      : Get.put(PermissionHandlerController());
  final notificationCtrl = Get.isRegistered<NotificationController>()
      ? Get.find<NotificationController>()
      : Get.put(NotificationController());

  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void onReady() {
    // TODO: implement onReady
    final data  = appCtrl.storage.read("user");
    currentUserId = data["id"];
    update();
    final FirebaseAuth auth = FirebaseAuth.instance;
    final User user = auth.currentUser!;
    currentUser = user;
    update();
    fetch();
    notificationCtrl.configLocalNotification();
    notificationCtrl.registerNotification();
    getUser();
    update();
    super.onReady();
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
    bool isEmpty = true;
    print("currentUserId : ${document["isGroup"]}");
    if (document["isGroup"] == true) {
      List user  = document["receiverId"];
      print(user);
      isEmpty = user.where((element) {
        print("check  : ${element["id"] == currentUserId}");
        return element["id"] == currentUserId;
      }).isNotEmpty;
      print("isEmpty : $isEmpty");
      print("isEmpty : ${document["group"]}");
    }

    if (document["isGroup"] == false) {
      return MessageCard(
        document: document,
        currentUserId: currentUserId,
      );
    } else {

      return !isEmpty ? Container() : GroupMessageCard(
        document: document,
        currentUserId: currentUserId,
      );
    }
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
        final msgList = await FirebaseFirestore.instance
            .collection("messages")
            .doc("$currentUserId-${contactLists.docs[i]["id"]}")
            .get();
        if (msgList.exists) {
          contactList.add(contactLists.docs[i]);
        }
      }
    }
    update();
  }

  //pick up contact and check if mobile exist
  saveContactInChat() async {
    // Add your onPressed code here!
    PermissionStatus permissionStatus =
        await permissionHandelCtrl.getContactPermission();
    if (permissionStatus == PermissionStatus.granted) {
      Get.toNamed(routeName.contactList)!.then((value) async {
        if (value != null) {
          Contact contact = value;
          log("contact : ${contact.phones![0].value}");
          String phone = contact.phones![0].value!;
          if (phone.length > 10) {
            if (phone.contains("-")) {
              phone = phone.replaceAll("-", "");
            } else if (phone.contains("+")) {
              phone = phone.replaceAll("+", "");
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
            Get.toNamed(routeName.chat, arguments: m.docs[0].data());
          }
        }
      });
    } else {
      permissionHandelCtrl.handleInvalidPermissions(permissionStatus);
    }
  }
}
