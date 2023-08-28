import 'dart:developer';


import 'package:flutter_theme/controllers/fetch_contact_controller.dart';

import '../../../../config.dart';

class AllRegisteredContact extends StatelessWidget {
  final GestureTapCallback? onTap;
  final bool? isExist;
  final RegisterContactDetail? data;

  const AllRegisteredContact({Key? key, this.onTap, this.data, this.isExist})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    log("data : $data}");
    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection(collectionName.users).doc(data!.id).snapshots(),
      builder: (context,snapshot) {
       if(snapshot.hasData){
         return ListTile(
           onTap: onTap,
           trailing: Container(
               decoration: BoxDecoration(
                 border: Border.all(color: appCtrl.appTheme.borderGray, width: 1),
                 borderRadius: BorderRadius.circular(5),
               ),
               child: Icon(
                 isExist! ? Icons.check : null,
                 size: 19.0,
               )),
           leading: CommonImage(image: snapshot.data!.data()!["image"] , name: data!.name),
           title: Text(data!.name ?? ""),
           subtitle: Text(snapshot.data!.data()!["statusDesc"] ?? ""),
         );
       }else{
         return Container();
       }
      }
    );
  }
}
