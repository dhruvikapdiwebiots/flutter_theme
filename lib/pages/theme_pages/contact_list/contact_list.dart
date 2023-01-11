import 'dart:io';

import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

import '../../../config.dart';

class ContactList extends StatelessWidget {
  final contactCtrl = Get.find<ContactListController>();

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
              title: Text(
                fonts.contact.tr,
                style: AppCss.poppinsMedium16
                    .textColor(appCtrl.appTheme.whiteColor)
              ),
              automaticallyImplyLeading: false,
              actions: [
                Icon(
                  Icons.refresh,
                  color: appCtrl.appTheme.white,
                ).marginSymmetric(horizontal: Insets.i15).inkWell(
                    onTap: () => contactCtrl.pagingController.refresh())
              ],
              leading: IconButton(
                  icon: Icon(Icons.arrow_back,
                      color: appCtrl.appTheme.whiteColor),
                  onPressed: () {
                    Get.back();
                    contactCtrl.searchText.text = "";
                  })),
          body: Stack(
            children: [
              Column(
                children: [
                  CommonTextBox(
                          labelText: fonts.mobileNumber.tr,
                          controller: contactCtrl.searchText,
                          textInputAction: TextInputAction.done,
                          keyboardType: TextInputType.name,
                          onChanged: (val) {
                            contactCtrl.searchList(0, val);
                            contactCtrl.update();
                          },
                          border: OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: appCtrl.appTheme.primary)),
                          maxLength: 10,
                          suffixIcon: Icon(Icons.search,
                                  color: appCtrl.appTheme.blackColor)
                              .inkWell(
                                  onTap: () => contactCtrl.searchList(
                                      0, contactCtrl.searchText.text)))
                      .marginAll(Insets.i15),
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: () => Future.sync(
                        () => contactCtrl.pagingController.refresh(),
                      ),
                      child: PagedListView<int, ContactModel>(
                        pagingController: contactCtrl.pagingController,
                        builderDelegate:
                            PagedChildBuilderDelegate<ContactModel>(
                                firstPageProgressIndicatorBuilder: (_) =>
                                    Center(
                                      child: const CircularProgressIndicator()
                                          .width(Sizes.s30)
                                          .height(Sizes.s30),
                                    ),
                                newPageProgressIndicatorBuilder: (_) => Center(
                                      child: const CircularProgressIndicator()
                                          .width(Sizes.s30)
                                          .height(Sizes.s30),
                                    ),
                                noItemsFoundIndicatorBuilder: (_) => Center(
                                    child: const CircularProgressIndicator()
                                        .width(Sizes.s30)
                                        .height(Sizes.s30)),
                                noMoreItemsIndicatorBuilder: (_) => Center(
                                      child: const CircularProgressIndicator()
                                          .width(Sizes.s30)
                                          .height(Sizes.s30),
                                    ),
                                itemBuilder: (context, item, index) => Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        index == 0
                                            ? item.userTitle!.isNotEmpty
                                                ? Text(item.title!)
                                                    .paddingSymmetric(
                                                        horizontal: Insets.i15,
                                                        vertical: Insets.i10)
                                                    .width(
                                                        MediaQuery.of(context)
                                                            .size
                                                            .width)
                                                : Container()
                                            : Text(item.title!)
                                                .paddingSymmetric(
                                                    horizontal: Insets.i15,
                                                    vertical: Insets.i10)
                                                .width(MediaQuery.of(context)
                                                    .size
                                                    .width),
                                        ListView.builder(
                                          shrinkWrap: true,
                                          physics:
                                              const NeverScrollableScrollPhysics(),
                                          itemBuilder: (context, index) =>
                                              item.userTitle![index].isRegister!
                                                  ? RegisterUser(
                                                      userContactModel: item
                                                          .userTitle![index])
                                                  : ListTile(
                                                      contentPadding:
                                                          const EdgeInsets
                                                                  .symmetric(
                                                              vertical:
                                                                  Insets.i5,
                                                              horizontal:
                                                                  Insets.i18),
                                                      onTap: () {
                                                        MessageFirebaseApi()
                                                            .saveContact(
                                                                item.userTitle![
                                                                    index],
                                                                item
                                                                    .userTitle![
                                                                        index]
                                                                    .isRegister);
                                                      },
                                                      leading:
                                                          item.userTitle![index]
                                                                  .isRegister!
                                                              ? CachedNetworkImage(
                                                                  imageUrl: item
                                                                      .userTitle![
                                                                          index]
                                                                      .image!,
                                                                  imageBuilder:
                                                                      (context,
                                                                              imageProvider) =>
                                                                          CircleAvatar(
                                                                            backgroundColor:
                                                                                const Color(0xffE6E6E6),
                                                                            radius:
                                                                                Sizes.s20,
                                                                            backgroundImage:
                                                                                NetworkImage(item.userTitle![index].image!),
                                                                          ),
                                                                  placeholder: (context,
                                                                          url) =>
                                                                      const CircularProgressIndicator(
                                                                        strokeWidth:
                                                                            2,
                                                                      ).width(Sizes.s20).height(Sizes.s20).paddingAll(Insets.i15).decorated(
                                                                          color: appCtrl
                                                                              .appTheme
                                                                              .grey
                                                                              .withOpacity(
                                                                                  .4),
                                                                          shape: BoxShape
                                                                              .circle),
                                                                  errorWidget: (context,
                                                                          url,
                                                                          error) =>
                                                                      CircleAvatar(
                                                                          child: Text(
                                                                        item.userTitle![index].username!.length >
                                                                                2
                                                                            ? item.userTitle![index].username!.replaceAll(" ", "").substring(0, 2).toUpperCase()
                                                                            : item.userTitle![index].username![0],
                                                                        style: AppCss
                                                                            .poppinsMedium12
                                                                            .textColor(appCtrl.appTheme.whiteColor),
                                                                      )))
                                                              : item.userTitle![index].contactImage != null
                                                                  ? CircleAvatar(backgroundImage: MemoryImage(item.userTitle![index].contactImage!))
                                                                  : CircleAvatar(child: Text(item.userTitle![index].username!.length > 2 ? item.userTitle![index].username!.replaceAll(" ", "").substring(0, 2).toUpperCase() : item.userTitle![index].username![0], style: AppCss.poppinsMedium12.textColor(appCtrl.appTheme.whiteColor))),
                                                      title: Text(item
                                                              .userTitle![index]
                                                              .username! ),
                                                      trailing: !item
                                                              .userTitle![index]
                                                              .isRegister!
                                                          ? Icon(
                                                              Icons
                                                                  .person_add_alt_outlined,
                                                              color: appCtrl
                                                                  .appTheme
                                                                  .primary,
                                                            ).inkWell(
                                                              onTap: () async {
                                                              if (Platform
                                                                  .isAndroid) {
                                                                final uri = Uri(
                                                                  scheme: "sms",
                                                                  path: phoneNumberExtension(item
                                                                      .userTitle![
                                                                          index]
                                                                      .phoneNumber),
                                                                  queryParameters: <
                                                                      String,
                                                                      String>{
                                                                    'body': Uri
                                                                        .encodeComponent(
                                                                            'Download the ChatBox App'),
                                                                  },
                                                                );
                                                                await launchUrl(
                                                                    uri);
                                                              }
                                                            })
                                                          : const SizedBox(
                                                              height: 1,
                                                              width: 1,
                                                            ),
                                                    ),
                                          itemCount: item.userTitle!.length,
                                        )
                                      ],
                                    ).width(MediaQuery.of(context).size.width)),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    });
  }
}
