import 'dart:developer';
import 'dart:io';
import 'package:flutter_theme/pages/bottom_pages/message/layout/group_message_card.dart';
import 'package:flutter_theme/pages/bottom_pages/message/layout/receiver_message_card.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_theme/config.dart';
import 'package:url_launcher/url_launcher_string.dart';

class MessageController extends GetxController {
  String? currentUserId;
  GoogleSignIn googleSignIn = GoogleSignIn();
  User? currentUser;
  bool isHomePageSelected = true;
  List contactList = [];
  List<Contact> contactUserList = [];
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
    final data = appCtrl.storage.read("user");
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

  Future getMessage() async {
    List statusData = [];
    try {
      PermissionStatus permissionStatus =
          await permissionHandelCtrl.getContactPermission();
      if (permissionStatus == PermissionStatus.granted) {
        var contacts = (await ContactsService.getContacts(
            withThumbnails: false, iOSLocalizedLabels: false));
        print(contacts.length);
        statusData = await getContactList(contacts);
        print("statusData $statusData");
      }
    } catch (e) {
      log("message : $e");
    }
    return statusData;
  }

  // LOAD USERDATA LIST
  Widget loadUser(BuildContext context, DocumentSnapshot document) {
    print("ssss");
    if (document["isGroup"] == false) {
      if (document["senderId"] == currentUserId) {

        return ReceiverMessageCard(
            document: document, currentUserId: currentUserId);
      } else {
        return MessageCard(
          document: document,
          currentUserId: currentUserId,
        );
      }
    } else {
      List user = document["receiverId"];
      return user.where((element) => element["id"] == currentUserId).isNotEmpty
          ? GroupMessageCard(
              document: document,
              currentUserId: currentUserId,
            )
          : Container();
    }
  }

  getContactList(List<Contact> contacts) async {
    List message = [];
    var statusesSnapshot =
        await FirebaseFirestore.instance.collection('users').get();
    for (int i = 0; i < statusesSnapshot.docs.length; i++) {
      for (int j = 0; j < contacts.length; j++) {
        if (contacts[j].phones!.isNotEmpty) {
          String phone = contacts[j].phones![0].value.toString();
          if (phone.length > 10) {
            if (phone.contains(" ")) {
              phone = phone.replaceAll(" ", "");
            }
            if (phone.contains("-")) {
              phone = phone.replaceAll("-", "");
            }
            if (phone.contains("+")) {
              phone = phone.replaceAll("+91", "");
            }
          }
          if (phone == statusesSnapshot.docs[i]["phone"]) {
            var messageSnapshot =
                await FirebaseFirestore.instance.collection('contacts').get();
            print("messageSnapshot : $messageSnapshot");
            for (int a = 0; a < messageSnapshot.docs.length; a++) {
              if (messageSnapshot.docs[a].data()["isGroup"] == false) {
                if (messageSnapshot.docs[a].data()["senderId"] ==
                        currentUserId ||
                    messageSnapshot.docs[a].data()["receiverId"] ==
                            statusesSnapshot.docs[i]["id"] &&
                        messageSnapshot.docs[a].data()["senderId"] ==
                            statusesSnapshot.docs[i]["id"] ||
                    messageSnapshot.docs[a].data()["receiverId"] ==
                        currentUserId) {
                  message.add(messageSnapshot.docs[a]);
                }
              }
            }
            return message;
          }
        }
      }
    }

    return message;
  }

  // LOAD USERDATA LIST
  Widget groupUser(BuildContext context, DocumentSnapshot document) {
    bool isEmpty = true;
    List user = document["users"];
    isEmpty = user.where((element) {
      return element["id"] == currentUserId;
    }).isNotEmpty;
    return isEmpty
        ? Container()
        : GroupMessageCard(
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

  //get all users
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
            if (phone.contains(" ")) {
              phone = phone.replaceAll(" ", "");
            }
            if (phone.contains("-")) {
              phone = phone.replaceAll("-", "");
            }
            if (phone.contains("+")) {
              phone = phone.replaceAll("+91", "");
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
            if (Platform.isAndroid) {
              final uri = Uri(scheme: 'Download the Chatter', path: phone);
              await launchUrl(uri);
            }
          } else {
            var data ={
              "data":m.docs[0].data(),
              "chatId": "0"
            };
            Get.toNamed(routeName.chat,
                arguments: data);
          }
        }
      });
    } else {
      permissionHandelCtrl.handleInvalidPermissions(permissionStatus);
    }
  }
}
