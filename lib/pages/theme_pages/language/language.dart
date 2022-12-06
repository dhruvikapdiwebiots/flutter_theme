import '../../../config.dart';

class LanguageScreen extends StatelessWidget {
  final languageCtrl = Get.put(LanguageController());

  LanguageScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<LanguageController>(builder: (_) {
      return GetBuilder<AppController>(builder: (appCtrl) {
        return Scaffold(
          body: Column(
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
                        child: RadioListTile(
                            dense: true,
                            visualDensity: const VisualDensity(
                                horizontal: VisualDensity.minimumDensity,
                                vertical: VisualDensity.minimumDensity),
                            value: e.key,
                            groupValue: appCtrl.currVal,
                            contentPadding: EdgeInsets.zero,
                            title: Text(trans(e.value['name'].toString()),
                                style: AppCss.montserratSemiBold14
                                    .textColor(appCtrl.appTheme.txt)),
                            onChanged: (int? val) {
                              appCtrl.currVal = val!;
                              languageCtrl.languageSelection(e.value);
                            },
                            activeColor: appCtrl.appTheme.primary),
                      ));
                }).toList()
              ]),
        );
      });
    });
  }
}
