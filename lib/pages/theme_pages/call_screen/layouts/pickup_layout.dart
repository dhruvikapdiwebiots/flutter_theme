//*************   © Copyrighted by Thinkcreative_Technologies. An Exclusive item of Envato market. Make sure you have purchased a Regular License OR Extended license for the Source Code from Envato to use this product. See the License Defination attached with source code. *********************

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/material.dart';
import 'package:flutter_theme/config.dart';
import 'package:flutter_theme/models/call_model.dart';
import 'package:flutter_theme/pages/theme_pages/call_screen/layouts/call_firebase_method.dart';
import 'package:flutter_theme/pages/theme_pages/call_screen/layouts/pickup_screen.dart';
import 'package:provider/provider.dart';

class PickupLayout extends StatelessWidget {
  final Widget scaffold;
  final CallMethods callMethods = CallMethods();

  PickupLayout({
    required this.scaffold,
  });

  @override
  Widget build(BuildContext context) {
   var user = appCtrl.storage.read("user");

    // ignore: unnecessary_null_comparison
    return StreamBuilder<DocumentSnapshot>(
            stream: callMethods.callStream(phone: user["phone"]),
            builder: (context, snapshot) {
              if (snapshot.hasData && snapshot.data!.data() != null) {
                Call call = Call.fromMap(
                    snapshot.data!.data() as Map<dynamic, dynamic>);

                if (!call.hasDialled!) {
                  return PickupScreen(
                    call: call,
                    currentuseruid: user["phone"],
                  );
                }
              }
              return scaffold;
            },
          );
  }
}
