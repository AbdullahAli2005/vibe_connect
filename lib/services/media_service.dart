import 'dart:io';

import 'package:image_picker/image_picker.dart';

class MediaService {
  static MediaService instance = MediaService();

  Future<File?> getImageFromLibrary() async {
    final XFile? xfile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (xfile != null) {
      return File(xfile.path);
    }
    return null;
  }
}
