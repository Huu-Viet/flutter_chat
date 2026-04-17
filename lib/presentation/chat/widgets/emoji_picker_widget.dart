import 'package:flutter/material.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/foundation.dart' as foundation;

class EmojiPickerWidget extends StatelessWidget {
  final Function(String) onEmojiSelected;

  const EmojiPickerWidget({
    super.key,
    required this.onEmojiSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 300,
      child: EmojiPicker(
        onEmojiSelected: (Category? category, Emoji emoji) {
          onEmojiSelected(emoji.emoji);
        },
        config: Config(
          height: 256,
          checkPlatformCompatibility: true,
          emojiViewConfig: EmojiViewConfig(
            emojiSizeMax: 28 *
                (foundation.defaultTargetPlatform == TargetPlatform.iOS
                    ? 1.20
                    : 1.0),
            backgroundColor: const Color(0xFFF2F2F2),
            columns: 7,
            verticalSpacing: 0,
            horizontalSpacing: 0,
            gridPadding: EdgeInsets.zero,
            recentsLimit: 28,
            replaceEmojiOnLimitExceed: false,
          ),
          skinToneConfig: const SkinToneConfig(),
          categoryViewConfig: const CategoryViewConfig(),
          bottomActionBarConfig: const BottomActionBarConfig(
            enabled: false,
          ),
          searchViewConfig: const SearchViewConfig(
            backgroundColor: Color(0xFFF2F2F2),
          ),
        ),
      ),
    );
  }
}
