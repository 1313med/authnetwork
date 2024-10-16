import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late DatabaseReference userStatusRef;
  String userStatus = "offline";

  @override
  void initState() {
    super.initState();
    _trackUserStatus();
  }

  // Function to track user's online/offline status
  void _trackUserStatus() {
    User? user = _auth.currentUser;
    if (user != null) {
      String userId = user.uid;
      userStatusRef = FirebaseDatabase.instance
          .ref()  // Updated from .reference() to .ref()
          .child('users')
          .child(userId)
          .child('status');

      // Listening to the user status changes in Firebase Realtime Database
      userStatusRef.onValue.listen((event) {
        String status = (event.snapshot.value as String?) ?? "offline";  // Updated to safely cast value to String
        setState(() {
          userStatus = status;
        });
        print('User is $status');
      });
    }
  }

  Future<void> _logout(BuildContext context) async {
    await _auth.signOut();
    // Navigate the user back to the LoginScreen
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Welcome to the Home Page bro!',
              style: TextStyle(fontSize: 24),
            ),
            SizedBox(height: 20),
            Text(
              "User status: $userStatus",
              style: TextStyle(
                fontSize: 18,
                color: userStatus == "online" ? Colors.green : Colors.red,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
