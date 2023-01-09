
import 'package:story_view/story_view.dart';

import '../../../../config.dart';

class StatusScreenView extends StatefulWidget {
  static const String routeName = '/status-screen';
  const StatusScreenView({
    Key? key,
  }) : super(key: key);

  @override
  State<StatusScreenView> createState() => _StatusScreenViewState();
}

class _StatusScreenViewState extends State<StatusScreenView> {
  StoryController controller = StoryController();
  List<StoryItem> storyItems = [];
  Status? status;

  @override
  void initState() {
    super.initState();
    status = Get.arguments;
    setState(() {

    });
    initStoryPageItems();
  }

  void initStoryPageItems() {
    for (int i = 0; i < status!.photoUrl!.length; i++) {
      if (status!.photoUrl![i].statusType == StatusType.text.name) {
        int value = int.parse(status!.photoUrl![i].statusBgColor!, radix: 16);
        Color finalColor =  Color(value);
        storyItems.add(StoryItem.text(
            title: status!.photoUrl![i].statusText!,
            textStyle: TextStyle(
                color: appCtrl.appTheme.whiteColor,
                fontSize: 23,
                height: 1.6,
                fontWeight: FontWeight.w700),
            backgroundColor: finalColor
        ));
      } else if(status!.photoUrl![i].statusType == StatusType.video.name){
        storyItems.add(StoryItem.pageVideo(
            status!.photoUrl![i].image!,
            controller: controller),
        );
      } else {
        storyItems.add(StoryItem.pageImage(
          url: status!.photoUrl![i].image!,
          controller: controller,
        ));
      }
    }
    setState(() {
      
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: storyItems.isEmpty
          ? const CircularProgressIndicator()
          : StoryView(

        storyItems: storyItems,
        controller: controller,
        onVerticalSwipeComplete: (direction) {
          if (direction == Direction.down) {
            Navigator.pop(context);
          }
        },
      ),
    );
  }
}
