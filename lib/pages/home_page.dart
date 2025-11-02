import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proximity_finder/pages/login_page.dart';
import 'package:proximity_finder/pages/services_pages.dart';
import 'package:proximity_finder/util/section_tile.dart';

import '../Provider/theme_change.dart';

class HomePage extends StatelessWidget {
  HomePage({super.key});

  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> _logout(BuildContext context) async {
    await _auth.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    final categories = [
      {'title': 'Hospital', 'icon': '🏥'},
      {'title': 'School', 'icon': '🏫'},
      {'title': 'College', 'icon': '🎓'},
      {'title': 'Restaurant', 'icon': '🍴'},
      {'title': 'Park', 'icon': '🌳'},
      {'title': 'Mall', 'icon': '🛍️'},
      {'title': 'Pharmacy', 'icon': '💊'},
      {'title': 'Supermarket', 'icon': '🛒'},
      {'title': 'Bank', 'icon': '🏦'},
      {'title': 'ATM', 'icon': '🏧'},
      {'title': 'Gas Station', 'icon': '⛽'},
      {'title': 'Cop Station', 'icon': '🚓'},
      {'title': 'Fire Station', 'icon': '🚒'},
      {'title': 'Library', 'icon': '📚'},
      {'title': 'Gym', 'icon': '🏋️‍♂️'},
      {'title': 'Cinema', 'icon': '🎬'},
      {'title': 'Hotel', 'icon': '🏨'},
      {'title': 'Bus Station', 'icon': '🚏'},
      {'title': 'Train Station', 'icon': '🚉'},
      {'title': 'Airport', 'icon': '✈️'},
      {'title': 'Post Office', 'icon': '📮'},
      {'title': 'Clinic', 'icon': '🏥'},
      {'title': 'Dentist', 'icon': '🦷'},
      {'title': 'Veterinary', 'icon': '🐾'},
      {'title': 'Church', 'icon': '⛪'},
      {'title': 'Mosque', 'icon': '🕌'},
      {'title': 'Temple', 'icon': '🛕'},
      {'title': 'Museum', 'icon': '🏛️'},
      {'title': 'Zoo', 'icon': '🦁'},
      {'title': 'Beach', 'icon': '🏖️'}
    ];

    return Scaffold(
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: const BoxDecoration(
                color: Colors.blueGrey,
              ),
              child: const Text(
                'Proximity Finder',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            SizedBox(height: 10),
            ListTile(
              title: Text('Get help from AI'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            SizedBox(height: 10),
            ListTile(
              title: Text('issue a new service'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            SizedBox(height: 10),
            ListTile(
              title: Text(themeProvider.isLightMode ? "light" : "dark"),
              onTap: () {
                themeProvider.toggleTheme();
              },
            ),
            SizedBox(height: 10),
            ListTile(
              title: Text('logout'),
              onTap: () {
                _logout(context);
              },
            ),
          ],
        ),
      ),
      appBar: AppBar(
        backgroundColor: Colors.blueGrey[400],
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Center(
              child: Text('proximity finder'),
            ),
            // Switch(
            //     value: themeProvider.isLightMode,
            //     onChanged: (value) {
            //       themeProvider.toggleTheme();
            //     }),
            TextButton(
              onPressed: () {
                themeProvider.toggleTheme();
              },
              child: Text(themeProvider.isLightMode ? "light" : "dark"),
            )
          ],
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Center(
            child: Text("What do you want to search for?",
                style: TextStyle(fontSize: 20)),
          ),
          SizedBox(height: 20),
          Expanded(
            child: GridView.builder(
              itemCount: categories.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 12,
                mainAxisSpacing: 10,
              ),
              itemBuilder: (context, index) {
                final category = categories[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            ServicesPage(category: category['title']!),
                      ),
                    );
                  },
                  child: SectionTile(
                    icon: category['icon']!,
                    title: category['title']!,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
