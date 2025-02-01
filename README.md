# VibeConnect 💬🚀

**VibeConnect** is a real-time chat application built using **Flutter**, **Firebase**, and **Cloudinary**. It provides a seamless and interactive messaging experience with secure authentication, media sharing, and a responsive UI.

---

## ✨ Features

- 🔐 **Secure Authentication** – Firebase authentication for user login and signup.
- ⚡ **Real-Time Messaging** – Instantly send and receive messages with Firestore database.
- 📂 **Cloud-Based Storage** – Cloudinary integration for high-quality media uploads and optimization.
- 🖼️ **Profile Customization** – Users can upload profile pictures and update display names.
- 📱 **Responsive UI** – Optimized for both Android and iOS devices with a smooth user experience.
- 🔔 **Push Notifications** – Get notified instantly when you receive a message.
- 🌙 **Dark Mode Support** – Toggle between light and dark themes for better usability.

---

## 🛠️ Tech Stack

- **Frontend:** Flutter (Dart)
- **Backend:** Firebase Authentication, Firestore Database
- **Cloud Storage:** Cloudinary
- **State Management:** Provider / Riverpod (optional)
- **Push Notifications:** Firebase Cloud Messaging (FCM)

---

## 📸 Screenshots

*(Add screenshots of your app here)*

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK installed
- Firebase project set up
- Cloudinary account with an upload preset

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/vibeconnect.git
   cd vibeconnect
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Set up Firebase**
   - Create a Firebase project and add `google-services.json` (Android) & `GoogleService-Info.plist` (iOS).
   - Enable Firestore and Authentication in the Firebase Console.

4. **Configure Cloudinary**
   - Sign up on Cloudinary and get your **Cloud Name**.
   - Replace the placeholder in `CloudinaryService.dart` with your Cloud Name and Upload Preset.

5. **Run the app**
   ```bash
   flutter run
   ```

---

## 🛠️ API Integration

### Upload Image to Cloudinary
```dart
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CloudinaryService {
  static const String cloudName = "your-cloud-name";
  static const String uploadPreset = "your-upload-preset";

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
        return jsonResponse['secure_url'];
      } else {
        return null;
      }
    } catch (e) {
      print("Error: $e");
      return null;
    }
  }
}
```

---

## 📜 License
This project is licensed under the MIT License. Feel free to use and modify it.

---

## 🤝 Contributing
Contributions, issues, and feature requests are welcome! Feel free to check the [issues page](https://github.com/yourusername/vibeconnect/issues).

---

## 🔗 Connect with Me
- 📧 Email: smabd7409@gmail.com
- 🔗 LinkedIn: https://www.linkedin.com/in/abdullah-ali-44a892330

---

### ⭐ Don't forget to **star** the repository if you found this helpful! ⭐
