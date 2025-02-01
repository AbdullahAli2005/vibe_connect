// ignore_for_file: no_leading_underscores_for_local_identifiers

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:vibe_connect/providers/auth_provider.dart';
import 'package:vibe_connect/services/media_service.dart';

import '../models/conversations.dart';
import '../models/messages.dart';
import '../services/cloud_storage.dart';
import '../services/db_service.dart';

class ConversationPage extends StatefulWidget {
  String conversationID;
  String receiverID;
  String receiverImage;
  String receiverName;
  ConversationPage({
    super.key,
    required this.conversationID,
    required this.receiverID,
    required this.receiverImage,
    required this.receiverName,
  });

  @override
  State<ConversationPage> createState() => _ConversationPageState();
}

class _ConversationPageState extends State<ConversationPage> {
  late double _deviceHeight;
  late double _deviceWidth;

  late AuthProvider _auth;
  late GlobalKey<FormState> _formKey;
  late ScrollController _listViewController;


  late String _messageText;

  @override
  void initState() {
    super.initState();
    _formKey = GlobalKey<FormState>();
    _listViewController = ScrollController();
    _messageText = "";
  }

  @override
  Widget build(BuildContext context) {
    _deviceHeight = MediaQuery.of(context).size.height;
    _deviceWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(31, 31, 31, 1.0),
        title: Text(widget.receiverName),
        centerTitle: true,
      ),
      body: ChangeNotifierProvider<AuthProvider>.value(
        value: AuthProvider.instance,
        child: _conversationPageUI(),
      ),
    );
  }

  Widget _conversationPageUI() {
    return Builder(
      builder: (BuildContext _context) {
        _auth = Provider.of<AuthProvider>(_context);
        return Stack(
          children: [
            _messageListView(),
            Align(
              alignment: Alignment.bottomCenter,
              child: _messageField(_context),
            ),
          ],
        );
      },
    );
  }

  Widget _messageListView() {
    return SizedBox(
      height: _deviceHeight * 0.75,
      width: _deviceWidth,
      child: StreamBuilder<Conversation>(
        stream: DBService.instance.getConversation(widget.conversationID),
        builder: (BuildContext _context, _snapshot) {
          Timer(
            const Duration(milliseconds: 50),
            () {
              _listViewController
                  .jumpTo(_listViewController.position.maxScrollExtent);
            },
          );
          var _conversationData = _snapshot.data;
          if (_conversationData != null) {
            if(_conversationData.messages.isNotEmpty ){
              return ListView.builder(
              controller: _listViewController,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
              itemCount: _conversationData.messages.length,
              itemBuilder: (BuildContext _context, int _index) {
                var _message = _conversationData.messages[_index];
                bool _isOwnMessage = _message.senderID == _auth.user!.uid;
                return _messageListViewChild(_isOwnMessage, _message);
              },
            );
            } else {
              return const Align(
                alignment: Alignment.center,
                child: Text("Let's start a conversation!"),
              );
            }
            
          } else {
            return const SpinKitWanderingCubes(
              color: Colors.blue,
              size: 50.0,
            );
          }
        },
      ),
    );
  }

  Widget _messageListViewChild(bool _isOwnMessage, Message _message) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment:
            _isOwnMessage ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          !_isOwnMessage ? _userImageWidget() : Container(),
          SizedBox(width: _deviceWidth * 0.02),
          _message.type == MessageType.Text
              ? _textMessageBubble(
                  _isOwnMessage, _message.content, _message.timestamp)
              : _imageMessageBubble(
                  _isOwnMessage, _message.content, _message.timestamp)
        ],
      ),
    );
  }

  Widget _userImageWidget() {
    double _imageRadius = _deviceHeight * 0.05;
    return Container(
      height: _imageRadius,
      width: _imageRadius,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(500),
        image: DecorationImage(
          fit: BoxFit.cover,
          image: NetworkImage(widget.receiverImage),
        ),
      ),
    );
  }

  Widget _textMessageBubble(
      bool _isOwnMessage, String _message, Timestamp _timestamp) {
    List<Color> _colorScheme = _isOwnMessage
        ? [Colors.blue, const Color.fromRGBO(42, 117, 188, 1)]
        : [
            const Color.fromRGBO(89, 89, 89, 1),
            const Color.fromRGBO(54, 54, 54, 1)
          ];
    return Container(
      height: _deviceHeight * 0.08 + (_message.length / 20 * 5.0),
      width: _deviceWidth * 0.75,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        gradient: LinearGradient(
          colors: _colorScheme,
          stops: const [0.30, 0.70],
          begin: Alignment.bottomLeft,
          end: Alignment.topRight,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Text(_message),
          Text(
            timeago.format(_timestamp.toDate()),
            style: const TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _imageMessageBubble(
      bool _isOwnMessage, String _imageURL, Timestamp _timestamp) {
    List<Color> _colorScheme = _isOwnMessage
        ? [Colors.blue, const Color.fromRGBO(42, 117, 188, 1)]
        : [
            const Color.fromRGBO(89, 89, 89, 1),
            const Color.fromRGBO(54, 54, 54, 1)
          ];
    DecorationImage _image =
        DecorationImage(image: NetworkImage(_imageURL), fit: BoxFit.cover);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        gradient: LinearGradient(
          colors: _colorScheme,
          stops: const [0.30, 0.70],
          begin: Alignment.bottomLeft,
          end: Alignment.topRight,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Container(
            height: _deviceHeight * 0.30,
            width: _deviceWidth * 0.40,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              image: _image,
            ),
          ),
          Text(
            timeago.format(_timestamp.toDate()),
            style: const TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _messageField(BuildContext _context) {
    return Container(
      height: _deviceHeight * 0.08,
      decoration: BoxDecoration(
        color: const Color.fromRGBO(43, 43, 43, 1),
        borderRadius: BorderRadius.circular(100),
      ),
      margin: EdgeInsets.symmetric(
          horizontal: _deviceWidth * 0.04, vertical: _deviceHeight * 0.03),
      child: Form(
        key: _formKey,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: [
            _messageTextField(),
            _sendMessageButton(_context),
            _imageMessageButton(),
          ],
        ),
      ),
    );
  }

  Widget _messageTextField() {
    return SizedBox(
      width: _deviceWidth * 0.55,
      child: TextFormField(
        validator: (_input) {
          if (_input!.isEmpty) {
            return "Please Enter a Message";
          }
          return null;
        },
        onChanged: (_input) {
          _formKey.currentState!.save();
        },
        onSaved: (_input) {
          setState(() {
            _messageText = _input!;
          });
        },
        cursorColor: Colors.white,
        decoration: const InputDecoration(
          border: InputBorder.none,
          hintText: "Type a message",
        ),
        autocorrect: false,
      ),
    );
  }

  Widget _sendMessageButton(BuildContext _context) {
    return Container(
      height: _deviceHeight * 0.05,
      width: _deviceHeight * 0.05,
      child: IconButton(
        icon: const Icon(
          Icons.send,
          color: Colors.white,
        ),
        onPressed: () {
          if (_formKey.currentState!.validate()) {
            DBService.instance.sendMessage(
              widget.conversationID,
              Message(
                senderID: _auth.user!.uid,
                content: _messageText,
                timestamp: Timestamp.now(),
                type: MessageType.Text,
              ),
            );
          }
          setState(() {
            _messageText = ""; // Reset message text
          });
          _formKey.currentState!.reset();
          FocusScope.of(_context).unfocus();
        },
      ),
    );
  }

  Widget _imageMessageButton() {
    return Container(
      height: _deviceHeight * 0.05,
      width: _deviceHeight * 0.05,
      child: FloatingActionButton(
        onPressed: () async {
          var _image = await MediaService.instance.getImageFromLibrary();
          if (_image != null) {
            var _result = await CloudinaryService.uploadMediaMessage(
                _auth.user!.uid, _image);
            var _imageURL = _result!;
            await DBService.instance.sendMessage(
              widget.conversationID,
              Message(
                  senderID: _auth.user!.uid,
                  content: _imageURL,
                  timestamp: Timestamp.now(),
                  type: MessageType.Image),
            );
          }
        },
        child: const Icon(Icons.camera_enhance),
      ),
    );
  }
}
