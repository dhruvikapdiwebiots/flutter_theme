import 'dart:developer';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_theme/config.dart';
import 'package:flutter_theme/pages/theme_pages/pick_up_call/pick_up_call.dart';
import 'package:overlay_support/overlay_support.dart';


Future<dynamic> myBackgroundMessageHandlerAndroid(RemoteMessage message) async {
  if (message.data['title'] == 'Call Ended' ||
      message.data['title'] == 'Missed Call') {
    flutterLocalNotificationsPlugin.cancelAll();

    await _showNotificationWithDefaultSound(
        'Missed Call', 'You have Missed a Call', );
  } else {
    if (message.data['title'] == 'You have new message(s)' ||
        message.data['title'] == 'New message in Group') {
      //-- need not to do anythig for these message type as it will be automatically popped up.

    } else if (message.data['title'] == 'Incoming Audio Call...' ||
        message.data['title'] == 'Incoming Video Call...') {
      final data = message.data;
      final title = data['title'];
      final body = data['body'];

      await _showNotificationWithDefaultSound(
          title, body,);
    }
  }

  return Future<void>.value();
}

// Future<dynamic> myBackgroundMessageHandlerIos(RemoteMessage message) async {
//   await Firebase.initializeApp();

//   if (message.data['title'] == 'Call Ended') {
//     final data = message.data;

//     final titleMultilang = data['titleMultilang'];
//     final bodyMultilang = data['bodyMultilang'];
//     flutterLocalNotificationsPlugin..cancelAll();
//     await _showNotificationWithDefaultSound(
//         'Missed Call', 'You have Missed a Call', titleMultilang, bodyMultilang);
//   } else {
//     if (message.data['title'] == 'You have new message(s)') {
//     } else if (message.data['title'] == 'Incoming Audio Call...' ||
//         message.data['title'] == 'Incoming Video Call...') {
//       final data = message.data;
//       final title = data['title'];
//       final body = data['body'];
//       final titleMultilang = data['titleMultilang'];
//       final bodyMultilang = data['bodyMultilang'];
//       await _showNotificationWithDefaultSound(
//           title, body, titleMultilang, bodyMultilang);
//     }
//   }

//   return Future<void>.value();
// }

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();
Future _showNotificationWithDefaultSound(String? title, String? message,) async {
  if (Platform.isAndroid) {
    flutterLocalNotificationsPlugin.cancelAll();
  }

  var initializationSettingsAndroid =
  const AndroidInitializationSettings('@mipmap/ic_launcher');
  var initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid, );
  flutterLocalNotificationsPlugin.initialize(initializationSettings);
  var androidPlatformChannelSpecifics =
  title == 'Missed Call' || title == 'Call Ended'
      ? const AndroidNotificationDetails(
      'channel_id', 'channel_name', channelDescription: "channel_description",
      importance: Importance.max,
      priority: Priority.high,
      sound: RawResourceAndroidNotificationSound('whistle2'),
      playSound: true,
      ongoing: true,

      visibility: NotificationVisibility.public,
      timeoutAfter: 28000)
      : const AndroidNotificationDetails(
      'channel_id', 'channel_name', channelDescription: "channel_description",
      sound: RawResourceAndroidNotificationSound('ringtone'),
      playSound: true,
      ongoing: true,
      importance: Importance.max,
      priority: Priority.high,
      visibility: NotificationVisibility.public,
      timeoutAfter: 28000);

  var platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
  );
  await flutterLocalNotificationsPlugin
      .show(
    0,
    '$title',
    '$message',
    platformChannelSpecifics,
    payload: 'payload',
  )
      .catchError((err) {
    print('ERROR DISPLAYING NOTIFICATION: $err');
  });
}


class Dashboard extends StatefulWidget {
  const Dashboard({Key? key}) : super(key: key);

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  final dashboardCtrl = Get.put(DashboardController());

  @override
  void initState() {
    // TODO: implement initState
    WidgetsBinding.instance.addObserver(this);
    dashboardCtrl.initConnectivity();
    listenToNotification();
    super.initState();
  }
  void listenToNotification() async {
    //FOR ANDROID  background notification is handled here whereas for iOS it is handled at the very top of main.dart ------
    if (Platform.isAndroid) {
      FirebaseMessaging.onBackgroundMessage(myBackgroundMessageHandlerAndroid);
    }
    //ANDROID & iOS  OnMessage callback
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      // ignore: unnecessary_null_comparison
      flutterLocalNotificationsPlugin.cancelAll();

      if (message.data['title'] != 'Call Ended' &&
          message.data['title'] != 'Missed Call' &&
          message.data['title'] != 'You have new message(s)' &&
          message.data['title'] != 'Incoming Video Call...' &&
          message.data['title'] != 'Incoming Audio Call...' &&
          message.data['title'] != 'Incoming Call ended' &&
          message.data['title'] != 'New message in Group') {
        log("newnotifications");
      } else {
        // if (message.data['title'] == 'New message in Group') {
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
            final data = message.data;
            final title = data['title'];
            final body = data['body'];
            await _showNotificationWithDefaultSound(
                title, body,);
          } else if (message.data['title'] == 'You have new message(s)') {
            if (dashboardCtrl.user["id"] != message.data['peerid']) {
              // FlutterRingtonePlayer.playNotification();
              showOverlayNotification((context) {
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  child: SafeArea(
                    child: ListTile(
                      title: Text(
                        message.data['titleMultilang'],
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text(
                        message.data['bodyMultilang'],
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () {
                            OverlaySupportEntry.of(context)!.dismiss();
                          }),
                    ),
                  ),
                );
              }, duration: const Duration(milliseconds: 2000));
            }

          } else {
            showOverlayNotification((context) {
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                child: SafeArea(
                  child: ListTile(
                    leading: Image.network(
                      message.data['image'],
                      width: 50,
                      height: 70,
                      fit: BoxFit.cover,
                    ),
                    title: Text(
                      message.data['titleMultilang'],
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      message.data['bodyMultilang'],
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          OverlaySupportEntry.of(context)!.dismiss();
                        }),
                  ),
                ),
              );
            }, duration: const Duration(milliseconds: 2000));
          }
        }
      }
    });
    //ANDROID & iOS  onMessageOpenedApp callback
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
      flutterLocalNotificationsPlugin.cancelAll();
      Map<String, dynamic> notificationData = message.data;
      AndroidNotification? android = message.notification?.android;
      if (android != null) {
        if (notificationData['title'] == 'Call Ended') {
          flutterLocalNotificationsPlugin.cancelAll();
        } else if (notificationData['title'] != 'Call Ended' &&
            notificationData['title'] != 'You have new message(s)' &&
            notificationData['title'] != 'Missed Call' &&
            notificationData['title'] != 'Incoming Video Call...' &&
            notificationData['title'] != 'Incoming Audio Call...' &&
            notificationData['title'] != 'Incoming Call ended' &&
            notificationData['title'] != 'New message in Group') {
          flutterLocalNotificationsPlugin.cancelAll();

        } else {
          flutterLocalNotificationsPlugin.cancelAll();
        }
      }
    });
    FirebaseMessaging.instance.getInitialMessage().then((message) {
      if (message != null) {
        flutterLocalNotificationsPlugin.cancelAll();
        Map<String, dynamic>? notificationData = message.data;
        if (notificationData['title'] != 'Call Ended' &&
            notificationData['title'] != 'You have new message(s)' &&
            notificationData['title'] != 'Missed Call' &&
            notificationData['title'] != 'Incoming Video Call...' &&
            notificationData['title'] != 'Incoming Audio Call...' &&
            notificationData['title'] != 'Incoming Call ended' &&
            notificationData['title'] != 'New message in Group') {
          flutterLocalNotificationsPlugin.cancelAll();

        }
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      firebaseCtrl.setIsActive();
    } else {
      firebaseCtrl.setLastSeen();
    }
    firebaseCtrl.statusDeleteAfter24Hours();

    log("cccccc");
    log("index : ${dashboardCtrl.controller!.index}");
    dashboardCtrl.connectivitySubscription =
        dashboardCtrl.connectivity.onConnectivityChanged.listen((event) {
      dashboardCtrl.updateConnectionStatus(event);
    });

  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<DashboardController>(builder: (_) {
      dashboardCtrl.onChange(dashboardCtrl.controller!.index);
      log("index : ${dashboardCtrl.selectedIndex}");
      return PickupLayout(
        scaffold: StreamBuilder(
            stream: Connectivity().onConnectivityChanged,
            builder: (context, AsyncSnapshot<ConnectivityResult> snapshot) {
              log("snapshot : ${snapshot.data}");


              return WillPopScope(
                onWillPop: () async {
                  SystemNavigator.pop();
                  return false;
                },
                child: dashboardCtrl.bottomList.isNotEmpty
                    ? DashboardBody(snapshot: snapshot,)
                    : Container(),
              );
            }),
      );
    });
  }
}
