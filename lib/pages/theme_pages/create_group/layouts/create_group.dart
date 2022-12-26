import 'dart:developer';
import 'dart:io';

import '../../../../config.dart';

class CreateGroup extends StatelessWidget {
  const CreateGroup({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
      return GetBuilder<CreateGroupController>(builder: (groupCtrl) {
        return Stack(
          children: [
            Padding(
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom),
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
                                          .imagePickerOption(context);
                                    })
                                  : Container(
                                      height: Sizes.s60,
                                      width: Sizes.s60,
                                      alignment: Alignment.center,
                                      padding: const EdgeInsets.all(Insets.i15),
                                      decoration: BoxDecoration(
                                          color: appCtrl.appTheme.gray
                                              .withOpacity(.2),
                                          image: DecorationImage(
                                              image:
                                                  AssetImage(imageAssets.user),
                                              fit: BoxFit.fill),
                                          shape: BoxShape.circle),
                                    ).inkWell(
                                      onTap: () => groupCtrl.pickerCtrl
                                          .imagePickerOption(context)),
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
                                          color: appCtrl.appTheme.primary)),
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
                            onTap: () async {
                              groupCtrl.isLoading = true;
                              groupCtrl.imageFile =
                                  groupCtrl.pickerCtrl.imageFile;
                              if (groupCtrl.imageFile != null) {
                                await groupCtrl.uploadFile();
                              }
                              groupCtrl.update();
                              final now = DateTime.now();
                              String id = now.microsecondsSinceEpoch.toString();

                              final user = appCtrl.storage.read("user");
                              await Future.delayed(Durations.s3);
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
                              });

                              FirebaseFirestore.instance
                                  .collection('groupMessage')
                                  .doc(id)
                                  .collection("chat")
                                  .add({
                                'sender': user["id"],
                                'senderName': user["name"],
                                'receiver': groupCtrl.selectedContact,
                                'content': "${user["name"]} created this group",
                                "groupId": id,
                                'type': MessageType.messageType.name,
                                'messageType': "sender",
                                "status": "",
                                'timestamp': DateTime.now()
                                    .millisecondsSinceEpoch
                                    .toString(),
                              });
                              groupCtrl.selectedContact.add(user);
                              await FirebaseFirestore.instance
                                  .collection("groups")
                                  .doc(id)
                                  .get()
                                  .then((value) async {
                                await FirebaseFirestore.instance
                                    .collection('contacts')
                                    .add({
                                  'sender': {
                                    "id": user['id'],
                                    "name": user['name'],
                                    "phone": user["phone"]
                                  },
                                  'receiver': null,
                                  'group': {
                                    "id": value.id,
                                    "name": groupCtrl.txtGroupName.text,
                                    "image": groupCtrl.imageUrl,
                                  },
                                  'receiverId': groupCtrl.selectedContact,
                                  'senderPhone': user["phone"],
                                  'timestamp': DateTime.now()
                                      .millisecondsSinceEpoch
                                      .toString(),
                                  "lastMessage": "",
                                  "isGroup": true,
                                  "groupId": value.id,
                                  "updateStamp": DateTime.now()
                                      .millisecondsSinceEpoch
                                      .toString()
                                }).then((value) {
                                  groupCtrl.selectedContact = [];
                                  groupCtrl.txtGroupName.text = "";
                                  groupCtrl.update();
                                  Get.back();
                                  Get.back();
                                });
                              });
                            },
                          )
                        ]),
                  )),
            ),
            if (groupCtrl.isLoading)
              LoginLoader(
                isLoading: groupCtrl.isLoading,
              )
          ],
        );
      });
    });
  }
}
