import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_firebase/screens/login_screen.dart';
import 'package:flutter_firebase/home_screen.dart';
import 'package:flutter_firebase/firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Firebase Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home:  AuthGate(),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // while checking auth state, show loader
        if (snapshot.connectionState == ConnectionState.waiting) {
          return  Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        // if user is logged in, go to Home
        if (snapshot.hasData && snapshot.data != null) {
          return HomeScreen();
        }
        // otherwise show login
        return  LoginScreen();
      },
    );
  }
}
