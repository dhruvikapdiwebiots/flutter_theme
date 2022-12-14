import '../../../config.dart';

class GroupChat extends StatelessWidget {
  final groupChatCtrl = Get.put(GroupChatController());
  GroupChat({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<GroupChatController>(
      builder: (_) {
        return GetBuilder<MessageController>(builder: (chatCtrl) {
          return WillPopScope(
            onWillPop: () async {
              groupChatCtrl.selectedContact = [];
              groupChatCtrl.update();
              return true;
            },
            child: Scaffold(
              appBar: AppBar(
                centerTitle: false,
                // leadingWidth: 40,
                title: Text(fonts.selectContacts.tr,
                    style: AppCss.poppinsMedium18.textColor(appCtrl.appTheme.whiteColor)),
              ),
              floatingActionButton: groupChatCtrl.selectedContact.isNotEmpty
                  ? FloatingActionButton(
                onPressed: () => groupChatCtrl.addGroupBottomSheet(),
                backgroundColor: appCtrl.appTheme.primary,
                child: const Icon(Icons.arrow_right_alt),
              )
                  : Container(),
              body: SafeArea(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (groupChatCtrl.selectedContact.isNotEmpty)
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children:
                            chatCtrl.selectedContact.asMap().entries.map((e) {
                              return Stack(
                                children: [
                                  Container(
                                    width: 90,
                                    padding:
                                    const EdgeInsets.fromLTRB(11, 10, 12, 10),
                                    child: Column(
                                      children: [
                                        CachedNetworkImage(
                                            imageUrl: e.value["image"].toString(),
                                            imageBuilder: (context,
                                                imageProvider) =>
                                                CircleAvatar(
                                                  backgroundColor:
                                                  const Color(0xffE6E6E6),
                                                  radius: 30,
                                                  backgroundImage: NetworkImage(
                                                      e.value["image"].toString()),
                                                ),
                                            placeholder: (context, url) =>
                                                const CircleAvatar(
                                                  backgroundColor:
                                                  Color(0xffE6E6E6),
                                                  radius: 30,
                                                  child: Icon(
                                                    Icons.person,
                                                    color: Color(0xffCCCCCC),
                                                  ),
                                                ),
                                            errorWidget: (context, url, error) =>
                                                const CircleAvatar(
                                                  backgroundColor:
                                                  Color(0xffE6E6E6),
                                                  radius: 30,
                                                  child: Icon(
                                                    Icons.person,
                                                    color: Color(0xffCCCCCC),
                                                  ),
                                                )),
                                        const SizedBox(
                                          height: 7,
                                        ),
                                        Text(
                                          e.value["name"].toString(),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                  Positioned(
                                    right: 17,
                                    top: 5,
                                    child: new InkWell(
                                      onTap: () {
                                        groupChatCtrl.selectedContact.remove(e.value);
                                        groupChatCtrl.update();
                                      },
                                      child: new Container(
                                        width: 20.0,
                                        height: 20.0,
                                        padding: const EdgeInsets.all(2.0),
                                        decoration: new BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.black,
                                        ),
                                        child: const Icon(
                                          Icons.close,
                                          size: 14,
                                          color: Colors.white,
                                        ),
                                      ), //............
                                    ),
                                  )
                                ],
                              );
                            }).toList(),
                          ),
                        ),
                      if (groupChatCtrl.contactList.isNotEmpty)
                        Column(
                          children: [
                            ...groupChatCtrl.contactList.asMap().entries.map((e) {
                              return ListTile(
                                onTap: () {
                                  if (groupChatCtrl.selectedContact.contains(e.value)) {
                                    groupChatCtrl.selectedContact.remove(e.value);
                                  } else {
                                    groupChatCtrl.selectedContact.add(e.value);
                                  }
                                  groupChatCtrl.update();
                                },
                                trailing: Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                          color: appCtrl.appTheme.borderGray,
                                          width: 1),
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    child: Icon(
                                      groupChatCtrl.selectedContact.contains(e.value)
                                          ? Icons.check
                                          : null,
                                      size: 19.0,
                                    )),
                                leading: (e.value["image"] != null &&
                                    e.value["image"]!.length > 0)
                                    ? CircleAvatar(
                                    backgroundImage:
                                    NetworkImage(e.value["image"]!))
                                    : CircleAvatar(child: Text(e.value["name"][0])),
                                title: Text(e.value["name"] ?? ""),
                                subtitle: Text(e.value["phone"] ?? ""),
                              );
                            }).toList()
                          ],
                        )
                    ],
                  ),
                ),
              ),
            ),
          );
        });
      }
    );
  }
}
