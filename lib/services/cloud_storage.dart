import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart';
import 'package:http/http.dart' as http;

class CloudinaryService {
  static const String cloudName = "aaaaa"; // Replace with your Cloudinary Cloud Name
  static const String uploadPreset = "folder"; // Replace with your Upload Preset

  static Future<String?> uploadImage(File image) async {
    try {
      String url = "https://api.cloudinary.com/v1_1/$cloudName/image/upload";

      var request = http.MultipartRequest('POST', Uri.parse(url))
        ..fields['upload_preset'] = uploadPreset
        ..files.add(await http.MultipartFile.fromPath('file', image.path));

      var response = await request.send();
      if (response.statusCode == 200) {
        var responseData = await response.stream.bytesToString();
        var jsonResponse = jsonDecode(responseData);
        return jsonResponse['secure_url']; // URL of the uploaded image
      } else {
        print("Failed to upload image: ${response.reasonPhrase}");
        return null;
      }
    } catch (e) {
      print("Error uploading image: $e");
      return null;
    }
  }

  static Future<String?> uploadMediaMessage(String uid, File file) async {
    try {
      String url = "https://api.cloudinary.com/v1_1/$cloudName/image/upload";

      var timestamp = DateTime.now().millisecondsSinceEpoch;
      String fileName = "${basename(file.path)}_$timestamp"; // Add timestamp to filename

      var request = http.MultipartRequest('POST', Uri.parse(url))
        ..fields['upload_preset'] = uploadPreset
        ..fields['public_id'] = "messages/$uid/images/$fileName" // Cloudinary folder structure
        ..files.add(await http.MultipartFile.fromPath('file', file.path));

      var response = await request.send();
      if (response.statusCode == 200) {
        var responseData = await response.stream.bytesToString();
        var jsonResponse = jsonDecode(responseData);
        return jsonResponse['secure_url']; // Return Cloudinary URL of uploaded file
      } else {
        print("Failed to upload media message: ${response.reasonPhrase}");
        return null;
      }
    } catch (e) {
      print("Error uploading media message: $e");
      return null;
    }
  }
}
