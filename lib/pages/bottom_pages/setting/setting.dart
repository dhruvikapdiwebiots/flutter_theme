import 'package:flutter_theme/config.dart';

class Setting extends StatelessWidget {
  const Setting({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: appCtrl.appTheme.primary,
        automaticallyImplyLeading: false,
        title: Text("Settings"),
      ),
      body: Column(
        children: [
          Row(
            children: [
              Container(
                height: Sizes.s60,
                width: Sizes.s60,
                alignment: Alignment.center,
                padding: EdgeInsets.all(Insets.i15),
                decoration: BoxDecoration(
                    color: appCtrl.appTheme.secondary, shape: BoxShape.circle),
                child: Text('d',
                    style: AppCss.poppinsblack28
                        .textColor(appCtrl.appTheme.accent)),
              ),
              const HSpace(Sizes.s20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start  ,
                children: [
                  Text('dhruvi kapdi',style: AppCss.poppinsblack16.textColor(appCtrl.appTheme.blackColor),),
                  const VSpace(Sizes.s10),
                  Text('Hello I am using Chatter',style: AppCss.poppinsMedium14.textColor(appCtrl.appTheme.grey)),
                  
                ],
              )
            ],
          ),
          const VSpace(Sizes.s20),
          ListTile(
            minLeadingWidth: 0,
            title: Text("Chats"),
            leading: Icon(Icons.message),
          ),
          ListTile(
            minLeadingWidth: 0,
            title: Text("Delete Account"),
            leading: Icon(Icons.delete),
          ),
          ListTile(
            minLeadingWidth: 0,
            title: Text("Logot"),
            leading: Icon(Icons.logout),
          ),
          ListTile(
            minLeadingWidth: 0,
            title: Text("Invite friend"),
            leading: Icon(Icons.supervised_user_circle_sharp),
          ),

        ],
      ).paddingSymmetric(horizontal: Insets.i15,vertical: Insets.i20),
    );
  }
}
