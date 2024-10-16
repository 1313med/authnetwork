import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'home_screen.dart'; // Make sure to import the HomeScreen
import 'presence_service.dart'; // Import the presence service file

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String errorMessage = '';
  bool isLoading = false; // Flag to indicate loading state

  // Helper function to validate email format
  bool isValidEmail(String email) {
    final emailRegex = RegExp(r"^[a-zA-Z0-9]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
    return emailRegex.hasMatch(email);
  }

  Future<void> _login() async {
    setState(() {
      isLoading = true; // Start loading spinner
    });

    // Input validation
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      setState(() {
        errorMessage = 'Email and password cannot be empty.';
        isLoading = false; // Stop loading spinner
      });
      return;
    }

    if (!isValidEmail(_emailController.text)) {
      setState(() {
        errorMessage = 'Please enter a valid email.';
        isLoading = false; // Stop loading spinner
      });
      return;
    }

    if (_passwordController.text.length < 6) {
      setState(() {
        errorMessage = 'Password must be at least 6 characters long.';
        isLoading = false; // Stop loading spinner
      });
      return;
    }

    try {
      // Attempt to sign in the user
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
          email: _emailController.text, password: _passwordController.text);

      // If login is successful, update presence
      PresenceService().updateUserPresence(); // Set the user's online status

      // Navigate to HomeScreen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen()),
      );
    } on FirebaseAuthException catch (e) {
      setState(() {
        switch (e.code) {
          case 'user-not-found':
            errorMessage = 'No user found for that email.';
            break;
          case 'wrong-password':
            errorMessage = 'Wrong password provided.';
            break;
          case 'network-request-failed':
            errorMessage = 'No internet connection.';
            break;
          default:
            errorMessage = 'Login failed: ${e.message}';
        }
        isLoading = false; // Stop loading spinner on error
      });
    } catch (e) {
      setState(() {
        errorMessage = 'An unknown error occurred: $e';
        isLoading = false; // Stop loading spinner on error
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            isLoading // Show spinner while loading
                ? CircularProgressIndicator() // Loading indicator
                : ElevatedButton(
                    onPressed: _login,
                    child: Text('Login'),
                  ),
            SizedBox(height: 20),
            Text(
              errorMessage,
              style: TextStyle(
                color: errorMessage == 'Login successful!' ? Colors.green : Colors.red,
              ),
            ),
          ],
        ),
      ),
    );
  }
} 
