import 'package:flutter_theme/pages/theme_pages/language/language_layout.dart';

import '../../../config.dart';

class LanguageScreen extends StatelessWidget {
  final languageCtrl = Get.put(LanguageController());

  LanguageScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<LanguageController>(builder: (_) {
      return GetBuilder<AppController>(builder: (appCtrl) {
        return DirectionalityRtl(
          child: Scaffold(
            appBar: CommonAppBar(text: fonts.language.tr),
            backgroundColor: appCtrl.appTheme.white,
            /*   body: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  //language list
                  ...appArray.languageList.asMap().entries.map((e) {
                    return Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: Insets.i12, horizontal: Insets.i10),
                        child: InkWell(
                          onTap: () => languageCtrl.languageSelection(e.value),
                          child: Theme(
                            data: Theme.of(context).copyWith(
                                unselectedWidgetColor: appCtrl.appTheme.grey,
                                disabledColor: appCtrl.appTheme.grey),
                            child: RadioListTile(
                                dense: true,
                                visualDensity: const VisualDensity(
                                    horizontal: VisualDensity.minimumDensity,
                                    vertical: VisualDensity.minimumDensity),
                                value: e.key,
                                groupValue: appCtrl.currVal,
                                contentPadding: EdgeInsets.zero,
                                title: Row(children: [
                                  Text(trans(e.value['name'].toString()),
                                      style: AppCss.poppinsSemiBold14.textColor(
                                          appCtrl.isTheme
                                              ? appCtrl.appTheme.whiteColor
                                              : appCtrl.appTheme.blackColor)),
                                  const HSpace(Sizes.s15),
                                  Text(
                                      "-   ${e.value['name'].toString().toCapitalized()}",
                                      style: AppCss.poppinsMedium12
                                          .textColor(appCtrl.appTheme.grey))
                                ]),
                                onChanged: (int? val) {
                                  appCtrl.currVal = val!;
                                  languageCtrl.languageSelection(e.value);
                                },
                                activeColor: appCtrl.appTheme.primary),
                          ),
                        ));
                  }).toList()
                ]),*/
            body: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                SingleChildScrollView(
                    child: GridView.builder(
                        shrinkWrap: true,
                        padding: const EdgeInsets.only(bottom: Insets.i100),
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: appCtrl.languagesLists.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisSpacing: 20,
                                mainAxisExtent: 90,
                                mainAxisSpacing: 20.0,
                                crossAxisCount: 3),
                        itemBuilder: (context, index) {
                          return appCtrl.languagesLists[index]["isActive"] ==
                                  true
                              ? LanguageLayout(
                                  value: appCtrl.languagesLists[index],
                                  index: index,
                                  selectedIndex: languageCtrl.selectedIndex,
                                  onTap: () => languageCtrl.onLanguageSelectTap(
                                      index, appCtrl.languagesLists[index]))
                              : Container();
                        }).paddingAll(Insets.i20)),
                CommonButton(title: fonts.select.tr, onTap: () => Get.back(),style: AppCss.poppinsMedium14.textColor(appCtrl.appTheme.white),)
                    .paddingOnly(bottom: Insets.i20).backgroundColor(appCtrl.appTheme.bgColor)

              ],
            ),
          ),
        );
      });
    });
  }
}
