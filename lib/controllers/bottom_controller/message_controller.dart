import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:flutter_theme/config.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class MessageController extends GetxController {
  String? currentUserId;
  GoogleSignIn googleSignIn = GoogleSignIn();
  User? currentUser;
  bool isHomePageSelected = true;
  FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

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
    _fetch();
    configLocalNotification();
    registerNotification();
    update();
    super.onReady();
  }

// NOTIFICATION REGISTRATION

  void registerNotification() {
    firebaseMessaging.requestPermission();
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _showNotificationWithDefaultSound();
      print('onMessage: $message');
      return;
    });
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('onMessageOpenedApp: $message');
      return;
    });
    firebaseMessaging.getToken().then((token) {
      print('token: $token');
      FirebaseFirestore.instance
          .collection('users')
          .doc(currentUserId)
          .update({'pushToken': token});
    }).catchError((err) {
      Fluttertoast.showToast(msg: err.message.toString());
    });
  }

  Future _showNotificationWithDefaultSound() async {
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
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
          title: Text("PayLoad"),
          content: Text("Payload : $payload"),
        );
      },
    );
  }

  // LOCAL CONFIGRATION OF NOTIFICATION

  void configLocalNotification() {
    var initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    var initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );
    flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  // SHOW NOTIFICATION STUCTURE

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

  Future<bool> onWillPop() async {
    return (await showDialog(
          context: Get.context!,
          builder: (context) => AlertDialog(
            title: const Text('Alert!'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text("Are you sure you want to exit from the app"),
              ],
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Close'),
              ),
              TextButton(
                onPressed: () async {
                  SystemNavigator.pop();
                },
                child: const Text('Yes'),
              ),
            ],
          ),
        )) ??
        false;
  }

  // LOAD USERDATA LIST
  Widget loadUser(BuildContext context, DocumentSnapshot document) {
    if (document['id'] == currentUserId) {
      return Container();
    } else {
      return Container(
        decoration:
            BoxDecoration(border: Border(bottom: BorderSide(width: 0.2))),
        child: TextButton(
          child: Row(
            children: <Widget>[
              Material(
                child: document['image'] != null
                    ? CachedNetworkImage(
                        placeholder: (context, url) => Container(
                          child: CircularProgressIndicator(
                            strokeWidth: 1.0,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(appCtrl.appTheme.primary),
                          ),
                          width: 50.0,
                          height: 50.0,
                          padding: EdgeInsets.all(10.0),
                        ),
                        imageUrl: document['image'],
                        width: 40.0,
                        height: 40.0,
                        fit: BoxFit.cover,
                      )
                    : Icon(
                        Icons.account_circle,
                        size: 50.0,
                        color: appCtrl.appTheme.grey,
                      ),
                borderRadius: BorderRadius.all(Radius.circular(25.0)),
                clipBehavior: Clip.hardEdge,
              ),
              Flexible(
                child: Container(
                  child: Column(
                    children: <Widget>[
                      Container(
                        child: Text(
                          document['name'],
                          style: TextStyle(color: appCtrl.appTheme.primary, fontSize: 16),
                        ),
                        alignment: Alignment.centerLeft,
                        margin: EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 5.0),
                      ),
                    ],
                  ),
                  margin: EdgeInsets.only(left: 10.0),
                ),
              ),
            ],
          ),
          onPressed: () {
          /*  Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => Chat(
                          pId: document.id,
                          pName: document['name'],
                        )));*/
          },
          /*padding: EdgeInsets.fromLTRB(25.0, 10.0, 25.0, 10.0),*/
        ),
        padding: EdgeInsets.fromLTRB(25.0, 10.0, 25.0, 10.0),
        margin: EdgeInsets.only(bottom: 10.0, left: 5.0, right: 5.0),
      );
    }
  }

  Future<User?> _fetch() async {
    String groupChatId = "";
    String lastSeen = "";
    // Wait for all documents to arrive, first.
    final result = await FirebaseFirestore.instance.collection('users').get();
    result.docs.forEach((doc) async {
      String id = doc.data()['id'];
      if (id.hashCode <= currentUserId.hashCode) {
        groupChatId = '$id-$currentUserId';
      } else {
        groupChatId = '$currentUserId-$id';
      }
      final m = await FirebaseFirestore.instance
          .collection('messages')
          .doc(groupChatId)
          .collection(groupChatId)
          .get();
      if (m.docs.length > 0) {
        lastSeen = m.docs.first.data()['content'];
        // lastSeen = m.docs.first.data['content'];
      }
    });
  }
}
