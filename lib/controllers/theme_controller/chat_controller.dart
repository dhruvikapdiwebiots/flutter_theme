import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_theme/config.dart';
import 'package:fluttercontactpicker/fluttercontactpicker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:video_player/video_player.dart';

enum MessageType { text, image, video, doc, location, contact, audio }

enum _PositionItemType {
  log,
  position,
}

class _PositionItem {
  _PositionItem(this.type, this.displayValue);

  final _PositionItemType type;
  final String displayValue;
}

class ChatController extends GetxController {
  String? pId, id, pName, groupId, imageUrl, peerNo;
  dynamic message;
  static const String _kLocationServicesDisabledMessage =
      'Location services are disabled.';
  static const String _kPermissionDeniedMessage = 'Permission denied.';
  static const String _kPermissionDeniedForeverMessage =
      'Permission denied forever.';
  static const String _kPermissionGrantedMessage = 'Permission granted.';

  final GeolocatorPlatform _geolocatorPlatform = GeolocatorPlatform.instance;
  final List<_PositionItem> _positionItems = <_PositionItem>[];
  StreamSubscription<Position>? _positionStreamSubscription;
  StreamSubscription<ServiceStatus>? _serviceStatusStreamSubscription;
  bool positionStreamStarted = false;
  XFile? imageFile;
  bool? isLoading;

  final GeolocatorPlatform geoLocatorPlatform = GeolocatorPlatform.instance;

  TextEditingController textEditingController = TextEditingController();
  ScrollController listScrollController = ScrollController();
  FocusNode focusNode = FocusNode();

  @override
  void onReady() {
    // TODO: implement onReady
    groupId = '';
    isLoading = false;
    imageUrl = '';
    var data = Get.arguments;
    pId = data["pId"];
    pName = data["pName"];
    readLocal();

    update();
    super.onReady();
  }

//read local data
  readLocal() async {
    id = appCtrl.storage.read('id') ?? '';
    if (id.hashCode <= pId.hashCode) {
      groupId = '$id-$pId';
    } else {
      groupId = '$pId-$id';
    }
    FirebaseFirestore.instance
        .collection(
            'users') // Your collection name will be whatever you have given in firestore database
        .doc(id)
        .update({'chattingWith': pId});
    update();
  }

// FOR Dismiss KEYBOARD
  void dismissKeyboard() {
    FocusScope.of(Get.context!).requestFocus(FocusNode());
  }

  //share media
  shareMedia(BuildContext context) {
    showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
          borderRadius:
              BorderRadius.vertical(top: Radius.circular(AppRadius.r25)),
        ),
        builder: (BuildContext context) {
          // return your layout
          return Container(
            padding: const EdgeInsets.all(12),
            height: 250,
            child: Column(children: [
              const SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width / 3.27,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        RawMaterialButton(
                          disabledElevation: 0,
                          onPressed: () async {
                            dismissKeyboard();
                            Get.back();
                            FilePickerResult? result =
                                await FilePicker.platform.pickFiles();
                            print("result: ${result!.files.single.name}");
                            if (result != null) {
                              File file =
                                  File(result.files.single.path.toString());
                              print(file);
                              String fileName = DateTime.now()
                                  .millisecondsSinceEpoch
                                  .toString();
                              Reference reference = FirebaseStorage.instance
                                  .ref()
                                  .child(fileName);
                              UploadTask uploadTask = reference.putFile(file);
                              uploadTask.then((res) {
                                res.ref.getDownloadURL().then((downloadUrl) {
                                  imageUrl = downloadUrl;
                                  isLoading = false;
                                  onSendMessage(
                                      "${result.files.single.name}-BREAK-$imageUrl",
                                      result.files.single.path
                                              .toString()
                                              .contains(".mp4")
                                          ? MessageType.video
                                          : result.files.single.path
                                                  .toString()
                                                  .contains(".mp3")
                                              ? MessageType.audio
                                              : MessageType.doc);
                                  update();
                                }, onError: (err) {
                                  isLoading = false;
                                  update();
                                  Fluttertoast.showToast(msg: 'Not Upload');
                                });
                              });
                            }
                          },
                          elevation: .5,
                          fillColor: Colors.indigo,
                          padding: const EdgeInsets.all(15.0),
                          shape: const CircleBorder(),
                          child: const Icon(
                            Icons.file_copy,
                            size: 25.0,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(
                          height: 8,
                        ),
                        Text(
                          "Documents",
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style:
                              TextStyle(color: Colors.grey[700], fontSize: 14),
                        )
                      ],
                    ),
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width / 3.27,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        RawMaterialButton(
                          disabledElevation: 0,
                          onPressed: () {
                            dismissKeyboard();
                            Get.back();
                          },
                          elevation: .5,
                          fillColor: Colors.pink[600],
                          padding: const EdgeInsets.all(15.0),
                          shape: const CircleBorder(),
                          child: const Icon(
                            Icons.video_collection_sharp,
                            size: 25.0,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(
                          height: 8,
                        ),
                        Text(
                          "video",
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style:
                              TextStyle(color: Colors.grey[700], fontSize: 14),
                        )
                      ],
                    ),
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width / 3.27,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        RawMaterialButton(
                          disabledElevation: 0,
                          onPressed: () {
                            Get.back();
                            imagePickerOption(Get.context!);
                          },
                          elevation: .5,
                          fillColor: Colors.purple,
                          padding: const EdgeInsets.all(15.0),
                          shape: const CircleBorder(),
                          child: const Icon(
                            Icons.image_rounded,
                            size: 25.0,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(
                          height: 8,
                        ),
                        Text(
                          "image",
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style:
                              TextStyle(color: Colors.grey[700], fontSize: 14),
                        )
                      ],
                    ),
                  )
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width / 3.27,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        RawMaterialButton(
                          disabledElevation: 0,
                          onPressed: () {
                            dismissKeyboard();
                            Get.back();

                          },
                          elevation: .5,
                          fillColor: Colors.yellow[900],
                          padding: const EdgeInsets.all(15.0),
                          shape: const CircleBorder(),
                          child: const Icon(
                            Icons.mic_rounded,
                            size: 25.0,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(
                          height: 8,
                        ),
                        Text(
                          'audio',
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: Colors.grey[700]),
                        )
                      ],
                    ),
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width / 3.27,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        RawMaterialButton(
                          disabledElevation: 0,
                          onPressed: () async {
                            dismissKeyboard();
                            Get.back();
                            await getCurrentPosition().then((value) async {
                              var locationString =
                                  'https://www.google.com/maps/search/?api=1&query=${value.latitude},${value.longitude}';
                              onSendMessage(
                                  locationString, MessageType.location);
                            });
                          },
                          elevation: .5,
                          fillColor: Colors.cyan[700],
                          padding: const EdgeInsets.all(15.0),
                          shape: const CircleBorder(),
                          child: const Icon(
                            Icons.location_on,
                            size: 25.0,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(
                          height: 8,
                        ),
                        Text(
                          'location',
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: Colors.grey[700]),
                        )
                      ],
                    ),
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width / 3.27,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        RawMaterialButton(
                          disabledElevation: 0,
                          onPressed: () async {
                            dismissKeyboard();
                            Get.back();
                            saveContactInChat();
                          },
                          elevation: .5,
                          fillColor: Colors.blue[800],
                          padding: const EdgeInsets.all(15.0),
                          shape: const CircleBorder(),
                          child: const Icon(
                            Icons.person,
                            size: 25.0,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(
                          height: 8,
                        ),
                        Text(
                          'contact',
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: Colors.grey[700]),
                        )
                      ],
                    ),
                  )
                ],
              ),
            ]),
          );
        });
  }

// GET IMAGE FROM GALLERY
  Future getImage(source) async {
    final ImagePicker picker = ImagePicker();
    imageFile = (await picker.pickImage(source: source))!;
    if (imageFile != null) {
      isLoading = true;
      update();
      uploadFile();
    }
  }

// UPLOAD SELECTED IMAGE TO FIREBASE
  Future uploadFile() async {
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    Reference reference = FirebaseStorage.instance.ref().child(fileName);
    var file = File(imageFile!.path);
    UploadTask uploadTask = reference.putFile(file);
    uploadTask.then((res) {
      res.ref.getDownloadURL().then((downloadUrl) {
        imageUrl = downloadUrl;
        isLoading = false;
        onSendMessage(imageUrl!, MessageType.image);
        update();
      }, onError: (err) {
        isLoading = false;
        update();
        Fluttertoast.showToast(msg: 'Image is Not Valid');
      });
    });
  }

  //pick up contact and share
  saveContactInChat() async {
    // Add your onPressed code here!
    final granted = await FlutterContactPicker.hasPermission();
    if (granted) {
      update();
    } else {
      await FlutterContactPicker.requestPermission().then((value) async {
        update();
      });
    }
    final FullContact contactPick =
        (await FlutterContactPicker.pickFullContact());

    onSendMessage(
        '${contactPick.name!.nickName}-BREAK-${contactPick.phones[0].number}-BREAK-${contactPick.photo!}',
        MessageType.contact);
    update();
  }

  Future<Position> getCurrentPosition() async {
    final hasPermission = await _handlePermission();

    if (!hasPermission) {
      return Geolocator.getCurrentPosition();
    }

    final position = await geoLocatorPlatform.getCurrentPosition();
    _updatePositionList(
      _PositionItemType.position,
      position.toString(),
    );

    return position;
  }

  Future<bool> _handlePermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await geoLocatorPlatform.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      _updatePositionList(
        _PositionItemType.log,
        _kLocationServicesDisabledMessage,
      );

      return false;
    }

    permission = await geoLocatorPlatform.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await geoLocatorPlatform.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        _updatePositionList(
          _PositionItemType.log,
          _kPermissionDeniedMessage,
        );

        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      _updatePositionList(
        _PositionItemType.log,
        _kPermissionDeniedForeverMessage,
      );

      return false;
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    _updatePositionList(
      _PositionItemType.log,
      _kPermissionGrantedMessage,
    );
    return true;
  }

  void _updatePositionList(_PositionItemType type, String displayValue) {
    _positionItems.add(_PositionItem(type, displayValue));
    update();
  }

  // SEND MESSAGE CLICK
  void onSendMessage(String content, MessageType type) async {
    if (content.trim() != '') {
      textEditingController.clear();
      var documentReference = FirebaseFirestore.instance
          .collection('messages')
          .doc(groupId)
          .collection(groupId!)
          .doc(DateTime.now().millisecondsSinceEpoch.toString());

      await FirebaseFirestore.instance.runTransaction((transaction) async {
        transaction.set(
          documentReference,
          {
            'idFrom': id,
            'idTo': pId,
            'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
            'content': content,
            'type': type.name
          },
        );
      });
      listScrollController.animateTo(0.0,
          duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    } else {
      Fluttertoast.showToast(msg: 'Nothing to send');
    }
  }

  Widget buildPopupDialog(
      BuildContext context, DocumentSnapshot documentReference) {
    return DeleteAlert(
      documentReference: documentReference,
    );
  }

// BUILD ITEM MESSAGE BOX FOR RECEIVER AND SENDER BOX DESIGN
  Widget buildItem(int index, DocumentSnapshot document) {
    if (document['idFrom'] == id) {
      return SenderMessage(
        document: document,
        index: index,
      );
    } else {
      // RECEIVER MESSAGE
      return ReceiverMessage(document: document, index: index);
    }
  }

  // CHECK IF IT IS RECEIVER SIDE OR NOT
  bool isLastMessageLeft(int index) {
    /*if ((index > 0 && message != null && message![index - 1]['idFrom'] == id) ||
        index == 0) {
      return true;
    } else {
      return false;
    }*/
    return false;
  }

  // CHECK IF IT IS SENDER SIDE OR NOT
  bool isLastMessageRight(int index) {
    /* if ((index > 0 && message != null && message![index - 1]['idFrom'] != id) ||
        index == 0) {
      return true;
    } else {
      return false;
    }*/
    return false;
  }

  // ON BACKPRESS
  Future<bool> onBackPress() {
    FirebaseFirestore.instance
        .collection(
            'users') // Your collection name will be whatever you have given in firestore database
        .doc(id)
        .update({'chattingWith': null});
    Get.back();
    return Future.value(false);
  }

  imagePickerOption(BuildContext context) {
    showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
          borderRadius:
              BorderRadius.vertical(top: Radius.circular(AppRadius.r25)),
        ),
        builder: (BuildContext context) {
          // return your layout
          return Container(
            padding: const EdgeInsets.all(12),
            height: Sizes.s150,
            alignment: Alignment.bottomCenter,
            child: Column(children: [
              const VSpace(Sizes.s20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width / 3.27,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        RawMaterialButton(
                          disabledElevation: 0,
                          onPressed: () async {
                            Get.back();
                            getImage(ImageSource.camera);
                          },
                          elevation: .5,
                          fillColor: Colors.cyan[700],
                          padding: const EdgeInsets.all(15.0),
                          shape: const CircleBorder(),
                          child: const Icon(
                            Icons.camera,
                            size: 25.0,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(
                          height: 8,
                        ),
                        Text(
                          'Camera',
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: Colors.grey[700]),
                        )
                      ],
                    ),
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width / 3.27,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        RawMaterialButton(
                          disabledElevation: 0,
                          onPressed: () async {
                            getImage(ImageSource.gallery);
                            Get.back();
                          },
                          elevation: .5,
                          fillColor: Colors.blue[800],
                          padding: const EdgeInsets.all(15.0),
                          shape: const CircleBorder(),
                          child: const Icon(
                            Icons.image,
                            size: 25.0,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(
                          height: 8,
                        ),
                        Text(
                          'Gallery',
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: Colors.grey[700]),
                        )
                      ],
                    ),
                  )
                ],
              ),
            ]),
          );
        });
  }
}
