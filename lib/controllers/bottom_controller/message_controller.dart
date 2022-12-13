import 'dart:developer';
import 'dart:io';

import 'package:contacts_service/contacts_service.dart';
import 'package:flutter_theme/config.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';

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
  Image? contactPhoto;
  XFile? imageFile;
  File? image;
  List selectedContact = [];

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

// UPLOAD SELECTED IMAGE TO FIREBASE
  Future uploadFile() async {
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    Reference reference = FirebaseStorage.instance.ref().child(fileName);
    log("reference : $reference");
    image = File(imageFile!.path);
    var file = File(imageFile!.path);
    update();
  }

// GET IMAGE FROM GALLERY
  Future getImage(source) async {
    final ImagePicker picker = ImagePicker();
    imageFile = (await picker.pickImage(source: source))!;
    log("imageFile : $imageFile");
    if (imageFile != null) {
      update();
      uploadFile();
    }
  }

  //image picker option
  imagePickerOption(BuildContext context) {
    showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
          borderRadius:
              BorderRadius.vertical(top: Radius.circular(AppRadius.r25)),
        ),
        builder: (BuildContext context) {
          // return your layout
          return ImagePickerLayout(cameraTap: () {
            getImage(ImageSource.camera);
            Get.back();
          }, galleryTap: () {
            getImage(ImageSource.gallery);
            Get.back();
          });
        });
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
    PermissionStatus permissionStatus = await _getContactPermission();
    print(permissionStatus);
    if (permissionStatus == PermissionStatus.granted) {
      Get.to(ContactListPage())!.then((value) async {
        log("ccc : ${value}");
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
            var data = {"pId": m.docs[0].id, "pName": m.docs[0].data()["name"]};
            print(m.docs[0].data());
            Get.toNamed(routeName.chat, arguments: m.docs[0].data());
          }
        }
      });
    } else {
      _handleInvalidPermissions(permissionStatus);
    }
  }

  Future<PermissionStatus> _getContactPermission() async {
    PermissionStatus permission = await Permission.contacts.status;
    if (permission != PermissionStatus.granted &&
        permission != PermissionStatus.permanentlyDenied) {
      PermissionStatus permissionStatus = await Permission.contacts.request();
      return permissionStatus;
    } else {
      return permission;
    }
  }

  void _handleInvalidPermissions(PermissionStatus permissionStatus) {
    if (permissionStatus == PermissionStatus.denied) {
      final snackBar = SnackBar(content: Text('Access to contact data denied'));
      ScaffoldMessenger.of(Get.context!).showSnackBar(snackBar);
    } else if (permissionStatus == PermissionStatus.permanentlyDenied) {
      final snackBar =
          SnackBar(content: Text('Contact data not available on device'));
      ScaffoldMessenger.of(Get.context!).showSnackBar(snackBar);
    }
  }
}

class ContactListPage extends StatefulWidget {
  @override
  _ContactListPageState createState() => _ContactListPageState();
}

class _ContactListPageState extends State<ContactListPage> {
  List<Contact>? _contacts;
  List selectedContact = [];

  @override
  void initState() {
    super.initState();
    refreshContacts();
  }

  Future<void> refreshContacts() async {
    // Load without thumbnails initially.
    var contacts = (await ContactsService.getContacts(
        withThumbnails: false, iOSLocalizedLabels: false));
//      var contacts = (await ContactsService.getContactsForPhone("8554964652"))
//          ;
    setState(() {
      _contacts = contacts;
    });

    // Lazy load thumbnails after rendering initial contacts.
    for (final contact in contacts) {
      ContactsService.getAvatar(contact).then((avatar) {
        if (avatar == null) return; // Don't redraw if no change.
        setState(() => contact.avatar = avatar);
      });
    }
  }

  void updateContact() async {
    Contact ninja = _contacts!
        .firstWhere((contact) => contact.familyName!.startsWith("Ninja"));
    ninja.avatar = null;
    await ContactsService.updateContact(ninja);

    refreshContacts();
  }

  _openContactForm() async {
    try {
      var _ = await ContactsService.openContactForm(iOSLocalizedLabels: false);
      refreshContacts();
    } on FormOperationException catch (e) {
      switch (e.errorCode) {
        case FormOperationErrorCode.FORM_OPERATION_CANCELED:
        case FormOperationErrorCode.FORM_COULD_NOT_BE_OPEN:
        case FormOperationErrorCode.FORM_OPERATION_UNKNOWN_ERROR:
        default:
          print(e.errorCode);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Contacts ',
        ),
      ),
      body: SafeArea(
        child: _contacts != null
            ? ListView.builder(
                itemCount: _contacts?.length ?? 0,
                itemBuilder: (BuildContext context, int index) {
                  Contact c = _contacts!.elementAt(index);
                  return ListTile(
                    onTap: () {
                      var id = _contacts!
                          .indexWhere((c) => c.identifier == c.identifier);
                      _contacts![id] = c;
                      print("contact : ${c}");
                      Get.back(result: c);
                    },
                    leading: (c.avatar != null && c.avatar!.length > 0)
                        ? CircleAvatar(backgroundImage: MemoryImage(c.avatar!))
                        : CircleAvatar(child: Text(c.initials())),
                    title: Text(c.displayName ?? ""),
                    subtitle: Text(c.phones![0].value ?? ""),
                  );
                },
              )
            : Center(
                child: CircularProgressIndicator(),
              ),
      ),
    );
  }

  void contactOnDeviceHasBeenUpdated(Contact contact) {
    this.setState(() {
      var id = _contacts!.indexWhere((c) => c.identifier == contact.identifier);
      _contacts![id] = contact;
    });
  }
}

class GroupSelect extends StatefulWidget {
  const GroupSelect({Key? key}) : super(key: key);

  @override
  State<GroupSelect> createState() => _GroupSelectState();
}

class _GroupSelectState extends State<GroupSelect> {
  List<Contact>? _contacts;
  List selectedContact = [];
  List contactList = [];
  final formKey = GlobalKey<FormState>();
  TextEditingController txtGroupName = TextEditingController();

  @override
  void initState() {
    super.initState();

    refreshContacts();
  }

  Future<void> refreshContacts() async {
    // Load without thumbnails initially.
    var contacts = (await ContactsService.getContacts(
        withThumbnails: false, iOSLocalizedLabels: false));
//      var contacts = (await ContactsService.getContactsForPhone("8554964652"))
//          ;
    setState(() {
      _contacts = contacts;
    });

    // Lazy load thumbnails after rendering initial contacts.
    for (final contact in contacts) {
      ContactsService.getAvatar(contact).then((avatar) {
        if (avatar == null) return; // Don't redraw if no change.
        setState(() => contact.avatar = avatar);
      });
    }
    getFirebaseContact();
  }

  getFirebaseContact() async {
    final msgList = await FirebaseFirestore.instance.collection("users").get();

    for (final user in msgList.docs) {
      print(user.data()["phone"]);
      for (final contact in _contacts!) {
        String phone = contact.phones![0].value.toString();
        print(user.data()["phone"]);
        print(phone);
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
        print(phone == user.data()["phone"]);
        if (phone == user.data()["phone"]) {
          final storeUser = appCtrl.storage.read("user");
          if (user.data()["id"] != storeUser["id"]) {
            contactList.add(user.data());
          }
        }
      }
    }
    print(contactList);
    setState(() {});
  }

  void updateContact() async {
    Contact ninja = _contacts!
        .firstWhere((contact) => contact.familyName!.startsWith("Ninja"));
    ninja.avatar = null;
    await ContactsService.updateContact(ninja);

    refreshContacts();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<MessageController>(builder: (chatCtrl) {
      return WillPopScope(
        onWillPop: () async {
          chatCtrl.selectedContact = [];
          chatCtrl.update();
          return true;
        },
        child: Scaffold(
          appBar: AppBar(
            centerTitle: false,
            // leadingWidth: 40,
            title: Text("selectcontacts",
                style: TextStyle(
                  fontSize: 18,
                ),
                textAlign: TextAlign.left),
          ),
          floatingActionButton: chatCtrl.selectedContact.isNotEmpty
              ? FloatingActionButton(
                  onPressed: () async {
                    showModalBottomSheet(
                        isScrollControlled: true,
                        context: context,
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.vertical(top: Radius.circular(25.0)),
                        ),
                        builder: (BuildContext context) {
                          // return your layout
                          var w = MediaQuery.of(context).size.width;
                          return Padding(
                            padding: EdgeInsets.only(
                                bottom:
                                    MediaQuery.of(context).viewInsets.bottom),
                            child: Container(
                                padding: EdgeInsets.all(16),
                                height:
                                    MediaQuery.of(context).size.height / 2.2,
                                child: Form(
                                  key: formKey,
                                  child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        SizedBox(
                                          height: 15,
                                        ),
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(left: 8),
                                          child: Text(
                                            'setgroup',
                                            textAlign: TextAlign.left,
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16.5),
                                          ),
                                        ),
                                        SizedBox(
                                          height: 20,
                                        ),
                                        Row(
                                          children: [
                                            chatCtrl.image != null
                                                ? Container(
                                                    height: Sizes.s60,
                                                    width: Sizes.s60,
                                                    child: Image.file(
                                                            chatCtrl.image!,
                                                            fit: BoxFit.fill)
                                                        .clipRRect(
                                                            all: AppRadius.r50),
                                                    decoration: BoxDecoration(
                                                        color: appCtrl
                                                            .appTheme.gray
                                                            .withOpacity(.2),
                                                        shape: BoxShape.circle),
                                                  ).inkWell(
                                                    onTap: () => chatCtrl
                                                        .imagePickerOption(
                                                            context))
                                                : Container(
                                                    height: Sizes.s60,
                                                    width: Sizes.s60,
                                                    alignment: Alignment.center,
                                                    padding:
                                                        const EdgeInsets.all(
                                                            Insets.i15),
                                                    decoration: BoxDecoration(
                                                        color: appCtrl
                                                            .appTheme.gray
                                                            .withOpacity(.2),
                                                        image: DecorationImage(
                                                            image: AssetImage(
                                                                imageAssets
                                                                    .user),
                                                            fit: BoxFit.fill),
                                                        shape: BoxShape.circle),
                                                  ).inkWell(
                                                    onTap: () => chatCtrl
                                                        .imagePickerOption(
                                                            context)),
                                            const HSpace(Sizes.s15),
                                            Expanded(
                                              child: CommonTextBox(
                                                controller: txtGroupName,
                                                labelText: "Group Name",
                                                validator: (val) {
                                                  if (val!.isEmpty) {
                                                    return "Group Name Required";
                                                  } else {
                                                    return null;
                                                  }
                                                },
                                                maxLength: 25,
                                                border: OutlineInputBorder(
                                                    borderSide: BorderSide(
                                                        color: appCtrl
                                                            .appTheme.primary)),
                                                textInputAction:
                                                    TextInputAction.next,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const VSpace(Sizes.s20),
                                        CommonButton(
                                          title: "Create",
                                          style: AppCss.poppinsMedium14
                                              .textColor(
                                                  appCtrl.appTheme.whiteColor),
                                          margin: 0,
                                          onTap: () async {
                                            final user = appCtrl.storage.read("user");
                                            FirebaseFirestore.instance
                                                .collection('groups')
                                                .add({
                                              "name": txtGroupName.text,
                                              "image":"",
                                              "groupTypeNotification":"new_added",
                                              "users":chatCtrl.selectedContact,
                                              "createdBy": user,
                                              'timestamp': DateTime.now()
                                                  .millisecondsSinceEpoch
                                                  .toString(),
                                              // I dont know why you called it just timestamp i changed it on created and passed an function with serverTimestamp()
                                            });
                                          },
                                        )
                                      ]),
                                )),
                          );
                        });
                  },
                  backgroundColor: appCtrl.appTheme.primary,
                  child: const Icon(Icons.arrow_right_alt),
                )
              : Container(),
          body: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (chatCtrl.selectedContact.isNotEmpty)
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children:
                            chatCtrl.selectedContact.asMap().entries.map((e) {
                          return Stack(
                            children: [
                              Container(
                                width: 90,
                                padding:
                                    const EdgeInsets.fromLTRB(11, 10, 12, 10),
                                child: Column(
                                  children: [
                                    CachedNetworkImage(
                                        imageUrl: e.value["image"].toString(),
                                        imageBuilder: (context,
                                                imageProvider) =>
                                            CircleAvatar(
                                              backgroundColor:
                                                  Color(0xffE6E6E6),
                                              radius: 30,
                                              backgroundImage: NetworkImage(
                                                  e.value["image"].toString()),
                                            ),
                                        placeholder: (context, url) =>
                                            CircleAvatar(
                                              backgroundColor:
                                                  Color(0xffE6E6E6),
                                              radius: 30,
                                              child: Icon(
                                                Icons.person,
                                                color: Color(0xffCCCCCC),
                                              ),
                                            ),
                                        errorWidget: (context, url, error) =>
                                            CircleAvatar(
                                              backgroundColor:
                                                  Color(0xffE6E6E6),
                                              radius: 30,
                                              child: Icon(
                                                Icons.person,
                                                color: Color(0xffCCCCCC),
                                              ),
                                            )),
                                    SizedBox(
                                      height: 7,
                                    ),
                                    Text(
                                      e.value["name"].toString(),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              Positioned(
                                right: 17,
                                top: 5,
                                child: new InkWell(
                                  onTap: () {
                                    chatCtrl.selectedContact.remove(e.value);
                                    chatCtrl.update();
                                  },
                                  child: new Container(
                                    width: 20.0,
                                    height: 20.0,
                                    padding: const EdgeInsets.all(2.0),
                                    decoration: new BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.black,
                                    ),
                                    child: Icon(
                                      Icons.close,
                                      size: 14,
                                      color: Colors.white,
                                    ),
                                  ), //............
                                ),
                              )
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  if (contactList != null)
                    Column(
                      children: [
                        ...contactList.asMap().entries.map((e) {
                          return ListTile(
                            onTap: () {
                              if (chatCtrl.selectedContact.contains(e.value)) {
                                chatCtrl.selectedContact.remove(e.value);
                              } else {
                                chatCtrl.selectedContact.add(e.value);
                              }
                              chatCtrl.update();
                            },
                            trailing: Container(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                      color: appCtrl.appTheme.borderGray,
                                      width: 1),
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: Icon(
                                  chatCtrl.selectedContact.contains(e.value)
                                      ? Icons.check
                                      : null,
                                  size: 19.0,
                                )),
                            leading: (e.value["image"] != null &&
                                    e.value["image"]!.length > 0)
                                ? CircleAvatar(
                                    backgroundImage:
                                        NetworkImage(e.value["image"]!))
                                : CircleAvatar(child: Text(e.value["name"][0])),
                            title: Text(e.value["name"] ?? ""),
                            subtitle: Text(e.value["phone"] ?? ""),
                          );
                        }).toList()
                      ],
                    )
                ],
              ),
            ),
          ),
        ),
      );
    });
  }
}
