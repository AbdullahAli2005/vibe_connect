import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../services/navigation_service.dart';
import '../services/snackbar_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late double _deviceHeight;
  late double _deviceWidth;

  late GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late AuthProvider _auth;

  late String _email;
  late String _password;

  _LoginPageState() {
    _formKey = GlobalKey<FormState>();
  }

  @override
  Widget build(BuildContext context) {
    _deviceHeight = MediaQuery.of(context).size.height;
    _deviceWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color.fromRGBO(28, 27, 27, 1),
      body: Align(
        alignment: Alignment.center,
        child: ChangeNotifierProvider<AuthProvider>.value(
          value: AuthProvider.instance,
          child: _loginPageUI(),
        ),
      ),
    );
  }

  Widget _loginPageUI() {
    return Builder(builder: (BuildContext _context) {
      SnackBarService.instance.buildContext = _context;
      _auth = Provider.of<AuthProvider>(_context);
      return Container(
        padding: EdgeInsets.symmetric(horizontal: _deviceWidth * 0.10),
        height: _deviceHeight * 0.60,
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _headingWidget(),
            _inputForm(),
            _registerButton(),
            _loginButton(),
          ],
        ),
      );
    });
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
            "Welcome back!",
            style: TextStyle(fontSize: 35, fontWeight: FontWeight.w700),
          ),
          Text(
            "Please login to your account.",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w200),
          ),
        ],
      ),
    );
  }

  Widget _inputForm() {
    return Container(
      height: _deviceHeight * 0.18,
      child: Form(
        key: _formKey,
        onChanged: () {},
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _emailTextField(),
            _passwordTextField(),
          ],
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
            : "Please enter a valid email";
      },
      onSaved: (_input) {
        setState(() {
          _email = _input!;
        });
      },
      cursorColor: Colors.white,
      decoration: const InputDecoration(
        hintText: "Email Address",
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

  Widget _loginButton() {
    return _auth.status == AuthStatus.Authenticating
        ? const Align(
            alignment: Alignment.center,
            child: CircularProgressIndicator(),
          )
        : SizedBox(
            height: _deviceHeight * 0.06,
            width: _deviceWidth,
            child: MaterialButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  _formKey.currentState!.save();
                  _auth.loginWithUserEmailAndPassword(_email, _password);
                }
              },
              color: Colors.blue,
              child: const Text(
                "LOGIN",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
            ),
          );
  }

  Widget _registerButton() {
    return GestureDetector(
      onTap: () {
        NavigationService.instance.navigateTo("register");
      },
      child: SizedBox(
        height: _deviceHeight * 0.06,
        width: _deviceWidth,
        child: const Center(
          child: Text(
            "REGISTER",
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white60),
          ),
        ),
      ),
    );
  }
}
