//*************   © Copyrighted by Thinkcreative_Technologies. An Exclusive item of Envato market. Make sure you have purchased a Regular License OR Extended license for the Source Code from Envato to use this product. See the License Defination attached with source code. *********************


import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../models/call_model.dart';
import 'call_firebase_method.dart';

// ignore: must_be_immutable
class PickupScreen extends StatelessWidget {
  final Call call;
  final String? currentuseruid;
  final CallMethods callMethods = CallMethods();

  PickupScreen({
    required this.call,
    required this.currentuseruid,
  });
  ClientRoleType _role = ClientRoleType.clientRoleBroadcaster;
  @override
  Widget build(BuildContext context) {
    var w = MediaQuery.of(context).size.width;
    var h = MediaQuery.of(context).size.height;

    return Scaffold(

        body: Container(
          alignment: Alignment.center,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                alignment: Alignment.center,
                margin: EdgeInsets.only(
                    top: MediaQuery.of(context).padding.top),

                height: h / 4,
                width: w,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      height: 7,
                    ),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          call.isVideoCall == true
                              ? Icons.videocam
                              : Icons.mic_rounded,
                          size: 40,

                        ),
                        SizedBox(
                          width: 7,
                        ),
                        Text(
                          call.isVideoCall == true
                              ? 'incomingvideo'
                              : 'incomingaudio',
                          style: TextStyle(
                              fontSize: 18.0,

                              fontWeight: FontWeight.w400),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: h / 9,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(height: 7),
                          SizedBox(
                            width:
                            MediaQuery.of(context).size.width / 1.1,
                            child: Text(
                              call.callerName!,
                              maxLines: 1,
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontWeight: FontWeight.w500,

                                fontSize: 27,
                              ),
                            ),
                          ),
                          SizedBox(height: 7),
                          Text(
                            call.callerId!,
                            style: TextStyle(
                              fontWeight: FontWeight.normal,

                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // SizedBox(height: h / 25),

                    SizedBox(
                      height: 10,
                    ),
                  ],
                ),
              ),
              call.callerPic == null || call.callerPic == ''
                  ? Container(
                height: w + (w / 140),
                width: w,
                color: Colors.white12,
                child: Icon(
                  Icons.person,
                  size: 140,

                ),
              )
                  : Stack(
                children: [
                  Container(
                      height: w + (w / 140),
                      width: w,
                      color: Colors.white12,
                      child: CachedNetworkImage(
                        imageUrl: call.callerPic!,
                        fit: BoxFit.cover,
                        height: w + (w / 140),
                        width: w,
                        placeholder: (context, url) => Center(
                            child: Container(
                              height: w + (w / 140),
                              width: w,
                              color: Colors.white12,
                              child: Icon(
                                Icons.person,
                                size: 140,

                              ),
                            )),
                        errorWidget: (context, url, error) =>
                            Container(
                              height: w + (w / 140),
                              width: w,
                              color: Colors.white12,
                              child: Icon(
                                Icons.person,
                                size: 140,

                              ),
                            ),
                      )),
                  Container(
                    height: w + (w / 140),
                    width: w,
                    color: Colors.black.withOpacity(0.18),
                  ),
                ],
              ),
              Container(
                height: h / 6,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    RawMaterialButton(
                      onPressed: () async {

                      },
                      child: Icon(
                        Icons.call_end,
                        color: Colors.white,
                        size: 35.0,
                      ),
                      shape: CircleBorder(),
                      elevation: 2.0,
                      fillColor: Colors.redAccent,
                      padding: const EdgeInsets.all(15.0),
                    ),
                    SizedBox(width: 45),
                    RawMaterialButton(
                      onPressed: () async {

                      },
                      child: Icon(
                        Icons.call,
                        color: Colors.white,
                        size: 35.0,
                      ),
                      shape: CircleBorder(),
                      elevation: 2.0,
                      fillColor: Colors.green[400],
                      padding: const EdgeInsets.all(15.0),
                    )
                  ],
                ),
              ),
            ],
          ),
        ));
  }
}
