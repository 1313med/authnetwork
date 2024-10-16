import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PresenceService {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();

  void updateUserPresence() {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userStatusRef = _database.child('users/${user.uid}/status');

      // Mark the user as online when they log in
      userStatusRef.set("online");

      // Mark the user as offline when they disconnect
      userStatusRef.onDisconnect().set("offline");
    }
  }
}
