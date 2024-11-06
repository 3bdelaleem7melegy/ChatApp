import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class PreviewMediaPage extends StatefulWidget {
  final File mediaFile;
  final String storyContent;
  final bool isVideo;

  PreviewMediaPage({
    required this.mediaFile,
    required this.storyContent,
    required this.isVideo,
  });

  @override
  _PreviewMediaPageState createState() => _PreviewMediaPageState();
}

class _PreviewMediaPageState extends State<PreviewMediaPage> {
  VideoPlayerController? _videoController;

  @override
  void initState() {
    super.initState();
    if (widget.isVideo) {
      _videoController = VideoPlayerController.file(widget.mediaFile)
        ..initialize().then((_) {
          setState(() {});
          _videoController?.play();
          _videoController?.setLooping(true);
        });
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  Future<void> _onUploadStory() async {
    await uploadStory(
        widget.storyContent,
        widget.isVideo ? null : widget.mediaFile,
        widget.isVideo ? widget.mediaFile : null);
    Navigator.pop(context);
  }

  Future<void> uploadStory(
      String storyContent, File? imageFile, File? videoFile) async {
    String? imageUrl;
    String? videoUrl;
    String? profileImageUrl;

    User? user = FirebaseAuth.instance.currentUser;
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

    if (imageFile != null) {
      try {
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('stories/$username/${DateTime.now()}.jpg');
        await storageRef.putFile(imageFile);
        imageUrl = await storageRef.getDownloadURL();
      } catch (e) {
        print("Error uploading image: $e");
      }
    }

    if (videoFile != null) {
      try {
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('stories/$username/${DateTime.now()}.mp4');
        await storageRef.putFile(videoFile);
        videoUrl = await storageRef.getDownloadURL();
      } catch (e) {
        print("Error uploading video: $e");
      }
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
        // title: Text('Preview Media'),
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: widget.isVideo &&
                      _videoController != null &&
                      _videoController!.value.isInitialized
                  ? AspectRatio(
                      aspectRatio: _videoController!.value.aspectRatio,
                      child: VideoPlayer(_videoController!),
                    )
                  : Image.file(widget.mediaFile, fit: BoxFit.cover),
            ),
          ),
          IconButton(
            onPressed: _onUploadStory,
            icon:  Icon(Icons.send,),
          ),
        ],
      ),
    );
  }
}
