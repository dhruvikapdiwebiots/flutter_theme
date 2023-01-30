

import '../../../../config.dart';

class CreateGroup extends StatelessWidget {

  const CreateGroup({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
      return GetBuilder<CreateGroupController>(builder: (groupCtrl) {
        return groupCtrl.isLoading ? CommonLoader(isLoading: groupCtrl.isLoading) : Padding(
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Container(
              color: appCtrl.appTheme.whiteColor,
              padding: const EdgeInsets.all(16),
              height: MediaQuery.of(context).size.height / 2.2,
              child: Form(
                key: groupCtrl.formKey,
                child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const VSpace(Sizes.s15),
                      Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: Text(
                          fonts.setGroup.tr,
                          textAlign: TextAlign.left,
                          style: AppCss.poppinsBold16
                              .textColor(appCtrl.appTheme.blackColor),
                        ),
                      ),
                      const VSpace(Sizes.s20),
                      Row(
                        children: [
                          groupCtrl.pickerCtrl.image != null
                              ? Container(
                                  height: Sizes.s60,
                                  width: Sizes.s60,
                                  decoration: BoxDecoration(
                                      color: appCtrl.appTheme.gray
                                          .withOpacity(.2),
                                      shape: BoxShape.circle),
                                  child: Image.file(
                                          groupCtrl.pickerCtrl.image!,
                                          fit: BoxFit.fill)
                                      .clipRRect(all: AppRadius.r50),
                                ).inkWell(onTap: () {
                                  groupCtrl.pickerCtrl
                                      .imagePickerOption(context,isCreateGroup: true);
                                })
                              : Image.asset(
                                  imageAssets.user,
                                  height: Sizes.s30,
                                  width: Sizes.s30,
                                  color: appCtrl.appTheme.whiteColor,
                                )
                                  .paddingAll(Insets.i15)
                                  .decorated(
                                      color: appCtrl.appTheme.grey
                                          .withOpacity(.4),
                                      shape: BoxShape.circle)
                                  .inkWell(
                                      onTap: () => groupCtrl.pickerCtrl
                                          .imagePickerOption(context,isCreateGroup: true)),
                          const HSpace(Sizes.s15),
                          Expanded(
                            child: CommonTextBox(
                              controller: groupCtrl.txtGroupName,
                              labelText: fonts.groupName.tr,
                              validator: (val) {
                                if (val!.isEmpty) {
                                  return "Group Name Required";
                                } else {
                                  return null;
                                }
                              },
                              maxLength: 25,
                              border: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: appCtrl.appTheme.blackColor)),
                              textInputAction: TextInputAction.next,
                            ),
                          ),
                        ],
                      ),
                      const VSpace(Sizes.s20),
                      CommonButton(
                          title: fonts.create.tr,
                          style: AppCss.poppinsMedium14
                              .textColor(appCtrl.appTheme.whiteColor),
                          margin: 0,
                          onTap: () =>
                              GroupFirebaseApi().createGroup(groupCtrl))
                    ]),
              )),
        );
      });
    });
  }
}
