import 'dart:developer';


import 'package:contacts_service/contacts_service.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';

import '../../config.dart';

class NewContactController extends GetxController {
  TextEditingController emailController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  GlobalKey<FormState> profileGlobalKey = GlobalKey<FormState>();
  String? dialCode;
  bool nameValidation = false,emailValidate=false,isCorrect = false;
  bool isExist = false,isExistInApp =false;
  bool mobileNumber = false;
  PhoneNumber number = PhoneNumber(dialCode: "+91", isoCode: 'IN');



  final FocusNode nameFocus = FocusNode();
  final FocusNode emailFocus = FocusNode();

  @override
  void onReady() {
    final String systemLocales =
        WidgetsBinding.instance.platformDispatcher.locale.countryCode!;
    List country =  appArray.countryList;
    int index =
        country.indexWhere((element) => element['alpha_2_code'] == systemLocales);
    dialCode = country[index]['dial_code'];
    update();
    log("DIAL : $dialCode");
    update();

    // TODO: implement onReady
    super.onReady();
  }

  onContactSave() async {
    FocusScope.of(Get.context!).requestFocus(FocusNode());
    Contact contact = Contact(
        displayName: nameController.text,
        givenName: nameController.text,
        androidAccountName: nameController.text,
        emails: [
          Item(label: "personal", value: emailController.text)
        ],
        phones: [
          Item(label: "mobile", value: "$dialCode${phoneController.text}")
        ]);
    log("contact: $contact");

    // await ContactsService.addContact(contact);
    await ContactsService.getContactsForPhone(phoneController.text)
        .then((value) async {
      log("COOOO : $value");
      if (value.isNotEmpty) {
        isExist = true;
      } else {
        await FirebaseFirestore.instance
            .collection(collectionName.users)
            .where("phone", isEqualTo: "$dialCode${phoneController.text}")
            .get()
            .then((user) {
          log("CHECK : ${user.docs.length}");
          if(user.docs.isNotEmpty){
            isExistInApp = false;
          }else{
            isExistInApp =true;
          }
        });
        isExist = false;
        await ContactsService.addContact(contact);
        Get.back();
      }
      update();
    });

  }
}
