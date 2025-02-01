// ignore_for_file: constant_identifier_names, no_leading_underscores_for_local_identifiers, avoid_print

import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';

import '../services/db_service.dart';
import '../services/navigation_service.dart';
import '../services/snackbar_service.dart';



enum AuthStatus {
  NotAuthenticated,
  Authenticating,
  Authenticated,
  UserNotFound,
  Error
}

class AuthProvider extends ChangeNotifier {
  late User? user;
  late AuthStatus status;

  late FirebaseAuth _auth;

  static AuthProvider instance = AuthProvider();

  AuthProvider() {
    _auth = FirebaseAuth.instance;
    status = AuthStatus.NotAuthenticated;
    _checkCurrentUserIsAuthenticated();
  }

  void _autoLogin() async {
    if (user != null) {
      await DBService.instance.updateUserLastSeenTime(user!.uid);
      return NavigationService.instance.navigateToReplacement("home");
    }
  }

  void _checkCurrentUserIsAuthenticated() async {
    user = _auth.currentUser;
    if (user != null) {
      notifyListeners();
      _autoLogin();
    }
  }

  void loginWithUserEmailAndPassword(String _email, String _password) async {
    status = AuthStatus.Authenticating;
    notifyListeners();
    try {
      // UserCredential rather than AuthResult
      UserCredential _result = await _auth.signInWithEmailAndPassword(
          email: _email, password: _password);
      user = _result.user!;
      status = AuthStatus.Authenticated;
      SnackBarService.instance.showSnackBarSuccess("Welcome, ${user!.email}");
      NavigationService.instance.navigateToReplacement("home");
      await DBService.instance.updateUserLastSeenTime(user!.uid);
    } catch (e) {
      status = AuthStatus.Error;
      user = null;
      print("The erre is $e");
      SnackBarService.instance.showSnackBarError("Error Authenticating");
    }
    notifyListeners();
  }

   void registerUserWithEmailAndPassword(String _email, String _password,
      Future<void> onSuccess(String _uid)) async {
    status = AuthStatus.Authenticating;
    notifyListeners();
    try {
      UserCredential _result = await _auth.createUserWithEmailAndPassword(
          email: _email, password: _password);
      user = _result.user!;
      status = AuthStatus.Authenticated;
      await onSuccess(user!.uid);
      SnackBarService.instance.showSnackBarSuccess("Welcome, ${user!.email}");
      await DBService.instance.updateUserLastSeenTime(user!.uid);
      NavigationService.instance.goBack();
      NavigationService.instance.navigateToReplacement("home");
    } catch (e) {
      status = AuthStatus.Error;
      user = null;
      SnackBarService.instance.showSnackBarError("Error $e");
    }
    notifyListeners();
  }

  void logoutUser(Future<void> onSuccess()) async {
    try {
      await _auth.signOut();
      user = null;
      status = AuthStatus.NotAuthenticated;
      await onSuccess();
      await NavigationService.instance.navigateToReplacement("login");
      SnackBarService.instance.showSnackBarSuccess("Logged Out Successfully!");
    } catch (e) {
      SnackBarService.instance.showSnackBarError("Error Logging Out");
    }
    notifyListeners();
  }
}
