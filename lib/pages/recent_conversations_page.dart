// ignore_for_file: no_leading_underscores_for_local_identifiers

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:vibe_connect/models/messages.dart';
import 'package:vibe_connect/pages/conversation_page.dart';
import 'package:vibe_connect/services/navigation_service.dart';

import '../providers/auth_provider.dart';
import '../services/db_service.dart';

class RecentConversationsPage extends StatelessWidget {
  const RecentConversationsPage(
      {super.key, required this.height, required this.width});

  final double height;
  final double width;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
        height: height,
        width: width,
        child: ChangeNotifierProvider<AuthProvider>.value(
            value: AuthProvider.instance,
            child: _conversationsListViewWidget()),
      ),
    );
  }

  Widget _conversationsListViewWidget() {
    return Builder(
      builder: (BuildContext _context) {
        var _auth = Provider.of<AuthProvider>(_context);
        return SizedBox(
          height: height,
          width: width,
          child: StreamBuilder(
            stream: DBService.instance.getUserConversation(_auth.user!.uid),
            builder: (BuildContext _context, _snapshot) {
              if (_snapshot.connectionState == ConnectionState.waiting) {
                return const SpinKitWanderingCubes(
                  color: Colors.blue,
                  size: 50.0,
                );
              } else if (_snapshot.hasError) {
                return Center(child: Text('Error: ${_snapshot.error}'));
              } else if (!_snapshot.hasData || _snapshot.data!.isEmpty) {
                return const Center(child: Text('No Conversations Yet!'));
              }
              var _data = _snapshot.data!;
              return ListView.builder(
                itemCount: _data.length,
                itemBuilder: (_context, index) {
                  return ListTile(
                    onTap: () {
                      NavigationService.instance.navigateToRoute(
                          MaterialPageRoute(builder: (BuildContext _context) {
                        return ConversationPage(
                            conversationID: _data[index].conversationID,
                            receiverID: _data[index].id,
                            receiverImage: _data[index].image,
                            receiverName: _data[index].name);
                      }));
                    },
                    title: Text(_data[index].name),
                    subtitle: Text(_data[index].type == MessageType.Text ? _data[index].lastMessage : "Attachment: Image"),
                    leading: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(100),
                        image: DecorationImage(
                          fit: BoxFit.cover,
                          image: NetworkImage(_data[index].image),
                        ),
                      ),
                    ),
                    trailing: _listTileTrailingWidgets(_data[index].timestamp),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }

  // Widget _listTileTrailingWidgets(Timestamp _lastMessageTimestamp) {
  //   String formattedTime = _lastMessageTimestamp == null
  //       ? 'Never'
  //       : timeago.format(_lastMessageTimestamp.toDate());

  //   return Column(
  //     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  //     mainAxisSize: MainAxisSize.max,
  //     crossAxisAlignment: CrossAxisAlignment.end,
  //     children: [
  //       const Text(
  //         "Last Message",
  //         style: TextStyle(fontSize: 15),
  //       ),
  //       Text(
  //         formattedTime,
  //         style: const TextStyle(fontSize: 15),
  //       ),
  //     ],
  //   );
  // }
  Widget _listTileTrailingWidgets(Timestamp? _lastMessageTimestamp) {
  String formattedTime = 'Never';

  if (_lastMessageTimestamp != null) {
    // Check if the timestamp is valid (i.e., it's not some default uninitialized value)
    if (_lastMessageTimestamp.seconds != 0) {
      formattedTime = timeago.format(_lastMessageTimestamp.toDate());
    }
  }

  return Column(
    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    mainAxisSize: MainAxisSize.max,
    crossAxisAlignment: CrossAxisAlignment.end,
    children: [
      const Text(
        "Last Message",
        style: TextStyle(fontSize: 15),
      ),
      Text(
        formattedTime,
        style: const TextStyle(fontSize: 15),
      ),
    ],
  );
}

}
