// ignore_for_file: no_leading_underscores_for_local_identifiers

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:vibe_connect/pages/conversation_page.dart';

import '../models/contact.dart';
import '../providers/auth_provider.dart';
import '../services/db_service.dart';
import '../services/navigation_service.dart';

class SearchPage extends StatefulWidget {
  final double height;
  final double width;

  SearchPage({super.key, required this.height, required this.width});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  late AuthProvider _auth;

  late String _searchText;

  _SearchPageState() {
    _searchText = '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: ChangeNotifierProvider<AuthProvider>.value(
          value: AuthProvider.instance,
          child: searchPageUI(),
        ),
      ),
    );
  }

  Widget searchPageUI() {
    return Builder(
      builder: (BuildContext _context) {
        _auth = Provider.of<AuthProvider>(_context);
        return SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _userSearchField(),
              _usersListView(),
            ],
          ),
        );
      },
    );
  }

  Widget _userSearchField() {
    return Container(
      height: widget.height * 0.08,
      width: widget.width,
      padding: EdgeInsets.symmetric(vertical: widget.height * 0.02),
      child: TextField(
        autocorrect: false,
        style: const TextStyle(color: Colors.white),
        onSubmitted: (_input) {
          setState(() {
            _searchText = _input;
          });
        },
        decoration: const InputDecoration(
          prefixIcon: Icon(
            Icons.search,
            color: Colors.white,
          ),
          hintStyle: TextStyle(color: Colors.white),
          hintText: "Search",
          border: OutlineInputBorder(borderSide: BorderSide.none),
        ),
      ),
    );
  }

  Widget _usersListView() {
    return StreamBuilder<List<Contact>>(
      stream: DBService.instance.getUsersInDB(_searchText),
      builder: (_context, _snapshot) {
        var _usersData = _snapshot.data;
        if (_usersData != null) {
          _usersData.removeWhere((_contact) => _contact.id == _auth.user!.uid);
        }

        return _snapshot.hasData
            ? Container(
                height: widget.height * 0.72,
                child: ListView.builder(
                  itemCount: _usersData!.length,
                  itemBuilder: (BuildContext _context, int _index) {
                    var _userData = _usersData[_index];
                    var _currentTime = DateTime.now();
                    var _recepientID = _usersData[_index].id;
                    var _isUserActive = !_userData.lastseen.toDate().isBefore(
                          _currentTime.subtract(
                            const Duration(hours: 1),
                          ),
                        );
                    return ListTile(
                      onTap: () {
                        DBService.instance.createOrGetConversartion(
                            _auth.user!.uid, _recepientID,
                            (String _conversationID) {
                          return NavigationService.instance.navigateToRoute(
                            MaterialPageRoute(builder: (_context) {                   
                              return ConversationPage(
                                  conversationID: _conversationID,
                                  receiverID: _recepientID,
                                  receiverImage: _userData.image,
                                  receiverName: _userData.name);
                            }),
                          );
                        });
                      },
                      title: Text(_userData.name),
                      leading: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(100),
                          image: DecorationImage(
                            fit: BoxFit.cover,
                            image: NetworkImage(_userData.image),
                          ),
                        ),
                      ),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        mainAxisSize: MainAxisSize.max,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          _isUserActive
                              ? const Text(
                                  "Active Now",
                                  style: TextStyle(fontSize: 15),
                                )
                              : const Text(
                                  "Last Seen",
                                  style: TextStyle(fontSize: 15),
                                ),
                          _isUserActive
                              ? Container(
                                  height: 10,
                                  width: 10,
                                  decoration: BoxDecoration(
                                    color: Colors.green,
                                    borderRadius: BorderRadius.circular(100),
                                  ),
                                )
                              : Text(
                                  timeago.format(
                                    _userData.lastseen.toDate(),
                                  ),
                                  style: const TextStyle(fontSize: 15),
                                ),
                        ],
                      ),
                    );
                  },
                ),
              )
            : const SpinKitWanderingCubes(
                color: Colors.blue,
                size: 50.0,
              );
      },
    );
  }
}
