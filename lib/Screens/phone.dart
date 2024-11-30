import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PhoneAuthScreen extends StatefulWidget {
  @override
  _PhoneAuthScreenState createState() => _PhoneAuthScreenState();
}

class _PhoneAuthScreenState extends State<PhoneAuthScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();

  String? _verificationId;

  Future<void> _verifyPhoneNumber() async {
    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: _phoneController.text,
      verificationCompleted: (PhoneAuthCredential credential) async {
        // التحقق التلقائي (على أجهزة Android يمكن أن يتم التحقق تلقائياً)
        await FirebaseAuth.instance.signInWithCredential(credential);
        _saveUserData();
      },
      verificationFailed: (FirebaseAuthException e) {
        print("Verification failed: ${e.message}");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to verify phone number: ${e.message}")),
        );
      },
      codeSent: (String verificationId, int? resendToken) {
        // يتم استدعاؤها عند إرسال الرمز
        setState(() {
          _verificationId = verificationId;
        });
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        // يتم استدعاؤها عند انتهاء المهلة
        setState(() {
          _verificationId = verificationId;
        });
      },
    );
  }

  Future<void> _signInWithPhoneNumber() async {
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: _codeController.text,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);
      _saveUserData();
    } catch (e) {
      print("Failed to sign in: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to sign in: $e")),
      );
    }
  }

  Future<void> _saveUserData() async {
    // حفظ بيانات المستخدم في Firestore بعد التحقق من رقم الهاتف
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'phone': user.phoneNumber,
        'createdAt': DateTime.now(),
      });
      print("User data saved!");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Phone Authentication")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _phoneController,
              decoration: InputDecoration(labelText: "Enter phone number"),
              keyboardType: TextInputType.phone,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _verifyPhoneNumber,
              child: Text("Verify Phone Number"),
            ),
            if (_verificationId != null) ...[
              TextField(
                controller: _codeController,
                decoration: InputDecoration(labelText: "Enter SMS code"),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _signInWithPhoneNumber,
                child: Text("Sign in"),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
