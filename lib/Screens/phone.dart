import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PhoneAuthScreen extends StatefulWidget {
  @override
  _PhoneAuthScreenState createState() => _PhoneAuthScreenState();
}

class _PhoneAuthScreenState extends State<PhoneAuthScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _smsController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String? _verificationId;

  // إرسال رمز التحقق إلى رقم الهاتف
  void _verifyPhoneNumber() async {
    await _auth.verifyPhoneNumber(
      phoneNumber: _phoneController.text,
      verificationCompleted: (PhoneAuthCredential credential) async {
        // في حال تم التحقق تلقائيًا
        await _auth.signInWithCredential(credential);
        _storeUserData(_auth.currentUser!);
      },
      verificationFailed: (FirebaseAuthException e) {
        print('Verification failed: ${e.message}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Verification failed: ${e.message}')),
        );
      },
      codeSent: (String verificationId, int? resendToken) {
        setState(() {
          _verificationId = verificationId;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Code sent to ${_phoneController.text}')),
        );
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        _verificationId = verificationId;
      },
    );
  }

  // تسجيل الدخول باستخدام رمز التحقق
  void _signInWithPhoneNumber() async {
    if (_verificationId != null && _smsController.text.isNotEmpty) {
      try {
        PhoneAuthCredential credential = PhoneAuthProvider.credential(
          verificationId: _verificationId!,
          smsCode: _smsController.text,
        );
        UserCredential userCredential = await _auth.signInWithCredential(credential);
        _storeUserData(userCredential.user!);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Successfully signed in!')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to sign in: $e')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter the SMS code')),
      );
    }
  }

  // تخزين بيانات المستخدم في Firestore
  void _storeUserData(User user) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    await firestore.collection('users').doc(user.uid).set({
      'phone': user.phoneNumber,
      'createdAt': DateTime.now(),
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Phone Authentication")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _phoneController,
              decoration: InputDecoration(labelText: "Phone Number"),
              keyboardType: TextInputType.phone,
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: _verifyPhoneNumber,
              child: Text("Send Verification Code"),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _smsController,
              decoration: InputDecoration(labelText: "Verification Code"),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: _signInWithPhoneNumber,
              child: Text("Verify Code"),
            ),
          ],
        ),
      ),
    );
  }
}
