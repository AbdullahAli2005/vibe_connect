// // ignore_for_file: no_leading_underscores_for_local_identifiers

// // Auth provider mai line 32 ka error nikal

// import 'package:firebase_core/firebase_core.dart';
// import 'package:flutter/material.dart';
// import 'package:vibe_connect/pages/home_page.dart';
// import 'package:vibe_connect/pages/login_page.dart';

// import 'pages/registration_page.dart';
// import 'services/conversation_service.dart';
// import 'services/navigation_service.dart';

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized(); // Ensure Flutter binding is initialized
//   await Firebase.initializeApp(); // Initialize Firebase
//   runApp(const MyApp());
//   final conversationService = ConversationService();
//   conversationService.listenForNewConversations();
//   conversationService.listenForConversationUpdates();
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'VibeConnect',
//       navigatorKey: NavigationService.instance.navigatorKey,
//       debugShowCheckedModeBanner: false,
//       theme: ThemeData(
//         brightness: Brightness.dark,
//         primaryColor: const Color.fromRGBO(42, 117, 188, 1),
//         hintColor: const Color.fromRGBO(42, 117, 188, 1),
//         colorScheme: const ColorScheme(
//           brightness: Brightness.dark,
//           primary: Color.fromRGBO(42, 117, 188, 1),
//           onPrimary: Colors.white,
//           secondary: Color.fromRGBO(42, 117, 188, 1),
//           onSecondary: Colors.white,
//           error: Colors.red,
//           onError: Colors.white,
//           surface: Color.fromRGBO(28, 27, 27, 1),
//           onSurface: Colors.white,
//         ),
//       ),
//       initialRoute: "login",
//       routes: {
//         "login": (BuildContext _context) => const LoginPage(),
//         "register": (BuildContext _context) => const RegistrationPage(),
//         "home": (BuildContext _context) => const HomePage(),
//       },
//     );
//   }
// }


import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vibe_connect/pages/login_page.dart';
import 'package:vibe_connect/pages/home_page.dart';
import 'package:vibe_connect/pages/registration_page.dart';
import 'package:vibe_connect/services/navigation_service.dart';
import 'package:vibe_connect/services/conversation_service.dart';
import 'package:vibe_connect/providers/auth_provider.dart';
import 'pages/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Ensure Flutter binding is initialized
  await Firebase.initializeApp(); // Initialize Firebase

  runApp(const MyApp());

  final conversationService = ConversationService();
  conversationService.listenForNewConversations();
  conversationService.listenForConversationUpdates();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<AuthProvider>(
      create: (_) => AuthProvider.instance,
      child: MaterialApp(
        title: 'VibeConnect',
        navigatorKey: NavigationService.instance.navigatorKey,
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          brightness: Brightness.dark,
          primaryColor: const Color.fromRGBO(42, 117, 188, 1),
          hintColor: const Color.fromRGBO(42, 117, 188, 1),
          colorScheme: const ColorScheme(
            brightness: Brightness.dark,
            primary: Color.fromRGBO(42, 117, 188, 1),
            onPrimary: Colors.white,
            secondary: Color.fromRGBO(42, 117, 188, 1),
            onSecondary: Colors.white,
            error: Colors.red,
            onError: Colors.white,
            surface: Color.fromRGBO(28, 27, 27, 1),
            onSurface: Colors.white,
          ),
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => const SplashScreen(), // Set splash screen as initial route
          'login': (context) => const LoginPage(),
          'register': (context) => const RegistrationPage(),
          'home': (context) => const HomePage(),
        },
      ),
    );
  }
}
