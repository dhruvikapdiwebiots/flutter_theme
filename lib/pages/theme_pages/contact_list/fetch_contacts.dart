import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_theme/controllers/fetch_contact_controller.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../config.dart';

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
        builder: (context, availableContacts, _child) {
        return Scaffold(
            backgroundColor: appCtrl.appTheme.bgColor,
            appBar: AppBar(
                automaticallyImplyLeading: false,
                leadingWidth: Sizes.s80,
                toolbarHeight: Sizes.s80,
                elevation: 0,
                backgroundColor: appCtrl.appTheme.bgColor,
                title: Text(fonts.contact.tr,
                    style:
                        AppCss.poppinsMedium16.textColor(appCtrl.appTheme.primary)),
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
                      .marginSymmetric(horizontal: Insets.i20, vertical: Insets.i20)
                      .inkWell(onTap: () async {
                    final FetchContactController
                    contactsProvider = Provider.of<
                        FetchContactController>(
                        context,
                        listen: false);

                    contactsProvider.fetchContacts(
                        context,
                        appCtrl.user["phone"],
                        widget.prefs!,
                        true);
                  }),
                ],
                leading: const BackIcon()),
            body: availableContacts.searchingcontactsindatabase == true
                ? loading()
                :RefreshIndicator(
              onRefresh: ()async{
                return availableContacts.fetchContacts(
                    context,
                    appCtrl.user["phone"],
                    widget.prefs!,
                    true);
              },
                  child: ListView(
              controller: scrollController,
              padding: EdgeInsets.only(bottom: 15, top: 0),
              physics: BouncingScrollPhysics(),
              children: [
                  availableContacts
                      .alreadyJoinedSavedUsersPhoneNameAsInServer
                      .length ==
                      0
                      ? SizedBox(
                    height: 0,
                  ):
                  Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: Insets.i20),
                      child: Text(fonts.registerUser.tr,
                          style: AppCss.poppinsSemiBold14
                              .textColor(appCtrl.appTheme.blackColor)))
                      .paddingOnly(top: Insets.i10),
                  availableContacts
                      .alreadyJoinedSavedUsersPhoneNameAsInServer
                      .length ==
                      0
                      ? SizedBox(
                    height: 0,
                  )
                      : ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    padding: EdgeInsets.all(00),
                    itemCount: availableContacts
                        .alreadyJoinedSavedUsersPhoneNameAsInServer
                        .length,
                    itemBuilder: (context, idx) {
                      DeviceContactIdAndName user = availableContacts
                          .alreadyJoinedSavedUsersPhoneNameAsInServer
                          .elementAt(idx);
                      log("user : ${user.name}");
                      String phone = user.phone!;
                      String name = user.name ?? user.phone!;
                      return phone != appCtrl.user["phone"]? FutureBuilder<LocalUserData?>(
                        future: availableContacts
                            .fetchUserDataFromnLocalOrServer(
                            widget.prefs!, phone),
                        builder: (BuildContext context,
                            AsyncSnapshot<LocalUserData?>
                            snapshot) {
                          if (snapshot.hasData &&
                              snapshot.data != null) {
                            return ListTile(
                              leading: CachedNetworkImage(
                                  imageUrl: snapshot.data!.photoURL,
                                  imageBuilder: (context, imageProvider) => CircleAvatar(
                                      backgroundColor:
                                      const Color(0xffE6E6E6),
                                      radius: Sizes.s20,
                                      backgroundImage: NetworkImage(
                                          snapshot.data!.photoURL)),
                                  placeholder: (context, url) => const CircleAvatar(
                                      backgroundColor:
                                      Color(0xffE6E6E6),
                                      radius: Sizes.s20,
                                      child: Icon(Icons.person,
                                          color:
                                          Color(0xffCCCCCC))),
                                  errorWidget: (context, url, error) =>
                                  const CircleAvatar(
                                      backgroundColor:
                                      Color(0xffE6E6E6),
                                      radius: AppRadius.r20,
                                      child: Icon(Icons.person,
                                          color:
                                          Color(0xffCCCCCC)))),
                              title: Text(
                                snapshot.data!.name,
                              ),   subtitle: Text(
                                snapshot.data!.aboutUser,
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 22.0, vertical: 0.0),
                              onTap: ()async {
                                log("DATA ss");
                                await FirebaseFirestore.instance
                                    .collection(
                                    collectionName.users)
                                    .doc(appCtrl.user['id'])
                                    .collection(
                                    collectionName.chats)
                                    .get()
                                    .then((value) {
                                  if (value.docs.isNotEmpty) {
                                    value.docs
                                        .asMap()
                                        .forEach((key, value) {
                                      if (value.data()[
                                      "receiverId"] ==
                                          appCtrl
                                              .user["id"] &&
                                          value.data()[
                                          "senderId"] ==
                                              snapshot
                                                  .data!.id ||
                                          value.data()[
                                          "senderId"] ==
                                              appCtrl
                                                  .user["id"] &&
                                              value.data()[
                                              "receiverId"] ==
                                                  snapshot
                                                      .data!.id) {

                                        UserContactModel
                                        userContact =
                                        UserContactModel(
                                            username: snapshot
                                                .data!.name,
                                            uid: value.data()[
                                            "senderId"],
                                            phoneNumber:
                                            snapshot.data!.idVariants,
                                            image: snapshot
                                                .data!.photoURL,
                                            isRegister: true);
                                        var data = {
                                          "chatId": value
                                              .data()["chatId"],
                                          "data": userContact
                                        };
                                        Get.toNamed(routeName.chat,
                                            arguments: data);
                                      }
                                    });
                                  }else{
                                    UserContactModel
                                    userContact =
                                    UserContactModel(
                                        username: snapshot
                                            .data!.name,
                                        uid: snapshot.data!.id,
                                        phoneNumber:
                                        snapshot.data!.idVariants,
                                        image: snapshot
                                            .data!.photoURL,
                                        isRegister: true);
                                    var data = {
                                      "chatId": "0",
                                      "data": userContact,
                                    };
                                    Get.toNamed(routeName.chat,
                                        arguments: data);
                                  }
                                });
                              },
                            );
                          }
                          return ListTile(
                            leading: CircleAvatar(radius: 22),
                            title: Text(
                              name,
                            ),
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 22.0, vertical: 0.0),
                          );
                        },
                      ): Container();
                    },
                  ),
                  Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: Insets.i20),
                      child: Text(fonts.inviteUser.tr,
                          style: AppCss.poppinsSemiBold14
                              .textColor(appCtrl.appTheme.blackColor)))
                      .paddingOnly(top: Insets.i10),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    padding: EdgeInsets.all(0),
                    itemCount: inviteContactsCount >=
                        availableContacts
                            .contactsBookContactList!.length
                        ? availableContacts
                        .contactsBookContactList!.length
                        : inviteContactsCount,
                    itemBuilder: (context, idx) {
                      MapEntry user = availableContacts
                          .contactsBookContactList!.entries
                          .elementAt(idx);
                      String phone = user.key;
                      return availableContacts
                          .previouslyFetchedKEYPhoneInSharedPrefs
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
                                  availableContacts
                                      .getInitials(user.value),
                                )),
                            title: Text(
                              user.value,
                            ),
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 22.0, vertical: 0.0),

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
                                child: Icon(
                                  Icons.person_add_alt,
                                )),
                          )
                        ],
                      );
                    },
                  ),
              ],
            ),
                ));
      }
    );
  }

  loading() {
    return Stack(children: [
      Container(
        child: Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(appCtrl.appTheme.primary),
            )),
      )
    ]);
  }
}
