
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import '../../../config.dart';
import '../../../controllers/theme_controller/add_contact_book.dart';

class NewContact extends StatelessWidget {
  final contactCtrl = Get.put(NewContactController());

  NewContact({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<NewContactController>(builder: (_) {
      return Scaffold(
        backgroundColor: appCtrl.appTheme.bgColor,
        appBar: CommonAppBar(
          text: fonts.addContact.tr,
        ),
        body: ListView(
          children: [
            Text(fonts.name.tr,
                style:
                    AppCss.poppinsBold14.textColor(appCtrl.appTheme.txt)),
            const VSpace(Sizes.s8),
            NameTextBox(
                nameFocus: contactCtrl.nameFocus,
                nameText: contactCtrl.nameController,
                nameValidation: contactCtrl.nameValidation),


            const VSpace(Sizes.s20),
            Text(fonts.email.tr,
                style:
                    AppCss.poppinsBold14.textColor(appCtrl.appTheme.txt)),
            const VSpace(Sizes.s8),
            EmailTextBox(
                emailText: contactCtrl.emailController,
                emailValidate: contactCtrl.emailValidate,
                focusNode: contactCtrl.emailFocus,
                border: OutlineInputBorder(
                    borderSide: BorderSide(color: appCtrl.appTheme.primary))),

            const VSpace(Sizes.s20),
            Text(fonts.phoneNumber.tr,
                style: AppCss.poppinsBold14
                    .textColor(appCtrl.appTheme.txt)),
            const VSpace(Sizes.s8),
          Theme(
              data: ThemeData(
                  dialogTheme:
                  DialogTheme(backgroundColor: appCtrl.appTheme.white)),
              child: InternationalPhoneNumberInput(
                  textStyle:
                  AppCss.poppinsMedium16.textColor(appCtrl.appTheme.txt),
                  onInputChanged: (PhoneNumber number) {
                    contactCtrl.dialCode = number.dialCode!;
                    contactCtrl.update();
                    if (number.phoneNumber!.isNotEmpty) {
                      contactCtrl.mobileNumber = false;
                    }
                    contactCtrl.update();
                  },
                  onInputValidated: (bool value) {
                    contactCtrl.isCorrect = value;
                    contactCtrl.update();

                  },
                  selectorConfig: const SelectorConfig(
                      leadingPadding: 0,
                      trailingSpace: false,
                      selectorType: PhoneInputSelectorType.BOTTOM_SHEET),
                  selectorButtonOnErrorPadding: 0,
                  ignoreBlank: false,
                  autoValidateMode: AutovalidateMode.disabled,
                  selectorTextStyle: TextStyle(color: appCtrl.appTheme.txt),
                  initialValue: contactCtrl.number,

                  textFieldController: contactCtrl.phoneController,
                  scrollPadding: EdgeInsets.zero,
                  formatInput: false,

                  inputDecoration: InputDecoration(
                    filled: true,
                    border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.circular(AppRadius.r8)),
                    fillColor: const Color.fromRGBO(153, 158, 166, .1),
                  ),
                  keyboardType: const TextInputType.numberWithOptions(
                      signed: true, decimal: true),
                  inputBorder: OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.circular(AppRadius.r8)),
                  onSaved: (PhoneNumber number) {})),
            if (contactCtrl.isExist || contactCtrl.isExistInApp)
              Column(
                children: [
                  const VSpace(Sizes.s15),
                  Text(contactCtrl.isExist
                      ? fonts.alreadyInContact.tr
                      : fonts.userNotInChatify.tr,style: AppCss.poppinsMedium14.textColor(appCtrl.appTheme.txt),),
                  const VSpace(Sizes.s15),
                ],
              ),
            const VSpace(Sizes.s50),
            CommonButton(title: fonts.addContact.tr,onTap: () => contactCtrl.onContactSave(),style: AppCss.poppinsMedium14.textColor(appCtrl.appTheme.white),margin: 0,)
          ],
        ).paddingSymmetric(horizontal: Insets.i20),
      );
    });
  }
}
