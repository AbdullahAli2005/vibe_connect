import 'package:flutter/material.dart';
import 'package:vibe_connect/pages/login_page.dart';
import 'package:vibe_connect/pages/home_page.dart';
import 'package:vibe_connect/providers/auth_provider.dart';
import 'package:provider/provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNextScreen();
  }

  // Wait for 3 seconds before navigating to the appropriate page
  Future<void> _navigateToNextScreen() async {
    await Future.delayed(const Duration(seconds: 3));

    // Check if the user is authenticated, if not navigate to login
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.user == null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    } else {
      // Navigate to home page if the user is authenticated
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(28, 27, 27, 1),
      body: SizedBox(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: Image.asset(
          'assets/splash_screen.png', 
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
