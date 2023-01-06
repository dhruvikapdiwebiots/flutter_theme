
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

import '../../../config.dart';

class AllContactList extends StatelessWidget {
  final contactCtrl = Get.put(AllContactListController());

  AllContactList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AllContactListController>(builder: (_) {
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
              body: Stack(children: [
                Column(children: [
                  CommonTextBox(
                          labelText: fonts.mobileNumber.tr,
                          controller: contactCtrl.searchText,
                          textInputAction: TextInputAction.done,
                          keyboardType: TextInputType.name,
                          onChanged: (val) => contactCtrl.fetchPage(0, val),
                          border: OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: appCtrl.appTheme.primary)),
                          maxLength: 10,
                          suffixIcon: Icon(Icons.search,
                                  color: appCtrl.appTheme.blackColor)
                              .inkWell(onTap: () {}))
                      .marginAll(Insets.i15),
                  Expanded(
                      child: RefreshIndicator(
                          onRefresh: () => Future.sync(
                                () => contactCtrl.fetchPage(0, ""),
                              ),
                          child: PagedListView<int, Contact>(
                            pagingController: contactCtrl.pagingController,
                            builderDelegate: PagedChildBuilderDelegate<Contact>(

                                noItemsFoundIndicatorBuilder: (_) => Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Center(
                                            child:
                                                const CircularProgressIndicator()
                                                    .width(Sizes.s30)
                                                    .height(Sizes.s30)),
                                        Text(fonts.noItemFound.tr)
                                            .alignment(Alignment.center)
                                      ],
                                    ),

                                itemBuilder: (context, item, index) => ListTile(
                                      onTap: () {
                                        Get.back(result: item);
                                      },
                                      leading: item.photo != null
                                          ? CircleAvatar(
                                              backgroundImage:
                                                  MemoryImage(item.photo!))
                                          : CircleAvatar(
                                              child: Text(
                                                  item.displayName.isNotEmpty?    item.displayName
                                                              .length >
                                                          2
                                                      ? item.displayName
                                                          .replaceAll(" ", "")
                                                          .substring(0, 2)
                                                          .toUpperCase()
                                                      : item.displayName[index]
                                                          [0]: "",
                                                  style: AppCss.poppinsMedium12
                                                      .textColor(appCtrl
                                                          .appTheme
                                                          .whiteColor))),
                                      title: Text(item.displayName ?? ""),
                                      subtitle: Text(phoneNumberExtension(
                                          item.phones[0].number)),
                                    ).width(MediaQuery.of(context).size.width)),
                          )))
                ])
              ])));
    });
  }
}
