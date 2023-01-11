
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
                  title: Text(fonts.contact.tr,
                      style: AppCss.poppinsblack16
                          .textColor(appCtrl.appTheme.whiteColor)),
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

                  //all list
                  const AllContactPageList()
                ])
              ])));
    });
  }
}
