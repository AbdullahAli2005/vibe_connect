// ignore_for_file: no_leading_underscores_for_local_identifiers

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vibe_connect/services/cloud_storage.dart';
import 'package:vibe_connect/services/db_service.dart';

import '../providers/auth_provider.dart';
import '../services/media_service.dart';
import '../services/navigation_service.dart';
import '../services/snackbar_service.dart';

class RegistrationPage extends StatefulWidget {
  const RegistrationPage({super.key});

  @override
  State<RegistrationPage> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  late double _deviceHeight;
  late double _deviceWidth;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late AuthProvider _auth;

  String? _name;
  String? _email;
  String? _password;
  File? _image;

  _RegistrationPageState() {
    // _formKey = GlobalKey<FormState>();
  }

  @override
  Widget build(BuildContext context) {
    _deviceHeight = MediaQuery.of(context).size.height;
    _deviceWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color.fromRGBO(28, 27, 27, 1),
      body: Container(
        alignment: Alignment.center,
        child: ChangeNotifierProvider<AuthProvider>.value(
          value: AuthProvider.instance,
          child: registrationPageUI(),
        ),
      ),
    );
  }

  Widget registrationPageUI() {
    return Builder(
      builder: (BuildContext _context) {
        SnackBarService.instance.buildContext = _context;
        _auth = Provider.of<AuthProvider>(_context);
        return Container(
          height: _deviceHeight * 0.8,
          padding: EdgeInsets.symmetric(horizontal: _deviceWidth * 0.10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _headingWidget(),
              _inputForm(),
              _registerButton(),
              _backToLoginPageButton(),
            ],
          ),
        );
      },
    );
  }

  Widget _headingWidget() {
    return SizedBox(
      height: _deviceHeight * 0.16,
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            "Let's get going!",
            style: TextStyle(fontSize: 35, fontWeight: FontWeight.w700),
          ),
          Text(
            "Please enter your details.",
            style: TextStyle(fontSize: 25, fontWeight: FontWeight.w200),
          ),
        ],
      ),
    );
  }

  Widget _inputForm() {
    return Container(
      height: _deviceHeight * 0.37,
      child: Form(
        key: _formKey,
        onChanged: () {},
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _imageSelectorWidget(),
            _nameTextField(),
            _emailTextField(),
            _passwordTextField(),
          ],
        ),
      ),
    );
  }

  Widget _imageSelectorWidget() {
    return Align(
      alignment: Alignment.center,
      child: GestureDetector(
          child: GestureDetector(
        onTap: () async {
          File? _imageFile = await MediaService.instance.getImageFromLibrary();
          setState(() {
            _image = _imageFile;
          });
        },
        child: Container(
          height: _deviceHeight * 0.10,
          width: _deviceHeight * 0.10,
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(500),
            image: DecorationImage(
              fit: BoxFit.cover,
              image: _image != null
                  ? FileImage(_image!)
                  : const NetworkImage(
                      "https://cdn0.iconfinder.com/data/icons/occupation-002/64/programmer-programming-occupation-avatar-512.png"),
            ),
          ),
        ),
      )),
    );
  }

  Widget _nameTextField() {
    return TextFormField(
      autocorrect: false,
      style: const TextStyle(color: Colors.white),
      validator: (_input) {
        return _input != null && _input.isNotEmpty
            ? null
            : "Please enter a name";
      },
      onSaved: (_input) {
        setState(() {
          _name = _input!;
        });
      },
      cursorColor: Colors.white,
      decoration: const InputDecoration(
        hintText: "Name",
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.white),
        ),
      ),
    );
  }

  Widget _emailTextField() {
    return TextFormField(
      autocorrect: false,
      style: const TextStyle(color: Colors.white),
      validator: (_input) {
        return _input != null && _input.isNotEmpty && _input.contains("@")
            ? null
            : "Please enter a valid Email";
      },
      onSaved: (_input) {
        setState(() {
          _email = _input!;
        });
      },
      cursorColor: Colors.white,
      decoration: const InputDecoration(
        hintText: "Email",
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.white),
        ),
      ),
    );
  }

  Widget _passwordTextField() {
    return TextFormField(
      autocorrect: false,
      obscureText: true,
      style: const TextStyle(color: Colors.white),
      validator: (_input) {
        return _input != null && _input.isNotEmpty
            ? null
            : "Please enter a password";
      },
      onSaved: (_input) {
        setState(() {
          _password = _input!;
        });
      },
      cursorColor: Colors.white,
      decoration: const InputDecoration(
        hintText: "Password",
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.white),
        ),
      ),
    );
  }

  Widget _registerButton() {
    return _auth.status != AuthStatus.Authenticating
        ? SizedBox(
            height: _deviceHeight * 0.06,
            width: _deviceWidth,
            child: MaterialButton(
              onPressed: () async {
              if (_formKey.currentState!.validate() && _image != null) {
                _formKey.currentState!.save();

                String? imageURL = await CloudinaryService.uploadImage(_image!);
                if (imageURL != null) {
                  _auth.registerUserWithEmailAndPassword(
                    _email!,
                    _password!,
                    (String _uid) async {
                      await DBService.instance.createUserInDB(
                          _uid, _name!, _email!, imageURL);
                    },
                  );
                } else {
                  print("Image upload failed.");
                }
              }
            },
              color: Colors.blue,
              child: const Text(
                "Register",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
            ),
          )
        : const Align(
            alignment: Alignment.center,
            child: CircularProgressIndicator(),
          );
  }

  Widget _backToLoginPageButton() {
    return GestureDetector(
      onTap: () {
        NavigationService.instance.goBack();
      },
      child: SizedBox(
        height: _deviceHeight * 0.06,
        width: _deviceWidth,
        child: const Icon(Icons.arrow_back, size: 40),
      ),
    );
  }
}
