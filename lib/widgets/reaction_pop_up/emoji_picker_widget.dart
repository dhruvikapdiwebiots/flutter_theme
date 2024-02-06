import 'dart:io';

import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/foundation.dart';

import '../../config.dart';

class EmojiPickerWidget extends StatelessWidget {
  const EmojiPickerWidget({Key? key, required this.onSelected,this.textEditingController})
      : super(key: key);

  /// Provides callback when user selects emoji.
  final StringCallback onSelected;
  final TextEditingController? textEditingController;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 10, left: 15, right: 15),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      height: MediaQuery.of(context).size.height / 2,
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(bottom: 15),
            width: 35,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey,
              borderRadius: BorderRadius.circular(30),
            ),
          ),
          Expanded(
            child: EmojiPicker(
              textEditingController: textEditingController,
              onEmojiSelected: (category, emoji) => onSelected(emoji.emoji),

            ),
          ),
        ],
      ),
    );
  }
}
