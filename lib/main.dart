import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();  // Initialize Firebase here
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: LoginScreen(),
    );
  }
}

class PresenceService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _databaseRef = FirebaseDatabase.instance.ref();

  void updateUserPresence() {
    // Set user presence as online/offline
    User? user = _auth.currentUser;

    if (user != null) {
      final userStatusDatabaseRef = _databaseRef.child('users/${user.uid}/status');

      // Set initial status to 'online' when connected
      _databaseRef.child('.info/connected').onValue.listen((event) {
        final connected = event.snapshot.value as bool? ?? false;
        if (connected) {
          userStatusDatabaseRef.set('online');
          userStatusDatabaseRef.onDisconnect().set('offline');
        }
      });
    }
  }
}
