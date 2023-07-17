import 'dart:developer';

import 'package:flutter_theme/config.dart';
import 'package:flutter_theme/models/firebase_contact_model.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

class ContactListController extends GetxController {
  bool isLoading = true;
  static const pageSize = 20;
  final PagingController<int, UserContactModel> pagingController =
      PagingController(firstPageKey: 0);
  ContactModel? registerContact;
  List<UserContactModel> registerList = [], allRegisterList = [];
  List<UserContactModel> unRegisterList = [], allUnRegisterList = [];
  ContactModel? unRegisterContact;
  List<UserContactModel> list = [];

  @override
  void onReady() {
    // TODO: implement onReady
    super.onReady();
  }

  fetchRegisterData(pageKey) async {
    pagingController.itemList = [];

    try {
      final newItems = unRegisterList.isNotEmpty
          ? unRegisterList
          : unRegisterContact!.userTitle;
      final isLastPage = newItems!.length < pageSize;

      if (isLastPage) {
        pagingController.appendLastPage(newItems);
      } else {
        final nextPageKey = pageKey + newItems.length;
        pagingController.appendPage(newItems, nextPageKey);
      }
      isLoading = false;
      update();
    } catch (error) {
      pagingController.error = error;
    }
  }

  onSearch(val) async {
    log("CHECK USER : ${registerContact!.userTitle!.length}");
    registerList = [];
    unRegisterList = [];
    registerContact!.userTitle!.asMap().entries.forEach((element) {
      if (element.value.username!.toLowerCase().contains(val)) {
        if (!registerList.contains(element.value)) {
          registerList.add(element.value);
        }
      }
    });
    unRegisterContact!.userTitle!.asMap().entries.forEach((element) {
      if (element.value.username!.toLowerCase().contains(val)) {
        if (!unRegisterList.contains(element.value)) {
          unRegisterList.add(element.value);
        }
      }
    });
    log("unRegisterList : ${unRegisterList.length}");
    update();
    //fetchRegisterData(0);
  }

  getAllData() async {
    List allUserList = [];
    appCtrl.firebaseContact = [];
    await FirebaseFirestore.instance
        .collection(collectionName.users)
        .doc(appCtrl.user["id"])
        .collection(collectionName.registerUser)
        .get()
        .then((snapshot) {
      if (snapshot.docs.isNotEmpty) {

        debugPrint("CONNNN 11: ${appCtrl.firebaseContact.length}");
        allUserList = snapshot.docs[0].data()["contact"];
        debugPrint("allUserList : ${allUserList.length}");
        allUserList.asMap().entries.forEach((element) {
          log("PHONE : ${element.value["phone"]}");
          log("PHONE : ${appCtrl.user["phone"]}");
          if(element.value["phone"] != appCtrl.user["phone"]) {
            if (!appCtrl.firebaseContact.contains(element.value)) {
              appCtrl.firebaseContact
                  .add(FirebaseContactModel.fromJson(element.value));
            }
          }
        });
        List<UserContactModel> register = [];
        debugPrint("CONNNN : ${appCtrl.user}");
        debugPrint("CONNNN : ${FirebaseAuth.instance.currentUser}");
        if (appCtrl.firebaseContact.isNotEmpty) {
          appCtrl.firebaseContact.asMap().entries.forEach((element) async {
            if (element.value.phone != appCtrl.user["phone"]) {
              String image = "", status = "";
              await FirebaseFirestore.instance
                  .collection(collectionName.users)
                  .where("phone", isEqualTo: element.value.phone)
                  .get()
                  .then((value) {
                if (value.docs.isNotEmpty) {
                  image = value.docs[0].data()["image"];
                  status = value.docs[0].data()["status"];

                  UserContactModel userContactModel = UserContactModel(
                    isRegister: true,
                    phoneNumber: element.value.phone,
                    uid: element.value.id,
                    image: image,
                    username: element.value.name,
                    description: status,
                  );
                  if (!register.contains(userContactModel)) {
                    register.add(userContactModel);
                  }
                }
              });
              update();
            }
          });

          allRegisterList = register;
          update();
        }
        update();
      }
    });
  }

  getAllUnRegisterUser() async {
    List allUserList = [];
    appCtrl.firebaseContact = [];
    await FirebaseFirestore.instance
        .collection(collectionName.users)
        .doc(appCtrl.user["id"])
        .collection(collectionName.unRegisterUser)
        .get()
        .then((snapshot) {
      if (snapshot.docs.isNotEmpty) {
        if (registerContact != null && unRegisterContact != null) {
          registerContact!.userTitle = [];
          unRegisterContact!.userTitle = [];
        }
        debugPrint("CONNNNs 11: ${appCtrl.user}");
        debugPrint("CONNNN : ${FirebaseAuth.instance.currentUser}");
        allUserList = snapshot.docs[0].data()["contact"];
        debugPrint("allUserList : ${allUserList.length}");
        allUserList.asMap().entries.forEach((element) {
          if (!appCtrl.firebaseContact.contains(element.value)) {
            appCtrl.firebaseContact
                .add(FirebaseContactModel.fromJson(element.value));
          }
        });
        List<UserContactModel> unRegister = [];
        debugPrint("CONNNN : ${appCtrl.firebaseContact.length}");
        if (appCtrl.firebaseContact.isNotEmpty) {
          appCtrl.firebaseContact.asMap().entries.forEach((element) async {
            UserContactModel userContactModel = UserContactModel(
              isRegister: false,
              phoneNumber: element.value.phone,
              uid: "0",
              contactImage: element.value.photo,
              username: element.value.name,
              description: "",
            );
            if (!unRegister.contains(userContactModel)) {
              unRegister.add(userContactModel);
            }
          });

          allUnRegisterList = unRegister;
          update();
        }
      }
    });
    update();
  }

}
