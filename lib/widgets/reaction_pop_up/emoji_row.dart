import 'dart:developer';

import 'package:flutter_theme/widgets/reaction_pop_up/emoji_picker_widget.dart';
import 'package:flutter_theme/widgets/reaction_pop_up/reaction_config.dart';

import '../../config.dart';

class EmojiRow extends StatelessWidget {
  EmojiRow({
    Key? key,
    required this.onEmojiTap,
    this.emojiConfiguration,
  }) : super(key: key);

  /// Provides callback when user taps on emoji in reaction pop-up.
  final StringCallback onEmojiTap;

  /// Provides configuration of emoji's appearance in reaction pop-up.
  final EmojiConfiguration? emojiConfiguration;

  /// These are default emojis.
  final List<String> _emojiUnicodes = [
    heart,
    faceWithTears,
    astonishedFace,
    disappointedFace,
    angryFace,
    thumbsUp,
  ];

  @override
  Widget build(BuildContext context) {
    final emojiList = emojiConfiguration?.emojiList ?? _emojiUnicodes;
    final size = emojiConfiguration?.size;
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(
                    emojiList.length,
                    (index) => GestureDetector(
                        onTap: (){
                          onEmojiTap(emojiList[index]);
                          log("CHECK `:${emojiList[index]}");
                        },
                        child: Text(
                          emojiList[index],
                          style: const TextStyle(fontSize: FontSizes.f16),
                        )))),
          ),
          InkWell(
            child: Icon(
              Icons.add,
              color: Colors.grey.shade600,
              size: 18,
            ),
            onTap: () => _showBottomSheet(context),
          ).paddingAll(Insets.i2).decorated(
              color: appCtrl.appTheme.lightGray, shape: BoxShape.circle)
        ],
      ),
    );
  }

  void _showBottomSheet(BuildContext context) => showModalBottomSheet<void>(
        context: context,
        builder: (context) => EmojiPickerWidget(onSelected: (emoji) {
          Navigator.pop(context);
          log("emoji : ${emoji.codeUnits}");
          log("emoji : ${emoji.characters}");
          onEmojiTap(emoji);
        }),
      );
}
