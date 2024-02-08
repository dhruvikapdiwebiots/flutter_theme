import 'dart:developer';
import 'dart:io';

import 'package:flutter_theme/controllers/fetch_contact_controller.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../config.dart';
import '../../../controllers/recent_chat_controller.dart';

class FetchContact extends StatefulWidget {
  final SharedPreferences? prefs;
  final PhotoUrl? message;

  const FetchContact({super.key, this.prefs, this.message});

  @override
  State<FetchContact> createState() => _FetchContactState();
}

class _FetchContactState extends State<FetchContact> {
  //final contactCtrl = Get.find<FetchContactController>();
  final scrollController = ScrollController();
  int inviteContactsCount = 30;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    scrollController.addListener(scrollListener);
  }

  String? sharedSecret;
  String? privateKey;

  void scrollListener() {
    if (scrollController.offset >=
            scrollController.position.maxScrollExtent / 2 &&
        !scrollController.position.outOfRange) {
      setStateIfMounted(() {
        inviteContactsCount = inviteContactsCount + 250;
      });
    }
  }

  void setStateIfMounted(f) {
    if (mounted) setState(f);
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<FetchContactController>(
        builder: (context, registerAvailableContact, child) {
      return Consumer<RecentChatController>(
          builder: (context, recentChat, child) {
        return Scaffold(
            backgroundColor: appCtrl.appTheme.bgColor,
            appBar: AppBar(
                automaticallyImplyLeading: false,
                leadingWidth: Sizes.s80,
                toolbarHeight: Sizes.s80,
                elevation: 0,
                backgroundColor: appCtrl.appTheme.bgColor,
                title: Text(fonts.contact.tr,
                    style: AppCss.poppinsMedium16
                        .textColor(appCtrl.appTheme.primary)),
                centerTitle: true,
                actions: [
                  const Icon(Icons.sync)
                      .paddingSymmetric(
                          horizontal: Insets.i10, vertical: Insets.i10)
                      .decorated(
                          borderRadius: BorderRadius.circular(AppRadius.r10),
                          boxShadow: [
                            const BoxShadow(
                                offset: Offset(0, 2),
                                blurRadius: 5,
                                spreadRadius: 1,
                                color: Color.fromRGBO(0, 0, 0, 0.08))
                          ],
                          color: appCtrl.appTheme.whiteColor)
                      .marginSymmetric(
                          horizontal: Insets.i20, vertical: Insets.i20)
                      .inkWell(onTap: () async {
                    bool per =
                        appCtrl.storage.read(session.contactPermission) ??
                            false;
                    Fluttertoast.showToast(msg: "Loading..");
                    if (per) {
                      final FetchContactController registerAvailableContact =
                          Provider.of<FetchContactController>(Get.context!,
                              listen: false);
                      debugPrint("INIT PAGE");
                      registerAvailableContact.fetchContacts(
                          Get.context!, appCtrl.user["phone"], widget.prefs!, true);
                    } else {
                      contactPermission(widget.prefs!);
                    }
                  }),
                ],
                leading: const BackIcon()),
            body: registerAvailableContact.searchContact == true
                ? loading()
                : registerAvailableContact.registerContactUser.isNotEmpty &&
                        registerAvailableContact.contactList!.isNotEmpty
                    ? RefreshIndicator(
                        onRefresh: () async {
                          bool per =
                              appCtrl.storage.read(session.contactPermission) ??
                                  false;
                          Fluttertoast.showToast(msg: "Loading..");
                          if (per) {
                            final FetchContactController registerAvailableContact =
                            Provider.of<FetchContactController>(Get.context!,
                                listen: false);
                            debugPrint("INIT PAGE");
                            registerAvailableContact.fetchContacts(
                                Get.context!, appCtrl.user["phone"],widget.prefs!, true);
                          } else {
                            contactPermission(widget.prefs!);
                          }
                        },
                        child: ListView(
                          controller: scrollController,
                          padding: const EdgeInsets.only(bottom: 15, top: 0),
                          physics: const BouncingScrollPhysics(),
                          children: [

                            Row(
                              children: [
                                Container(
                                  height: Sizes.s40,
                                  width: Sizes.s40,
                                  decoration: BoxDecoration(
                                    color: appCtrl.appTheme.borderGray.withOpacity(.6),
                                    shape: BoxShape.circle,
                                    image: DecorationImage(
                                      image: AssetImage(imageAssets.user)
                                    )
                                  ),
                                ),
                                const HSpace(Sizes.s20),
                                Text(fonts.addContact.tr,style: AppCss.poppinsMedium16.textColor(appCtrl.appTheme.txt),),
                              ],
                            ).marginSymmetric(horizontal: Insets.i20).inkWell(onTap: (){
                              Get.toNamed(routeName.addContact)!.then((value) {
                                Fluttertoast.showToast(msg: "Contact Sync..");
                                return registerAvailableContact.fetchContacts(context,
                                    appCtrl.user["phone"], widget.prefs!, true);
                              });
                            }),
                            const VSpace(Sizes.s10),
                            Divider(indent: 20,endIndent: 20,color: appCtrl.appTheme.lightGray,),
                            const VSpace(Sizes.s10),
                            registerAvailableContact.registerContactUser.isEmpty
                                ? const SizedBox(
                                    height: 0,
                                  )
                                : Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: Insets.i20),
                                        child: Text(fonts.registerUser.tr,
                                            style: AppCss.poppinsSemiBold14
                                                .textColor(appCtrl
                                                    .appTheme.blackColor)))
                                    .paddingOnly(top: Insets.i10),
                            registerAvailableContact.registerContactUser.isEmpty
                                ? const SizedBox(
                                    height: 0,
                                  )
                                : ListView.builder(
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    padding: const EdgeInsets.all(00),
                                    itemCount: registerAvailableContact
                                        .registerContactUser.length,
                                    itemBuilder: (context, idx) {
                                      RegisterContactDetail user =
                                          registerAvailableContact
                                              .registerContactUser
                                              .elementAt(idx);

                                      String phone = user.phone!;
                                      String name = user.name ?? user.phone!;
                                      return phone != appCtrl.user["phone"]
                                          ? FutureBuilder<UserData?>(
                                              future: registerAvailableContact
                                                  .getUserDataFromStorageAndFirebase(
                                                      widget.prefs ??
                                                          appCtrl.pref!,
                                                      phone),
                                              builder: (BuildContext context,
                                                  AsyncSnapshot<UserData?>
                                                      snapshot) {
                                                if (snapshot.hasData &&
                                                    snapshot.data != null) {
                                                  return ListTile(
                                                    leading: CachedNetworkImage(
                                                        imageUrl: snapshot
                                                            .data!.photoURL,
                                                        imageBuilder: (context, imageProvider) => CircleAvatar(
                                                            backgroundColor:
                                                                const Color(
                                                                    0xffE6E6E6),
                                                            radius: Sizes.s20,
                                                            backgroundImage:
                                                                imageProvider),
                                                        placeholder: (context, url) => const CircleAvatar(
                                                            backgroundColor: Color(
                                                                0xffE6E6E6),
                                                            radius: Sizes.s20,
                                                            child: Icon(Icons.person,
                                                                color: Color(
                                                                    0xffCCCCCC))),
                                                        errorWidget: (context, url, error) =>
                                                            const CircleAvatar(
                                                                backgroundColor: Color(0xffE6E6E6),
                                                                radius: AppRadius.r20,
                                                                child: Icon(Icons.person, color: Color(0xffCCCCCC)))),
                                                    title: Text(
                                                      snapshot.data!.name,
                                                    ),
                                                    subtitle: Text(
                                                      snapshot.data!.aboutUser,
                                                    ),
                                                    contentPadding:
                                                        const EdgeInsets
                                                            .symmetric(
                                                            horizontal: 22.0,
                                                            vertical: 0.0),
                                                    onTap: () async {
                                                      final RecentChatController
                                                          recentChatController =
                                                          Provider.of<
                                                                  RecentChatController>(
                                                              Get.context!,
                                                              listen: false);
                                                      log("INIT PAGE : ${recentChatController.userData.length}");
                                                      bool isEmpty =
                                                          recentChatController
                                                              .userData
                                                              .where((element) {
                                                        return element["receiverId"] ==
                                                                    appCtrl.user[
                                                                        "id"] &&
                                                                element["senderId"] ==
                                                                    snapshot
                                                                        .data!
                                                                        .id ||
                                                            element["senderId"] ==
                                                                    appCtrl.user[
                                                                        "id"] &&
                                                                element["receiverId"] ==
                                                                    snapshot
                                                                        .data!
                                                                        .id;
                                                      }).isEmpty;
                                                      log("isEmpty : $isEmpty");
                                                      if (!isEmpty) {
                                                        int index = recentChatController.userData.indexWhere((element) =>
                                                            element["receiverId"] ==
                                                                    appCtrl.user[
                                                                        "id"] &&
                                                                element["senderId"] ==
                                                                    snapshot
                                                                        .data!
                                                                        .id ||
                                                            element["senderId"] ==
                                                                    appCtrl.user[
                                                                        "id"] &&
                                                                element["receiverId"] ==
                                                                    snapshot
                                                                        .data!
                                                                        .id);
                                                        UserContactModel userContact =
                                                            UserContactModel(
                                                                username:
                                                                    snapshot
                                                                        .data!
                                                                        .name,
                                                                uid: snapshot
                                                                    .data!.id,
                                                                phoneNumber: snapshot
                                                                    .data!
                                                                    .idVariants,
                                                                image: snapshot
                                                                    .data!
                                                                    .photoURL,
                                                                isRegister:
                                                                    true);

                                                        if (widget.message ==
                                                            null) {
                                                          var data = {
                                                            "chatId":
                                                                recentChatController
                                                                            .userData[
                                                                        index]
                                                                    ["chatId"],
                                                            "data": userContact
                                                          };

                                                          Get.back();
                                                          Get.toNamed(
                                                              routeName.chat,
                                                              arguments: data);
                                                        } else {
                                                          var data = {
                                                            "chatId":
                                                                recentChatController
                                                                            .userData[
                                                                        index]
                                                                    ["chatId"],
                                                            "data": userContact,
                                                            "message":
                                                                widget.message,
                                                          };

                                                          Get.back();
                                                          Get.toNamed(
                                                            routeName.chat,
                                                            arguments: data,
                                                          );
                                                        }
                                                      } else {
                                                        UserContactModel userContact =
                                                            UserContactModel(
                                                                username:
                                                                    snapshot
                                                                        .data!
                                                                        .name,
                                                                uid: snapshot
                                                                    .data!.id,
                                                                phoneNumber: snapshot
                                                                    .data!
                                                                    .idVariants,
                                                                image: snapshot
                                                                    .data!
                                                                    .photoURL,
                                                                isRegister:
                                                                    true);
                                                        if (widget.message ==
                                                            null) {
                                                          var data = {
                                                            "chatId": "0",
                                                            "data": userContact,
                                                          };
                                                          Get.back();
                                                          Get.toNamed(
                                                              routeName.chat,
                                                              arguments: data);
                                                        } else {
                                                          var data = {
                                                            "chatId": "0",
                                                            "data": userContact,
                                                            "message":
                                                                widget.message,
                                                          };
                                                          Get.back();
                                                          Get.toNamed(
                                                              routeName.chat,
                                                              arguments: data);
                                                        }
                                                        //
                                                        final chatCtrl = Get
                                                                .isRegistered<
                                                                    ChatController>()
                                                            ? Get.find<
                                                                ChatController>()
                                                            : Get.put(
                                                                ChatController());
                                                        chatCtrl.onReady();
                                                      }
                                                    },
                                                  );
                                                }
                                                return ListTile(
                                                  leading: const CircleAvatar(
                                                      radius: 22),
                                                  title: Text(
                                                    name,
                                                  ),
                                                  contentPadding:
                                                      const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 22.0,
                                                          vertical: 0.0),
                                                );
                                              },
                                            )
                                          : Container();
                                    },
                                  ),
                            if (widget.message == null)
                              Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: Insets.i20),
                                      child: Text(fonts.inviteUser.tr,
                                          style: AppCss.poppinsSemiBold14
                                              .textColor(
                                                  appCtrl.appTheme.blackColor)))
                                  .paddingOnly(top: Insets.i10),
                            if (widget.message == null)
                              ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                padding: const EdgeInsets.all(0),
                                itemCount: inviteContactsCount >=
                                        registerAvailableContact
                                            .contactList!.length
                                    ? registerAvailableContact
                                        .contactList!.length
                                    : inviteContactsCount,
                                itemBuilder: (context, idx) {
                                  MapEntry user = registerAvailableContact
                                      .contactList!.entries
                                      .elementAt(idx);
                                  String phone = user.key;
                                  return registerAvailableContact.oldPhoneData
                                              .indexWhere((element) =>
                                                  element.phone == phone) >=
                                          0
                                      ? Container(
                                          width: 0,
                                        )
                                      : Stack(
                                          children: [
                                            ListTile(
                                              leading: CircleAvatar(
                                                  radius: Sizes.s20,
                                                  child: Text(
                                                    registerAvailableContact
                                                        .getInitials(
                                                            user.value),
                                                  )),
                                              title: Text(
                                                user.value,
                                              ),
                                              contentPadding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 22.0,
                                                      vertical: 0.0),
                                            ),
                                            Positioned(
                                              right: 19,
                                              bottom: 19,
                                              child: InkWell(
                                                  onTap: () {
                                                    if (Platform.isAndroid) {
                                                      Share.share(
                                                          " 'Download the ChatBox App'");
                                                    }
                                                  },
                                                  child: const Icon(
                                                    Icons.person_add_alt,
                                                  )),
                                            )
                                          ],
                                        );
                                },
                              ),
                          ],
                        ),
                      )
                    : Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "NO CONTACTS AVAILABLE",
                              style: AppCss.poppinsMedium16
                                  .textColor(appCtrl.appTheme.txt),
                            ),
                            const VSpace(Sizes.s20),
                            CommonButton(
                              title: fonts.syncNow.tr,
                              style: AppCss.poppinsMedium14
                                  .textColor(appCtrl.appTheme.white),
                              onTap: () {
                                registerAvailableContact.setIsLoading(true);
                                contactPermission(widget.prefs!);
                              },
                            )
                          ],
                        ),
                      ));
      });
    });
  }

  loading() {
    return Stack(children: [
      Center(
          child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(appCtrl.appTheme.primary),
      ))
    ]);
  }
}
