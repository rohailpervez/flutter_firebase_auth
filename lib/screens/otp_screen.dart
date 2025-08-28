import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_firebase/home_screen.dart';

class OtpScreen extends StatefulWidget {
  final dynamic confirmationResult; // Web
  final String? verificationId; // Mobile
  final String email;
  final String password;

  OtpScreen({
    Key? key,
    this.confirmationResult,
    this.verificationId,
    required this.email,
    required this.password,
  }) : super(key: key);

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final otpController = TextEditingController();
  bool loading = false;

  void _verifyOtp() async {
    if (otpController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please enter OTP")),
      );
      return;
    }

    setState(() => loading = true);

    try {
      UserCredential userCredential;

      if (kIsWeb) {
        userCredential = await widget.confirmationResult.confirm(
          otpController.text.trim(),
        );
      } else {
        PhoneAuthCredential credential = PhoneAuthProvider.credential(
          verificationId: widget.verificationId!,
          smsCode: otpController.text.trim(),
        );
        userCredential = await _auth.signInWithCredential(credential);
      }

      // Create email/password account
      UserCredential emailUser =
      await _auth.createUserWithEmailAndPassword(
        email: widget.email,
        password: widget.password,
      );

      // Send email verification
      await emailUser.user!.sendEmailVerification();

      // Show alert to user
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Email Verification Required"),
          content: Text(
              "A verification email has been sent to ${widget.email}. Please verify your email before continuing."),
          actions: [
            TextButton(
              onPressed: () async {
                // Reload current user and check verification
                await FirebaseAuth.instance.currentUser!.reload();
                var user = FirebaseAuth.instance.currentUser;

                if (user != null && user.emailVerified) {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => HomeScreen()),
                        (route) => false,
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text(
                            "Email not verified yet. Check your inbox.")),
                  );
                }
              },
              child: Text("I have verified"),
            )
          ],
        ),
      );
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.message}")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Unexpected error: $e")),
      );
    } finally {
      setState(() => loading = false);
    }
  }

  @override
  void dispose() {
    otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple.shade50,
      appBar: AppBar(
        title: Text("Verify OTP"),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
        elevation: 0,
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.message, size: 80, color: Colors.deepPurple),
              SizedBox(height: 20),
              Text(
                "Enter the OTP sent to your phone",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 30),
              TextField(
                controller: otpController,
                keyboardType: TextInputType.number,
                maxLength: 6,
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  hintText: "Enter 6-digit OTP",
                  counterText: "",
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              SizedBox(height: 30),
              loading
                  ? CircularProgressIndicator()
                  : SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _verifyOtp,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 14),
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                    textStyle: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text("Verify"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
