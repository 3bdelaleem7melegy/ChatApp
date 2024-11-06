import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class StoryEditorPage extends StatefulWidget {
  @override
  _StoryEditorPageState createState() => _StoryEditorPageState();
}

class _StoryEditorPageState extends State<StoryEditorPage> {
  final TextEditingController _storyContentController = TextEditingController();

  void _onUploadStory() async {
    String storyContent = _storyContentController.text;

    // تعيين الصورة أو الفيديو بناءً على ما تم اختياره

    // استدعاء دالة رفع القصة
    await uploadStory(storyContent);

    // العودة بعد الانتهاء من الرفع
    Navigator.pop(context);
  }

  Future<void> uploadStory(String storyContent) async {
    String? imageUrl;
    String? videoUrl;
    User? user = FirebaseAuth.instance.currentUser;
    String? profileImageUrl;

    if (user == null) return;

    String username = '';
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('Patients')
          .doc(user.uid)
          .get();
      if (userDoc.exists) {
        username = userDoc.get('name');
        profileImageUrl =
            userDoc.get('imageUrl'); // احصل على رابط الصورة الشخصية
      }
    } catch (e) {
      print("Error retrieving user document: $e");
    }

    try {
      await FirebaseFirestore.instance.collection('stories').add({
        'username': username,
        'storyContent': storyContent,
        'imageUrl': imageUrl,
        'videoUrl': videoUrl,
        'timestamp': FieldValue.serverTimestamp(),
        'senderid': user.uid,
        'profileImageUrl': profileImageUrl, // أضف رابط الصورة الشخصية
      });
    } catch (e) {
      print("Error adding story to Firestore: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          // title: Text('Type a Status'),
          // actions: [
          //   IconButton(
          //     icon: Icon(Icons.check),
          //     onPressed: _onUploadStory,
          //   ),
          // ],
          ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(children: [
          Spacer(),
          Center(
            child: TextField(
              controller: _storyContentController,
              maxLines: null,
              decoration: InputDecoration(
                hintText: 'Type a Status',
                border: InputBorder.none, // إخفاء الحدود الافتراضية
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Spacer(),
          IconButton(
            icon: Icon(
              Icons.send,
              size: 40,
            ),
            onPressed: _onUploadStory,
          ),
        ]),
      ),
    );
  }
}
