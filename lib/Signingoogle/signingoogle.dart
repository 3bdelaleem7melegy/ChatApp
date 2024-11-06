import 'package:chatapp/AuthFirebase/patient_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/material.dart';

// خدمة المصادقة باستخدام Firebase و Google
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // تسجيل الدخول باستخدام Google
  Future<User?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return null; // المستخدم لم يكمل عملية تسجيل الدخول
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential result = await _auth.signInWithCredential(credential);
      User? user = result.user;

      if (user != null) {
        // التحقق مما إذا كان المستخدم مسجلاً مسبقًا في Firestore
        DocumentSnapshot userDoc = await _firestore.collection('Patients').doc(user.uid).get();
        if (!userDoc.exists) {
          // إذا لم يكن مسجلاً، نقوم بتخزين البيانات الأولية للمستخدم
          await _firestore.collection('Patients').doc(user.uid).set({
            'email': user.email,
            'name': user.displayName ?? 'No Name',
            'imageUrl': user.photoURL ?? '',
            'phoneNumber': '',
            'bio': '',
          });
        }
      }

      return user;
    } catch (e) {
      print('Failed to sign in with Google: $e');
      throw e;
    }
  }

  // تحديث بيانات المستخدم
  Future<void> updatePatientData(Patient patient) async {
    try {
      await _firestore.collection('Patients').doc(patient.id).update(patient.toFireStore());
    } catch (e) {
      print('Failed to update patient data: $e');
      throw e;
    }
  }

  // تسجيل الخروج
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      await _googleSignIn.signOut();
    } catch (e) {
      print('Failed to sign out: $e');
      throw e;
    }
  }
}


