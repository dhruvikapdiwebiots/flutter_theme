
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_theme/config.dart';
import 'package:fluttercontactpicker/fluttercontactpicker.dart';

class Message extends StatelessWidget {
  final messageCtrl= Get.put(MessageController());
   Message({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<MessageController>(
      builder: (_) {
        return WillPopScope(
          onWillPop:messageCtrl.onWillPop,
          child: Scaffold(
              key: messageCtrl.scaffoldKey,
              floatingActionButton: FloatingActionButton(
                onPressed: ()async {
                  // Add your onPressed code here!
                  final granted = await FlutterContactPicker.hasPermission();
                  print(granted);
                  if(granted) {
                    final FullContact contact =
                    (await FlutterContactPicker.pickFullContact());
                    messageCtrl.contact = contact.toString();
                    messageCtrl.contactPhoto = contact.photo?.asWidget();
                    messageCtrl.update();
                    print(contact);
                  }else{
                    final granted = await FlutterContactPicker.requestPermission().then((value)async {
                      final FullContact contact =
                      (await FlutterContactPicker.pickFullContact());
                      messageCtrl.contact = contact.toString();
                      messageCtrl.contactPhoto = contact.photo?.asWidget();
                      messageCtrl.update();
                      print(contact);
                    });
                    print(granted);
                  }
                },
                backgroundColor: appCtrl.appTheme.primary,
                child: const Icon(Icons.message),
              ),
              body: SafeArea(
                  child: Stack(fit: StackFit.expand, children: <Widget>[
                    SingleChildScrollView(
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height - 50,
                        decoration: BoxDecoration(color: appCtrl.appTheme.accent),
                        child: StreamBuilder(
                          stream:
                          FirebaseFirestore.instance.collection('users').snapshots(),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return Center(
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(appCtrl.appTheme.primary),
                                ),
                              );
                            } else {
                              return ListView.builder(
                                padding: EdgeInsets.all(10.0),
                                itemBuilder: (context, index) =>
                                    messageCtrl.loadUser(context, (snapshot.data!).docs[index]),
                                itemCount: (snapshot.data!).docs.length,
                              );
                            }
                          },
                        ),
                      ),
                    ),

                  ]))),
        );
      }
    );
  }
}
