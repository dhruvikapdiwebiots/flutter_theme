import 'dart:developer';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'dart:convert';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config.dart';
import '../models/vklm.dart';

class CallFunc extends StatefulWidget {
  final SharedPreferences? prefs;

  const CallFunc({super.key, this.prefs});

  @override
  CallFuncState createState() => CallFuncState();
}

class CallFuncState extends State<CallFunc> {
  bool isLoading = false;
  SharedPreferences? prefs;
  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

  bool isDocHave = false, isCheckAK = true;
  DocumentSnapshot<Map<String, dynamic>>? doc, uc;
  String sV1 = "", sV2 = "", sV3 = "", sV4 = "", sV5 = "", sV6 = "", sV7 = "";

  String k20 = fonts.codeBase;
  String k21 = fonts.akCodeBase64Id;
  String k22 = fonts.akCodeBaseLink;
  String k27 = a2V5;
  bool isA1 = false, isA2 = false, isA3 = false, isA4 = false;

  initialise() async {
    prefs = widget.prefs;
    doc = await rm;
    uc = await uct;
log("R< :${k64(collectionName.nkfig)}");setState(() {});
await Future.delayed(DurationClass.s1);
isDocHave =true;
setState(() {

});
    if (isDRP()) {
      await a25.then((mn) async {
        if (mn.exists) {
          final docHae = mn.data();

          List list = docHae!.keys.toList();

          list.asMap().entries.forEach((a) {
            if (a.key == 0) {
              isA1 = ak76(k21) == ak76(a.value);
            }
            if (a.key == 1) {
              isA2 = ak76(k20) == ak76(a.value);
            }
            if (a.key == 2) {
              isA3 = ak76(k22) == ak76(a.value);
            }
            if (a.key == 3) {
              isA4 = ak76(k27) == ak76(a.value);
            }
          });

          setState(() {});

          if (isA1) {
            if (isA2) {
              if (isA3) {
                if (isA4) {

                  doc = await rm;
                  uc = await uct;
await Future.delayed(DurationClass.s2);
                  setState(() {});
                  isDocHave = true;
                  isCheckAK = false;
                } else {
                  setState(() {
                    isDocHave = false;
                    isCheckAK = false;
                  });
                }
              } else {
                setState(() {
                  isDocHave = false;
                  isCheckAK = false;
                });
              }
            } else {
              setState(() {
                isDocHave = false;
                isCheckAK = false;
              });
            }
          } else {
            setState(() {
              isDocHave = false;
              isCheckAK = false;
            });
          }
        } else {
          setState(() {
            isDocHave = false;
            isCheckAK = false;
          });
        }
      }).catchError((onError) async {
        isCheckAK = false;
        setState(() {});
        if (happens(onError)) {
          isDocHave = false;
          flutterAlertMessage(msg: onError.message);
          setState(() {});
        }
      });
    }

    setState(() {});
  }

  @override
  void initState() {
    initialise();

    super.initState();
  }

  FirebaseApp? app = Firebase.app();

  dest2(String c, String sk3, String sk4) async {
    final dio = Dio();
    isLoading = true;
    setState(() {});

    String k98 = app!.options.projectId;

    String k10 = k64(fonts.codeBase);
    String k11 = k64(fonts.akCodeBase64Id);
    String k12 = k64(fonts.akCodeBaseLink);
    String k13 = k64(c);
    String k14 = k64(sk3);
    String k15 = k64(sk4);
    String k16 = k64(fonts.akCodeBaseLink24);
    String k17 = k64(a2V5);
    var data = {k17: k13, k10: k14, k11: k15, k12: k98};
    log("DATA :$data");
    try {
      var response = await dio.post(k16, data: data);
      log("response :$response");
      if (response.statusCode == 200) {
        //get response
        var responseData = response.data;
        sV2 = a2V5;
        sV1 = fonts.codeBase;
        sV6 = fonts.akCodeBase64Id;
        sV3 = fonts.akCodeBaseLink;

        await r25.set({sV2: c, sV1: k15, sV6: sk4, sV3: ak76(k98)}).then((v) {
          isLoading = false;
          setState(() {});
        }).catchError((onError) async {
          isCheckAK = false;
          setState(() {});
          if (happens(onError)) {
            isDocHave = false;
            flutterAlertMessage(msg: onError.message);
            setState(() {});
          }
        });
        successSheet(prefs, doc, uc)!;
      } else {
        isLoading = false;
        setState(() {});
      }
    } catch (e) {
      isLoading = false;
      setState(() {});
      if (e is DioException) {
        if (e.type == DioExceptionType.badResponse) {
          final response = e.response;
          if (response != null && response.data != null) {
            flutterAlertMessage(msg: response.data['message']);
          }
        } else {
          final response = e.response;
          if (response != null && response.data != null) {
            final Map responseData =
                json.decode(response.data as String) as Map;
            flutterAlertMessage(msg: responseData['message']);
          }
        }
      }
    }
  }

  final _controller = TextEditingController();
  final userName = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    var h = MediaQuery.of(this.context).size.height;
    return /*!isDocHave
        ? isLoading
            ? Center(
                child: CircularProgressIndicator(),
              )
            : Scaffold(
                backgroundColor: appCtrl.appTheme.bgColor,
                appBar: AppBar(
                  centerTitle: true,
                  title: Text(fonts.checkLicense.tr,
                      style: AppCss.poppinsBold20
                          .textColor(appCtrl.appTheme.primary)),
                  backgroundColor: appCtrl.appTheme.bgColor,
                  elevation: 0,
                  automaticallyImplyLeading: false,
                ),
                body: Center(
                  child: ListView(
                    padding: const EdgeInsets.all(20),
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.fromLTRB(0, h / 10, 0, h / 8),
                        child: Column(
                          children: [
                            Text(
                              fonts.linkApp.tr,
                              textAlign: TextAlign.center,
                              style: AppCss.poppinsMedium18
                                  .textColor(appCtrl.appTheme.txt)
                                  .textHeight(1.5),
                            ),
                            const VSpace(Sizes.s20),
                          ],
                        ),
                      ),
                      Form(
                        key: _formKey,
                        child: Container(
                          padding: const EdgeInsets.fromLTRB(15, 17, 15, 15),
                          decoration: ShapeDecoration(
                            color: appCtrl.appTheme.white,
                            shape: SmoothRectangleBorder(
                              side:
                                  BorderSide(color: appCtrl.appTheme.lightGray),
                              borderRadius: SmoothBorderRadius(
                                  cornerRadius: 12, cornerSmoothing: 1),
                            ),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(fonts.pastePurchaseCode.tr,
                                  textAlign: TextAlign.center,
                                  style: AppCss.poppinsBold16
                                      .textColor(appCtrl.appTheme.primary)),
                              const VSpace(Sizes.s20),
                              *//* const Text(
                                'Paste Purchase Code',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 16.7,
                                    color: Colors.black87),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              TextFormField(
                                controller: userName,
                                decoration: InputDecoration(
                                  fillColor: Colors.blueGrey.withOpacity(0.06),
                                  filled: true,
                                  contentPadding:
                                      const EdgeInsets.fromLTRB(10, 5, 10, 4),
                                  hintText: 'Codecanyon Username',
                                  hintStyle: TextStyle(
                                      color: Colors.blueGrey.withOpacity(0.2)),
                                  focusedBorder: const OutlineInputBorder(
                                    borderSide: BorderSide(width: 1.4),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Colors.blueGrey.withOpacity(0.2),
                                        width: 1.4),
                                  ),
                                ),
                                validator: (text) {
                                  if (text == null || text.isEmpty) {
                                    return 'Can\'t be empty';
                                  }

                                  return null;
                                },
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              TextFormField(
                                controller: _controller,
                                decoration: InputDecoration(
                                  fillColor: Colors.blueGrey.withOpacity(0.06),
                                  filled: true,
                                  contentPadding:
                                      const EdgeInsets.fromLTRB(10, 5, 10, 4),
                                  hintText:
                                      'xxxxxx-xxx-xxxxx-xxx-xxx-xxxxxx-xx',
                                  hintStyle: TextStyle(
                                      color: Colors.blueGrey.withOpacity(0.2)),
                                  focusedBorder: const OutlineInputBorder(
                                    borderSide: BorderSide(width: 1.4),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Colors.blueGrey.withOpacity(0.2),
                                        width: 1.4),
                                  ),
                                ),
                                validator: (text) {
                                  if (text == null || text.isEmpty) {
                                    return 'Can\'t be empty';
                                  }
                                  if (text.length < 4) {
                                    return 'Too short';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(
                                height: 20,
                              ),*//*
                              Text(
                                fonts.userName.tr,
                                style: AppCss.poppinsMedium15
                                    .textColor(appCtrl.appTheme.blackColor),
                              ),
                              const VSpace(Sizes.s8),
                              CommonTextBox(
                                controller: userName,
                                textInputAction: TextInputAction.next,
                                labelText: "Codecanyon Username",
                                keyboardType: TextInputType.text,
                                border: OutlineInputBorder(
                                    borderSide: BorderSide.none,
                                    borderRadius:
                                        BorderRadius.circular(AppRadius.r8)),
                                filled: true,
                                fillColor:
                                    const Color.fromRGBO(153, 158, 166, .1),
                                validator: (val) {
                                  if (val == null || val.isEmpty) {
                                    return 'Can\'t be empty';
                                  }

                                  return null;
                                },
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: Insets.i16,
                                    vertical: Insets.i16),
                              ),
                              const VSpace(Sizes.s28),
                              //email text box
                              Text(
                                fonts.purchaseCode.tr,
                                style: AppCss.poppinsMedium15
                                    .textColor(appCtrl.appTheme.blackColor),
                              ),
                              const VSpace(Sizes.s8),
                              CommonTextBox(
                                controller: _controller,
                                textInputAction: TextInputAction.next,

                                labelText:  'xxxxxx-xxx-xxxxx-xxx-xxx-xxxxxx-xx',
                                keyboardType: TextInputType.text,
                                border: OutlineInputBorder(
                                    borderSide: BorderSide.none,
                                    borderRadius:
                                        BorderRadius.circular(AppRadius.r8)),
                                filled: true,
                                fillColor:
                                    const Color.fromRGBO(153, 158, 166, .1),
                                validator: (text) {
                                  if (text == null || text.isEmpty) {
                                    return 'Can\'t be empty';
                                  }
                                  if (text.length < 4) {
                                    return 'Too short';
                                  }
                                  return null;
                                },
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: Insets.i16,
                                    vertical: Insets.i16),
                              ),
                              const VSpace(Sizes.s40),
                              CommonButton(
                                title: fonts.checkLicense.tr,
                                margin: 0,
                                style: AppCss.poppinsMedium14
                                    .textColor(appCtrl.appTheme.white),
                                onTap: () {
                                  if (_formKey.currentState!.validate()) {
                                    print(
                                        "dhfjsdgh : ${_controller.text.length}");
                                    if (_controller.text.isNotEmpty &&
                                        (_controller.text.trim().length == 36 ||
                                            _controller.text.trim().length ==
                                                23)) {
                                      dest2(
                                          ak76(_controller.text),
                                          ak76(userName.text),
                                          ak76(fonts.fontSizeKey));
                                    } else {
                                      flutterAlertMessage(
                                          msg:
                                              'Please enter valid 36 length or 23 length code');
                                    }
                                  }
                                },
                              ),

                              const SizedBox(height: 7),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
        : */isDocHave?  Splash(
            pref: prefs!,
            rm: doc,
            uc: uc,
          ):Container();
  }

  String reverse(String string) {
    if (string.length < 2) {
      return string;
    }

    final characters = Characters(string);
    return characters.toList().reversed.join();
  }
}
