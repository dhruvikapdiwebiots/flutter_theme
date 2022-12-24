import 'dart:io';

import '../../../../config.dart';

class CurrentUserStatus extends StatelessWidget {
  final String? currentUserId;

  const CurrentUserStatus({Key? key, this.currentUserId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('status')
            .where("phoneNumber", isEqualTo: currentUserId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.data != null) {
            if (!snapshot.data!.docs.isNotEmpty) {
              return CurrentUserEmptyStatus(onTap: () async {
                File? pickedImage = await pickImageFromGallery(context);
                if (pickedImage != null) {
                  Get.toNamed(routeName.confirmationScreen,
                      arguments: pickedImage);
                }
              });
            } else {
              return StatusLayout(snapshot: snapshot);
            }
          } else {
            return CurrentUserEmptyStatus(onTap: () async {
              File? pickedImage = await pickImageFromGallery(context);
              if (pickedImage != null) {
                Get.toNamed(routeName.confirmationScreen,
                    arguments: pickedImage);
              }
            });
          }
        });
  }
}
