import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ImagePickerBottomSheet extends StatelessWidget {
  final Function(ImageSource) onSourceSelected;

  const ImagePickerBottomSheet({
    super.key,
    required this.onSourceSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Wrap(
        children: [
          ListTile(
            leading: const Icon(Icons.camera_alt),
            title: const Text('Máy ảnh'),
            onTap: () {
              Navigator.pop(context);
              onSourceSelected(ImageSource.camera);
            },
          ),
          ListTile(
            leading: const Icon(Icons.photo_library),
            title: const Text('Thư viện ảnh'),
            onTap: () {
              Navigator.pop(context);
              onSourceSelected(ImageSource.gallery);
            },
          ),
          ListTile(
            leading: const Icon(Icons.cancel),
            title: const Text('Hủy'),
            onTap: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  /// Helper method to show bottom sheet
  static Future<void> show(
      BuildContext context, {
        required Function(ImageSource) onSourceSelected,
      }) {
    return showModalBottomSheet(
      context: context,
      builder: (_) => ImagePickerBottomSheet(
        onSourceSelected: onSourceSelected,
      ),
    );
  }
}