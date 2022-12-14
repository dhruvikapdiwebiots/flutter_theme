import 'dart:developer';
import 'dart:io';

import '../../../../config.dart';

class CreateGroup extends StatelessWidget {
  const CreateGroup({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
      return GetBuilder<GroupChatController>(builder: (groupCtrl) {
        return Padding(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Container(
              padding: const EdgeInsets.all(16),
              height: MediaQuery.of(context).size.height / 2.2,
              child: Form(
                key: groupCtrl.formKey,
                child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(
                        height: 15,
                      ),
                      const Padding(
                        padding: EdgeInsets.only(left: 8),
                        child: Text(
                          'setgroup',
                          textAlign: TextAlign.left,
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16.5),
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Row(
                        children: [
                          groupCtrl.pickerCtrl.image != null
                              ? Container(
                                  height: Sizes.s60,
                                  width: Sizes.s60,
                                  child: Image.file(groupCtrl.pickerCtrl.image!,
                                          fit: BoxFit.fill)
                                      .clipRRect(all: AppRadius.r50),
                                  decoration: BoxDecoration(
                                      color:
                                          appCtrl.appTheme.gray.withOpacity(.2),
                                      shape: BoxShape.circle),
                                ).inkWell(onTap: () {
                                  groupCtrl.pickerCtrl
                                      .imagePickerOption(context);
                                })
                              : Container(
                                  height: Sizes.s60,
                                  width: Sizes.s60,
                                  alignment: Alignment.center,
                                  padding: const EdgeInsets.all(Insets.i15),
                                  decoration: BoxDecoration(
                                      color:
                                          appCtrl.appTheme.gray.withOpacity(.2),
                                      image: DecorationImage(
                                          image: AssetImage(imageAssets.user),
                                          fit: BoxFit.fill),
                                      shape: BoxShape.circle),
                                ).inkWell(
                                  onTap: () => groupCtrl.pickerCtrl
                                      .imagePickerOption(context)),
                          const HSpace(Sizes.s15),
                          Expanded(
                            child: CommonTextBox(
                              controller: groupCtrl.txtGroupName,
                              labelText: "Group Name",
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
                                      color: appCtrl.appTheme.primary)),
                              textInputAction: TextInputAction.next,
                            ),
                          ),
                        ],
                      ),
                      const VSpace(Sizes.s20),
                      CommonButton(
                        title: "Create",
                        style: AppCss.poppinsMedium14
                            .textColor(appCtrl.appTheme.whiteColor),
                        margin: 0,
                        onTap: () async {
                          groupCtrl.imageFile = groupCtrl.pickerCtrl.imageFile;
                          groupCtrl.update();
                          final now = DateTime.now();
                          String id = now.microsecondsSinceEpoch.toString();
                          await groupCtrl.uploadFile();
                          final user = appCtrl.storage.read("user");

                          await FirebaseFirestore.instance
                              .collection('groups')
                              .doc(id)
                              .set({
                            "name": groupCtrl.txtGroupName.text,
                            "image": groupCtrl.imageUrl,
                            "groupTypeNotification": "new_added",
                            "users": groupCtrl.selectedContact,
                            "groupId": id,
                            "createdBy": user,
                            'timestamp': DateTime.now()
                                .millisecondsSinceEpoch
                                .toString(),
                            // I dont know why you called it just timestamp i changed it on created and passed an function with serverTimestamp()
                          });

                          await FirebaseFirestore.instance
                              .collection("contacts")
                              .doc(id)
                              .get()
                              .then((value) async {
                            log("group : ${value.data()}");
                            await FirebaseFirestore.instance
                                .collection('contacts')
                                .add({
                              'sender': user,
                              'receiver': null,
                              'group': {
                                "id": value.id,
                                "name": groupCtrl.txtGroupName.text,
                                "image": groupCtrl.imageUrl
                              },
                              'receiverId': groupCtrl.selectedContact,
                              'senderId': user["id"],
                              'timestamp': DateTime.now()
                                  .millisecondsSinceEpoch
                                  .toString(),
                              "lastMessage": "new_added",
                              "isGroup": true,
                              "groupId": value.id,
                              "updateStamp": DateTime.now()
                                  .millisecondsSinceEpoch
                                  .toString()
                            });

                            groupCtrl.selectedContact = [];
                            groupCtrl.imageUrl = "";
                            groupCtrl.imageFile = null;
                            groupCtrl.image = null;
                            groupCtrl.txtGroupName.text = "";
                            groupCtrl.update();
                            Get.back();
                            Get.back();
                          });
                        },
                      )
                    ]),
              )),
        );
      });
    });
  }
}
