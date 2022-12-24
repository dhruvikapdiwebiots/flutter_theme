
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
      storyItems.add(StoryItem.pageImage(
        url: status!.photoUrl![i].image!,
        controller: controller,
      ));
    }

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
