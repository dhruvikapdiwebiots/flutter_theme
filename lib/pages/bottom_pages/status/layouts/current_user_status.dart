import 'dart:io';

import 'package:flutter_theme/pages/bottom_pages/status/layouts/current_user_empty_status.dart';
import 'package:flutter_theme/pages/bottom_pages/status/layouts/status_layout.dart';

import '../../../../config.dart';

class CurrentUserStatus extends StatelessWidget {
  final String? currentUserId;

  const CurrentUserStatus({Key? key, this.currentUserId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('status').where("phoneNumber",isEqualTo: currentUserId)
        
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.data != null) {
            if (!snapshot.data!.docs.isNotEmpty) {
              return CurrentUserEmptyStatus(onTap: ()async {
                File? pickedImage = await pickImageFromGallery(context);
                if (pickedImage != null) {
                  Get.toNamed(routeName.confirmationScreen,
                      arguments: pickedImage);
                }
              });
            } else {
              return StatusLayout(snapshot: snapshot) ;
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
