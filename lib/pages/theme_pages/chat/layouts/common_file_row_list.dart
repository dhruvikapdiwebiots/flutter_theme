import 'package:flutter_theme/pages/theme_pages/chat/layouts/icon_creation.dart';

import '../../../../../../config.dart';

class CommonFileRowList extends StatelessWidget {
  const CommonFileRowList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children:const [
            IconCreation(
                icons: Icons.insert_drive_file,color: Colors.indigo, text:"Document"),
             HSpace(Sizes.s40),
            IconCreation(icons:Icons.camera_alt, color:Colors.pink,  text:"Camera"),
             HSpace(Sizes.s40),
            IconCreation(icons:Icons.insert_photo,color: Colors.purple,  text:"Gallery"),
          ],
        ),
        const VSpace(Sizes.s30),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children:const [
            IconCreation(icons:Icons.headset,color: Colors.orange, text: "Audio"),
             HSpace(Sizes.s40),
            IconCreation(icons:Icons.location_pin,color:Colors.teal, text: "Location"),
             HSpace(Sizes.s40),
            IconCreation(icons:Icons.person,color: Colors.blue,  text:"Contact"),
          ],
        ),
      ],
    );
  }
}
