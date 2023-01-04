import 'dart:developer';
import 'dart:io';
import '../../../config.dart';

class ContactList extends StatelessWidget {
  final contactCtrl = Get.put(ContactListController());

  ContactList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return GetBuilder<ContactListController>(builder: (_) {
      return WillPopScope(
        onWillPop: () async {
          return false;
        },
        child: Scaffold(
          backgroundColor: appCtrl.appTheme.whiteColor,
          appBar: AppBar(
              title: Text(fonts.contact.tr),
              automaticallyImplyLeading: false,
              leading: IconButton(
                  icon: Icon(Icons.arrow_back,
                      color: appCtrl.appTheme.whiteColor),
                  onPressed: () {
                    Get.back();
                    contactCtrl.searchText.text = "";
                  })),
          body: SafeArea(
              child: Stack(
            children: [
              Column(
                children: [
                  CommonTextBox(
                          labelText: fonts.mobileNumber.tr,
                          controller: contactCtrl.searchText,
                          textInputAction: TextInputAction.done,
                          keyboardType: TextInputType.name,
                          onChanged: (val) {
                            contactCtrl.fetchPage(val);
                            contactCtrl.update();
                          },
                          border: OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: appCtrl.appTheme.primary)),
                          maxLength: 10,
                          suffixIcon: Icon(Icons.search,
                                  color: appCtrl.appTheme.blackColor)
                              .inkWell(
                                  onTap: () => contactCtrl
                                      .fetchPage(contactCtrl.searchText.text)))
                      .marginAll(Insets.i15),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ...contactCtrl.contactList
                              .asMap()
                              .entries
                              .map((e) => Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(e.value.title!)
                                          .paddingSymmetric(
                                              horizontal: Insets.i15,
                                              vertical: Insets.i10)
                                          .decorated(
                                              color: appCtrl.appTheme.grey
                                                  .withOpacity(.3))
                                          .width(MediaQuery.of(context)
                                              .size
                                              .width),
                                      ListView.builder(
                                        shrinkWrap: true,
                                        physics:const NeverScrollableScrollPhysics(),
                                        itemBuilder: (context, index) =>
                                            ListTile(
                                          onTap: () {
                                            log("dsgdsg : ${e.value.userTitle![index]}");
                                            MessageFirebaseApi().saveContact(e.value.userTitle![index],e.value.userTitle![index].isRegister);
                                          },
                                          leading: e.value.userTitle![index]
                                                  .isRegister!
                                              ? CachedNetworkImage(
                                                  imageUrl: e
                                                      .value
                                                      .userTitle![index]
                                                      .image!,
                                                  imageBuilder:
                                                      (context, imageProvider) =>
                                                          CircleAvatar(
                                                            backgroundColor:
                                                                const Color(
                                                                    0xffE6E6E6),
                                                            radius: 32,
                                                            backgroundImage:
                                                                NetworkImage(e
                                                                    .value
                                                                    .userTitle![
                                                                        index]
                                                                    .image!),
                                                          ),
                                                  placeholder: (context, url) =>
                                                      const CircularProgressIndicator(
                                                        strokeWidth: 2,
                                                      )
                                                          .width(Sizes.s20)
                                                          .height(Sizes.s20)
                                                          .paddingAll(
                                                              Insets.i15)
                                                          .decorated(
                                                              color: appCtrl
                                                                  .appTheme
                                                                  .grey
                                                                  .withOpacity(
                                                                      .4),
                                                              shape: BoxShape
                                                                  .circle),
                                                  errorWidget:
                                                      (context, url, error) =>
                                                          CircleAvatar(child: Text(e.value.userTitle![index].username!.length > 2 ? e.value.userTitle![index].username!.replaceAll(" ", "").substring(0, 2).toUpperCase() : e.value.userTitle![index].username![0])))
                                              : e.value.userTitle![index].contactImage != null
                                                  ? CircleAvatar(backgroundImage: MemoryImage(e.value.userTitle![index].contactImage!))
                                                  : CircleAvatar(child: Text(e.value.userTitle![index].username!.length > 2 ? e.value.userTitle![index].username!.replaceAll(" ", "").substring(0, 2).toUpperCase() : e.value.userTitle![index].username![0])),
                                          title: Text(e
                                                  .value
                                                  .userTitle![index]
                                                  .username! ??
                                              ""),
                                          subtitle: Text(e
                                                  .value
                                                  .userTitle![index]
                                                  .phoneNumber ??
                                              ""),
                                          trailing: StreamBuilder(
                                              stream: FirebaseFirestore
                                                  .instance
                                                  .collection('users')
                                                  .where("phone",
                                                      isEqualTo:
                                                          phoneNumberExtension(e.value.userTitle![index]
                                                              .phoneNumber))
                                                  .snapshots(),
                                              builder: (context, snapshot) {
                                                if (snapshot.data != null) {
                                                  if (!snapshot.data!.docs
                                                      .isNotEmpty) {
                                                    return Text(
                                                            fonts.invite.tr)
                                                        .inkWell(
                                                            onTap: () async {
                                                      if (Platform
                                                          .isAndroid) {
                                                        final uri = Uri(
                                                          scheme: "sms",
                                                          path: phoneNumberExtension(e
                                                              .value
                                                              .userTitle![
                                                                  index]
                                                              .phoneNumber),
                                                          queryParameters: <
                                                              String, String>{
                                                            'body': Uri
                                                                .encodeComponent(
                                                                    'Download the ChatBox App'),
                                                          },
                                                        );
                                                        await launchUrl(uri);
                                                      }
                                                    });
                                                  } else {
                                                    return Container();
                                                  }
                                                } else {
                                                  return Container();
                                                }
                                              }).width(Sizes.s40),
                                        ),
                                        itemCount: e.value.userTitle!.length,
                                      )
                                    ],
                                  ).width(MediaQuery.of(context).size.width))
                              .toList()
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          )),
        ),
      );
    });
  }
}
