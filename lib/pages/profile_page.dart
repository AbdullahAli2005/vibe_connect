// ignore_for_file: no_leading_underscores_for_local_identifiers

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import 'package:vibe_connect/services/db_service.dart';

import '../models/contact.dart';
import '../providers/auth_provider.dart';

class ProfilePage extends StatelessWidget {
  ProfilePage({super.key, required this.height, required this.width});

  final double height;
  final double width;

  late AuthProvider _auth;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
          child: ChangeNotifierProvider<AuthProvider>.value(
        value: AuthProvider.instance,
        child: _profilePageUI(),
      )),
    );
  }

  Widget _profilePageUI() {
    return Builder(
      builder: (BuildContext _context) {
        _auth = Provider.of<AuthProvider>(_context);
        return StreamBuilder<Contact>(
            stream: DBService.instance.getUserData(_auth.user!.uid),
            builder: (_context, _snapshot) {
              var _userData = _snapshot.data;
              return _snapshot.hasData
                  ? Align(
                      child: SizedBox(
                        height: height * 0.5,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          mainAxisSize: MainAxisSize.max,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            _userImageWidget(_userData!.image),
                            _userNameWidget(_userData.name),
                            _userEmailWidget(_userData.email),
                            _logoutButton()
                          ],
                        ),
                      ),
                    )
                  : const SpinKitWanderingCubes(
                      color: Colors.blue,
                      size: 50.0,
                    );
              ;
            });
      },
    );
  }

  Widget _userImageWidget(String _image) {
    double _imageRadius = height * 0.20;
    return Container(
      height: _imageRadius,
      width: _imageRadius,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(_imageRadius),
        image: DecorationImage(
          fit: BoxFit.cover,
          image: NetworkImage(_image),
        ),
      ),
    );
  }

  Widget _userNameWidget(String _userName) {
    return Container(
      height: height * 0.05,
      width: width,
      child: Text(
        _userName,
        textAlign: TextAlign.center,
        style: const TextStyle(color: Colors.white, fontSize: 30),
      ),
    );
  }

  Widget _userEmailWidget(String _email) {
    return Container(
      height: height * 0.03,
      width: width,
      child: Text(
        _email,
        textAlign: TextAlign.center,
        style: const TextStyle(color: Colors.white24, fontSize: 15),
      ),
    );
  }

  Widget _logoutButton() {
    return Container(
      height: height * 0.06,
      width: width * 0.80,
      child: MaterialButton(
        onPressed: () {
          _auth.logoutUser(() async {
            return;
          });
        },
        color: Colors.red,
        child: const Text(
          "LOGOUT",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}
