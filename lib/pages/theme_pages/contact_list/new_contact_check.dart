import 'dart:developer';
import 'dart:io';

import 'package:flutter_theme/config.dart';
import 'package:share_plus/share_plus.dart';

class NewContact extends StatefulWidget {
  final PhotoUrl? message;

  const NewContact({super.key, this.message});

  @override
  State<NewContact> createState() => _NewContactState();
}

class _NewContactState extends State<NewContact> {
  bool isLoading = true;
  List<JoinedUserModel> searchAvailable = [];
  List<JoinedUserModel> registerContact = [];
  String _query = "";
  Map<String?, String?>? contacts;

  Future<DocumentSnapshot> getUserDoc(String phone) async {
    var doc = await FirebaseFirestore.instance
        .collection(collectionName.users)
        .doc(phone)
        .get();
    return doc;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      timerSet();
    });
    setState(() {});
    final dashboardCtrl = Get.isRegistered<DashboardController>()
        ? Get.find<DashboardController>()
        : Get.put(DashboardController());
    dashboardCtrl.searchText.addListener(() {
      if (dashboardCtrl.searchText.text.isEmpty) {
        setState(() {
          appCtrl.availableContact = [];
          _query = "";
          appCtrl.allContacts = contacts;
          appCtrl.availableContact = registerContact;
          appCtrl.update();
          Get.forceAppUpdate();
        });
      } else {
        setState(() {
          _query = dashboardCtrl.searchText.text;
          appCtrl.availableContact = [];
          appCtrl.update();
          appCtrl.allContacts =
              Map.fromEntries(contacts!.entries.where((MapEntry contact) {
            return contact.value.toLowerCase().contains(_query.toLowerCase());
          }));
          appCtrl.update();

          registerContact.asMap().entries.forEach((element) {
            if (element.value.name!
                .toLowerCase()
                .contains(_query.toLowerCase())) {
              if (appCtrl.availableContact.isEmpty) {
                appCtrl.availableContact = [element.value];
              } else {
                if (!appCtrl.availableContact.contains(element.value)) {
                  appCtrl.availableContact.add(element.value);
                }
              }
              appCtrl.update();
            }
            setState(() {});
          });

          appCtrl.update();
        });
        appCtrl.update();
      }
      Get.forceAppUpdate();
    });
  }

  timerSet() async {
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        contacts = appCtrl.allContacts;
        registerContact = appCtrl.availableContact;
        isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<DashboardController>(builder: (dashboardCtrl) {
      return GetBuilder<AppController>(builder: (appCtrl) {
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
                Icon(Icons.refresh, color: appCtrl.appTheme.blackColor)
                    .paddingAll(Insets.i10)
                    .decorated(
                        color: appCtrl.appTheme.white,
                        boxShadow: [
                          const BoxShadow(
                              offset: Offset(0, 2),
                              blurRadius: 5,
                              spreadRadius: 1,
                              color: Color.fromRGBO(0, 0, 0, 0.08))
                        ],
                        borderRadius: BorderRadius.circular(AppRadius.r10))
                    .marginSymmetric(vertical: Insets.i5)
                    .paddingSymmetric(
                        vertical: Insets.i14, horizontal: Insets.i15)
                    .inkWell(onTap: () async {
                  isLoading = true;
                  setState(() {});

                  appCtrl.update();
                  registerContact = appCtrl.availableContact;
                  contacts = appCtrl.allContacts;
                  await Future.delayed(DurationClass.s2);
                  debugPrint("registerContact :: ${registerContact.length}");
                  debugPrint("contacts :: ${contacts!.length}");
                  isLoading = false;
                  setState(() {});
                })
              ],
              leading: const BackIcon()),
          body: Stack(children: [
            if (!isLoading)
              RefreshIndicator(
                  onRefresh: () async {
                    isLoading = true;
                    setState(() {});


                    appCtrl.update();
                    registerContact = appCtrl.availableContact;
                    contacts = appCtrl.allContacts;
                    await Future.delayed(DurationClass.s2);
                    isLoading = false;
                    setState(() {});
                  },
                  child: ListView(children: [
                    CommonTextBox(
                        labelText: fonts.mobileNumber.tr,
                        controller: dashboardCtrl.searchText,
                        textInputAction: TextInputAction.done,
                        keyboardType: TextInputType.name,
                        border: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: appCtrl.appTheme.primary),
                            borderRadius: BorderRadius.circular(AppRadius.r8)),
                        suffixIcon: Icon(
                                dashboardCtrl.searchText.text.isNotEmpty
                                    ? Icons.cancel
                                    : Icons.search,
                                color: appCtrl.appTheme.blackColor)
                            .inkWell(onTap: () {
                          _query = "";
                          appCtrl.allContacts = contacts;
                          appCtrl.update();
                          dashboardCtrl.searchText.text = "";
                          dashboardCtrl.update();
                          searchAvailable = [];
                          setState(() {});
                        })).marginAll(Insets.i15),
                    if (appCtrl.availableContact.isNotEmpty)
                      Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: Insets.i20),
                              child: Text(fonts.inviteUser.tr,
                                  style: AppCss.poppinsSemiBold14
                                      .textColor(appCtrl.appTheme.blackColor)))
                          .paddingOnly(top: Insets.i10),
                    if (appCtrl.availableContact.isNotEmpty)
                      ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          padding:
                              const EdgeInsets.symmetric(vertical: Insets.i10),
                          itemCount: appCtrl.availableContact.length,
                          itemBuilder: (context, idx) {
                            JoinedUserModel user =
                                appCtrl.availableContact.elementAt(idx);
                            return user.phone == appCtrl.user["phone"]
                                ? Container()
                                : FutureBuilder(
                                    future: getUserDoc(user.id!),
                                    builder: (BuildContext context,
                                        AsyncSnapshot snapshot) {
                                      if (snapshot.hasData &&
                                          snapshot.data.exists) {
                                        return ListTile(
                                            tileColor: Colors.white,
                                            leading: CachedNetworkImage(
                                                imageUrl:
                                                    snapshot.data['image'],
                                                imageBuilder: (context, imageProvider) => CircleAvatar(
                                                    backgroundColor:
                                                        const Color(0xffE6E6E6),
                                                    radius: Sizes.s20,
                                                    backgroundImage: NetworkImage(
                                                        '${snapshot.data['image']}')),
                                                placeholder: (context, url) =>
                                                    const CircleAvatar(
                                                        backgroundColor:
                                                            Color(0xffE6E6E6),
                                                        radius: Sizes.s20,
                                                        child: Icon(Icons.person,
                                                            color: Color(
                                                                0xffCCCCCC))),
                                                errorWidget: (context, url, error) =>
                                                    const CircleAvatar(
                                                        backgroundColor: Color(0xffE6E6E6),
                                                        radius: AppRadius.r20,
                                                        child: Icon(Icons.person, color: Color(0xffCCCCCC)))),
                                            title: Text(snapshot.data["name"], style: AppCss.poppinsSemiBold14.textColor(appCtrl.appTheme.blackColor)),
                                            subtitle: Text(snapshot.data["statusDesc"], style: AppCss.poppinsMedium14.textColor(appCtrl.appTheme.txtColor)),
                                            contentPadding: const EdgeInsets.symmetric(horizontal: 22.0, vertical: 0.0),
                                            onTap: () async {
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
                                                                appCtrl.user[
                                                                    "id"] &&
                                                            value.data()[
                                                                    "senderId"] ==
                                                                snapshot.data[
                                                                    "id"] ||
                                                        value.data()[
                                                                    "senderId"] ==
                                                                appCtrl.user[
                                                                    "id"] &&
                                                            value.data()[
                                                                    "receiverId"] ==
                                                                snapshot.data[
                                                                    "id"]) {
                                                      UserContactModel
                                                          userContact =
                                                          UserContactModel(
                                                              username: snapshot
                                                                      .data![
                                                                  "name"],
                                                              uid: value.data()[
                                                                  "senderId"],
                                                              phoneNumber:
                                                                  snapshot.data![
                                                                      "phone"],
                                                              image: snapshot
                                                                      .data![
                                                                  "image"],
                                                              isRegister: true);
                                                      var data = {
                                                        "chatId": value
                                                            .data()["chatId"],
                                                        "data": userContact
                                                      };
                                                      Get.toNamed(
                                                          routeName.chat,
                                                          arguments: data);
                                                    }
                                                  });
                                                }
                                              });
                                            });
                                      } else {
                                        return Container();
                                      }
                                    });
                          }),
                    Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: Insets.i20, vertical: Insets.i10),
                        child: Text(fonts.inviteUser.tr,
                            style: AppCss.poppinsSemiBold14
                                .textColor(appCtrl.appTheme.blackColor))),
                    ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: const EdgeInsets.all(0),
                        itemCount: appCtrl.allContacts!.length,
                        itemBuilder: (context, idx) {
                          MapEntry user =
                              appCtrl.allContacts!.entries.elementAt(idx);
                          String phone = user.key;
                          String name = user.value;

                          return appCtrl.availableContact.indexWhere(
                                      (element) => element.phone == phone) >=
                                  0
                              ? Container(width: 0)
                              : Stack(children: [
                                  ListTile(
                                      tileColor: Colors.white,
                                      leading: CircleAvatar(
                                          backgroundColor:
                                              appCtrl.appTheme.primary,
                                          radius: AppRadius.r20,
                                          child: Text(
                                              user.value.length > 2
                                                  ? user.value
                                                      .replaceAll(" ", "")
                                                      .substring(0, 2)
                                                      .toUpperCase()
                                                  : user.value[0],
                                              style: TextStyle(
                                                  fontSize: Sizes.s12,
                                                  color:
                                                      appCtrl.appTheme.white))),
                                      title: Text(name,
                                          style: TextStyle(
                                              color:
                                                  appCtrl.appTheme.blackColor)),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              horizontal: 22.0,
                                              vertical: Insets.i3),
                                      trailing: Icon(
                                              Icons.person_add_alt_outlined,
                                              color: appCtrl.appTheme.primary)
                                          .inkWell(onTap: () async {
                                        if (Platform.isAndroid) {
                                          final uri = Uri(
                                              scheme: "sms",
                                              path: phoneNumberExtension(phone),
                                              queryParameters: <String, String>{
                                                'body': Uri.encodeComponent(
                                                    'Download the ChatBox App'),
                                              });
                                          await launchUrl(uri);

                                          Share.share(
                                              " 'Download the ChatBox App'");
                                        }
                                      }))
                                ]);
                        })
                  ])),
            if (isLoading)
              Center(
                  child: Material(
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(60)),
                      child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                  color: appCtrl.appTheme.primary,
                                  strokeWidth: 3)))))
          ]).height(MediaQuery.of(context).size.height),
        );
      });
    });
  }
}
