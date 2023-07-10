import 'dart:developer';
import '../../../../config.dart';

class ImageLayout extends StatelessWidget {
  final String? id;
  final bool isLastSeen, isImageLayout;

  const ImageLayout(
      {Key? key, this.id, this.isLastSeen = true, this.isImageLayout = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {

    return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection(collectionName.users)
            .where("id", isEqualTo: id)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.data != null) {
            if (!snapshot.data!.docs.isNotEmpty) {
              return Stack(children: [
                CommonAssetImage(
                    height: isImageLayout ? Sizes.s40 : Sizes.s45,
                    width: isImageLayout ? Sizes.s40 : Sizes.s45),
                if (isLastSeen)
                  if ((snapshot.data!).docs[0]["status"] != "Offline")
                   const Positioned(
                        right: 3,
                        bottom: 10,
                        child: IconCircle())
              ]);
            } else {
              return Stack(children: [
                CommonImage(
                    height: isImageLayout ? Sizes.s40 : Sizes.s45,
                    width: isImageLayout ? Sizes.s40 : Sizes.s45,
                    image: (snapshot.data!).docs[0]["image"],
                    name: (snapshot.data!).docs[0]["name"]),
                if (isLastSeen)
                 const Positioned(
                      right: -2,
                      bottom: 0,
                      child: IconCircle())
              ]);
            }
          } else {
            return CommonAssetImage(
                height: isImageLayout ? Sizes.s40 : Sizes.s45,
                width: isImageLayout ? Sizes.s40 : Sizes.s45);
          }
        });
  }
}
