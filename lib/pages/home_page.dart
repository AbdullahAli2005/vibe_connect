import 'package:flutter/material.dart';
import 'package:vibe_connect/pages/profile_page.dart';
import 'package:vibe_connect/pages/recent_conversations_page.dart';

import 'search_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  late double _height;
  late double _width;

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    // Initialize the TabController in initState
    _tabController = TabController(length: 3, vsync: this, initialIndex: 1);
  }

  @override
  void dispose() {
    // Dispose the TabController to free resources
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _height = MediaQuery.of(context).size.height;
    _width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: const Color.fromRGBO(28, 27, 27, 1),
      appBar: AppBar(
        title:  Row(
          mainAxisSize:
              MainAxisSize.min, // Ensures the Row is as compact as possible
          children: [
            Image.asset(
              'assets/appbar.png', // Path to your logo in assets
              height: 40, // Adjust height to fit the AppBar
            ),
            const SizedBox(width: 10), // Spacing between logo and app name
            const Text(
              'VibeConnect',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 22,
              ),
            ),
          ],
        ),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Colors.blue,
          labelColor: Colors.blue,
          indicatorSize: TabBarIndicatorSize.tab,
          dividerHeight: 0,
          tabs: const [
            Tab(
              icon: Icon(
                Icons.people_outline,
                size: 25,
              ),
            ),
            Tab(
              icon: Icon(
                Icons.chat_bubble_outline,
                size: 25,
              ),
            ),
            Tab(
              icon: Icon(
                Icons.person_outline,
                size: 25,
              ),
            ),
          ],
        ),
      ),
      body: _tabBarPages(),
    );
  }

  Widget _tabBarPages() {
    return TabBarView(
      controller: _tabController,
      children: [
        SearchPage(height: _height,width: _width,),
        RecentConversationsPage(height: _height,width: _width,),
        ProfilePage(height: _height,width: _width,),
      ],
    );
  }
}
