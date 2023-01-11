import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter_theme/config.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';


//when app in background
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  log('Handling a background message ${message.messageId}');
  log("message.data : ${message.data}");

}

/// Create a [AndroidNotificationChannel] for heads up notifications
AndroidNotificationChannel? channel;

/// Initialize the [FlutterLocalNotificationsPlugin] package.
FlutterLocalNotificationsPlugin? flutterLocalNotificationsPlugin;


class NotificationController extends GetxController{
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
        log("Notification On InitMsg");
        log("Notification On InitMsg: $message");
        //Navigator.pushNamed(context, '/result', arguments: message.data);
        showFlutterNotification(message);
      }
    });

    var initialzationSettingsAndroid =
    const AndroidInitializationSettings('@mipmap/ic_launcher');
    var initializationSettings = InitializationSettings(
        android: initialzationSettingsAndroid, );

    flutterLocalNotificationsPlugin.initialize(initializationSettings);
    log('initCheck');
    //when app in foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      log('message : $message');
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
      showFlutterNotification(message);
      //Navigator.pushNamed(context, '/result', arguments: message.data);
    });

    //when app in background
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      log('A new onMessageOpenedApp event was published!');
      log("onMessageOpenedApp: $message");

      showFlutterNotification(message);
    });

    requestPermissions();
  }

  void showFlutterNotification(RemoteMessage message) {
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;
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

  requestPermissions() async {
    NotificationSettings settings = await FirebaseMessaging.instance.requestPermission(
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
    super.onReady();
  }

}