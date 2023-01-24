import 'dart:developer';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_theme/config.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../../main.dart';
import 'package:http/http.dart' as http;

//when app in background
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  log('Handling a background message ${message.messageId}');
  log("message.data : ${message.data}");
}

/// Create a [AndroidNotificationChannel] for heads up notifications
AndroidNotificationChannel? channel;

/// Initialize the [FlutterLocalNotificationsPlugin] package.
FlutterLocalNotificationsPlugin? flutterLocalNotificationsPlugin;

class CustomNotificationController extends GetxController {
  AndroidNotificationChannel? channel;

  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;

  Future<void> initNotification() async {
    log('initCall');
    //when app in background
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    if (!kIsWeb) {
      channel = const AndroidNotificationChannel(
        'high_importance_channel', // id
        'High Importance Notifications', // titledescription
        importance: Importance.high,
      );

      flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

      /// We use this channel in the `AndroidManifest.xml` file to override the
      /// default FCM channel to enable heads up notifications.
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel!);
    }

    //when app is [closed | killed | terminated]
    FirebaseMessaging.instance
        .getInitialMessage()
        .then((RemoteMessage? message) {
      if (message != null) {
        flutterLocalNotificationsPlugin.cancelAll();
        Map<String, dynamic>? notificationData = message.data;
        if (notificationData['title'] != 'Call Ended' &&
            notificationData['title'] != 'Single Message' &&
            notificationData['title'] != 'Missed Call' &&
            notificationData['title'] != 'Incoming Video Call...' &&
            notificationData['title'] != 'Incoming Audio Call...' &&
            notificationData['title'] != 'Incoming Call ended' &&
            notificationData['title'] != 'Group Message') {
          flutterLocalNotificationsPlugin.cancelAll();
          log("message.data : ${message.data}");
          if (message.data["isGroup"] == true) {
          } else {
            var data = {
              "chatId": message.data["chatId"],
              "data": message.data["userContact"]
            };
            Get.toNamed(routeName.chat, arguments: data);
          }
          showFlutterNotification(message);
        }
      }
    });

    var initialzationSettingsAndroid =
        const AndroidInitializationSettings('@mipmap/ic_launcher');
    var initializationSettings = InitializationSettings(
      android: initialzationSettingsAndroid,
    );

    flutterLocalNotificationsPlugin.initialize(initializationSettings);

    //when app in foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      RemoteNotification notification = message.notification!;

      AndroidNotification? android = message.notification?.android;
      if (android != null && !kIsWeb) {
        flutterLocalNotificationsPlugin.show(
            notification.hashCode,
            notification.title,
            notification.body,
            NotificationDetails(
              android: AndroidNotificationDetails(
                channel!.id,
                channel!.name,
                // TODO add a proper drawable resource to android, for now using
                //      one that already exists in example app.
                icon: 'launch_background',
              ),
            ));
      }
      // ignore: unnecessary_null_comparison
      log("notification1 : ${message.data}");
      flutterLocalNotificationsPlugin.cancelAll();

      if (message.data['title'] != 'Call Ended' &&
          message.data['title'] != 'Missed Call' &&
          message.data['title'] != 'You have new message(s)' &&
          message.data['title'] != 'Incoming Video Call...' &&
          message.data['title'] != 'Incoming Audio Call...' &&
          message.data['title'] != 'Incoming Call ended' &&
          message.data['title'] != 'Group Message') {
        log("newnotifications");
        showFlutterNotification(message);
      } else {
        // if (message.data['title'] == 'Group Message') {
        //   var currentpeer =
        //       Provider.of<CurrentChatPeer>(this.context, listen: false);
        //   if (currentpeer.groupChatId != message.data['groupid']) {
        //     flutterLocalNotificationsPlugin!.cancelAll();

        //     showOverlayNotification((context) {
        //       return Card(
        //         margin: const EdgeInsets.symmetric(horizontal: 4),
        //         child: SafeArea(
        //           child: ListTile(
        //             title: Text(
        //               message.data['titleMultilang'],
        //               maxLines: 1,
        //               overflow: TextOverflow.ellipsis,
        //             ),
        //             subtitle: Text(
        //               message.data['bodyMultilang'],
        //               maxLines: 2,
        //               overflow: TextOverflow.ellipsis,
        //             ),
        //             trailing: IconButton(
        //                 icon: Icon(Icons.close),
        //                 onPressed: () {
        //                   OverlaySupportEntry.of(context)!.dismiss();
        //                 }),
        //           ),
        //         ),
        //       );
        //     }, duration: Duration(milliseconds: 2000));
        //   }
        // } else

        if (message.data['title'] == 'Call Ended') {
          flutterLocalNotificationsPlugin.cancelAll();
        } else {
          if (message.data['title'] == 'Incoming Audio Call...' ||
              message.data['title'] == 'Incoming Video Call...') {
            showFlutterNotification(message);
          } else if (message.data['title'] == 'Single Message') {
            log("ovrr : ");
            showFlutterNotification(message);
          } else {
            showFlutterNotification(message);
          }
        }
      }

      //Navigator.pushNamed(context, '/result', arguments: message.data);
    });

    //when app in background
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      log('A new onMessageOpenedApp event was published!');
      log("onMessageOpenedApp: $message");
      flutterLocalNotificationsPlugin.cancelAll();
      Map<String, dynamic> notificationData = message.data;
      AndroidNotification? android = message.notification?.android;
      if (android != null) {
        if (notificationData['title'] == 'Call Ended') {
          flutterLocalNotificationsPlugin.cancelAll();
        } else if (notificationData['title'] != 'Call Ended' &&
            notificationData['title'] != 'Single Message' &&
            notificationData['title'] != 'Missed Call' &&
            notificationData['title'] != 'Incoming Video Call...' &&
            notificationData['title'] != 'Incoming Audio Call...' &&
            notificationData['title'] != 'Incoming Call ended' &&
            notificationData['title'] != 'Group Message') {
          flutterLocalNotificationsPlugin.cancelAll();
        } else {
          flutterLocalNotificationsPlugin.cancelAll();
        }
      }
    });

    requestPermissions();
  }

  void showFlutterNotification(RemoteMessage message) async {
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;
    if (message.data["title"] == "Incoming Video Call..." &&
        message.data["title"] == "Incoming Audio Call...") {
      await AwesomeNotifications().createNotification(
          content: NotificationContent(
              id: -1,
              // -1 is replaced by a random number
              channelKey: 'alerts',
              title: 'Huston! The eagle has landed!',
              body:
                  "A small step for a man, but a giant leap to Flutter's community!",
              bigPicture: 'https://storage.googleapis.com/cms-storage-bucket/d406c736e7c4c57f5f61.png',
              largeIcon: 'https://storage.googleapis.com/cms-storage-bucket/0dbfcc7a59cd1cf16282.png',
              //'asset://assets/images/balloons-in-sky.jpg',
              notificationLayout: NotificationLayout.BigPicture,
              payload: {'notificationId': "1234567890"}),
          actionButtons: [
            NotificationActionButton(key: 'REDIRECT', label: 'Redirect'),
            NotificationActionButton(
              key: 'REPLY',
              label: 'Reply Message',
              requireInputText: true,
              actionType: ActionType.SilentAction,
            ),
            NotificationActionButton(
                key: 'DISMISS',
                label: 'Dismiss',
                actionType: ActionType.DismissAction,
                isDangerousOption: true)
          ]);
    } else {
      if (notification != null && android != null && !kIsWeb) {
        flutterLocalNotificationsPlugin.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              channel!.id,
              channel!.name,
              channelDescription: channel!.description,
              // TODO add a proper drawable resource to android, for now using
              //      one that already exists in example app.
              icon: 'launch_background',
            ),
          ),
        );
      }
    }
  }

  requestPermissions() async {
    NotificationSettings settings =
        await FirebaseMessaging.instance.requestPermission(
      announcement: true,
      carPlay: true,
      criticalAlert: true,
    );

    log("settings.authorizationStatus: ${settings.authorizationStatus}");
  }

  @override
  void onReady() {
    // TODO: implement onReady
    initNotification();
    AwesomeNotificationController.startListeningNotificationEvents();
    super.onReady();
  }
}
