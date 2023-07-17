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
            .doc(id)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.data != null) {
            if (!snapshot.data!.exists) {

              return Stack(children: [
                CommonAssetImage(
                    height: isImageLayout ? Sizes.s40 : Sizes.s48,
                    width: isImageLayout ? Sizes.s40 : Sizes.s48),
                if (isLastSeen)
                  if ((snapshot.data!).data()!["status"] != "Offline")
                    const Positioned(right: 3, bottom: 10, child: IconCircle())
              ]);
            } else {
              return Stack(children: [
                CommonImage(
                    height: isImageLayout ? Sizes.s40 : Sizes.s48,
                    width: isImageLayout ? Sizes.s40 : Sizes.s48,
                    image: (snapshot.data!).data()!["image"] ?? "",
                    name: (snapshot.data!).data()!["name"] ?? ""),
                if (isLastSeen)
                  if ((snapshot.data!).data()!["status"] != "Offline")
                    const Positioned(right: -2, bottom: 0, child: IconCircle())
              ]);
            }
          } else {
            return Stack(children: [
              CommonAssetImage(
                  height: isImageLayout ? Sizes.s40 : Sizes.s48,
                  width: isImageLayout ? Sizes.s40 : Sizes.s48),
            ]);
          }
        });
  }
}
