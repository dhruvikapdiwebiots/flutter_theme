
import 'package:flutter_theme/config.dart';


class EditProfile extends StatelessWidget {
  final editCtrl = Get.put(EditProfileController());

  EditProfile({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<EditProfileController>(builder: (_) {
      return  PickupLayout(
        scaffold: Scaffold(
          backgroundColor: appCtrl.appTheme.whiteColor,
          appBar: AppBar(
            automaticallyImplyLeading: false,
              leading: Icon(Icons.arrow_back,color: appCtrl.appTheme.whiteColor).inkWell(onTap: ()=> Get.back()),
              backgroundColor: appCtrl.appTheme.primary,
              title: Text(fonts.saveProfile.tr,style: AppCss.poppinsblack16.textColor(appCtrl.appTheme.whiteColor),)),
          body: editCtrl.isLoading ?LoginLoader(isLoading: editCtrl.isLoading).height(MediaQuery.of(context).size.height) : SingleChildScrollView(
              child: Form(
            key: editCtrl.formKey,
            child:editCtrl.user != null && editCtrl.user != ""? Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Hero(
                  tag: "user",
                  child: editCtrl.user["image"] != "" && editCtrl.user["image"] != null?  CachedNetworkImage(
                      imageUrl: editCtrl.user["image"],
                      imageBuilder: (context, imageProvider) =>
                          CircleAvatar(
                            backgroundColor: const Color(0xffE6E6E6),
                            radius: 60,
                            backgroundImage: NetworkImage(
                                '${editCtrl.user["image"]}'),
                          ),
                      placeholder: (context, url) =>  Container(
                        height: Sizes.s120,
                        width: Sizes.s120,
                        alignment: Alignment.center,
                        padding: const EdgeInsets.all(Insets.i15),
                        decoration: BoxDecoration(
                            color: appCtrl.appTheme.gray.withOpacity(.3),
                            image:
                            DecorationImage(image: AssetImage(imageAssets.user)),
                            shape: BoxShape.circle),
                      ),
                      errorWidget: (context, url, error) =>
                       Container(
                        height: Sizes.s120,
                        width: Sizes.s120,
                        alignment: Alignment.center,
                        padding: const EdgeInsets.all(Insets.i15),
                        decoration: BoxDecoration(
                            color: appCtrl.appTheme.gray.withOpacity(.3),
                            image:
                            DecorationImage(image: AssetImage(imageAssets.user)),
                            shape: BoxShape.circle),
                      )):  Container(
                    height: Sizes.s120,
                    width: Sizes.s120,
                    alignment: Alignment.center,
                    padding: const EdgeInsets.all(Insets.i15),
                    decoration: BoxDecoration(
                        color: appCtrl.appTheme.gray.withOpacity(.3),
                        image:
                        DecorationImage(image: AssetImage(imageAssets.user)),
                        shape: BoxShape.circle),
                  ),
                ).inkWell(onTap: ()=>editCtrl.imagePickerOption(context)),
                const EditProfileTextBox(),
                CommonButton(
                  title: fonts.saveProfile.tr,
                  margin: 0,
                  onTap: () {
                    if (editCtrl.formKey.currentState!.validate()) {
                      editCtrl.updateUserData();
                    } else {
                    }
                  },
                  style: AppCss.poppinsblack14
                      .textColor(appCtrl.appTheme.whiteColor),
                )
              ],
            ).marginSymmetric(vertical: Insets.i20, horizontal: Insets.i15): Container(),
          )),
        ),
      );
    });
  }
}
