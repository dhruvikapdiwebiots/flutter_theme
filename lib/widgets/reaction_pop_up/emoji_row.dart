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
    return Row(
      children: [
        Expanded(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(
              emojiList.length,
                  (index) => GestureDetector(
                onTap: () => onEmojiTap(emojiList[index]),
                child: Text(
                  emojiList[index],
                  style: const TextStyle(fontSize: FontSizes.f16),
                ),
              ),
            ),
          ),
        ),
        IconButton(
          constraints: const BoxConstraints(),
          icon: Icon(
            Icons.add,
            color: Colors.grey.shade600,
            size: 28,
          ),
          onPressed: () => _showBottomSheet(context),
        ),
      ],
    );
  }

  void _showBottomSheet(BuildContext context) => showModalBottomSheet<void>(
    context: context,
    builder: (context) => EmojiPickerWidget(onSelected: (emoji) {
      Navigator.pop(context);
      log("emoji : $emoji");
      onEmojiTap(emoji);
    }),
  );
}