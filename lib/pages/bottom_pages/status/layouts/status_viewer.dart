import '../../../../config.dart';

class StatusViewer extends StatelessWidget {
  final List? userList;

  const StatusViewer({Key? key, this.userList}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: appCtrl.appTheme.primary,
      ),
      body: Column(
        children: [
          ...userList!.asMap().entries.map((e) {
            return StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection(collectionName.users)
                    .doc(e.value["uid"])
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    e.value["image"] = snapshot.data!.data()!["image"];
                    e.value["name"] = snapshot.data!.data()!["name"];
                  }
                  return ListTile(
                      leading: CommonImage(
                          height: Sizes.s50,
                          width: Sizes.s50,
                          image: e.value["image"]?? "",
                          name: e.value["name"] ?? ""));
                });
          }).toList()
        ],
      ),
    );
  }
}
