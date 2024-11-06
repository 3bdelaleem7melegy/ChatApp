import 'dart:async';
import 'dart:io';
import 'package:chatapp/Story/Camera.dart';
import 'package:chatapp/Story/EditStory.dart';
import 'package:chatapp/Story/StoryPage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class StartHomeStory extends StatefulWidget {
    final String currentUserId;

  const StartHomeStory({super.key, required this.currentUserId});

  @override
  _StartHomeStoryState createState() => _StartHomeStoryState();
}

class _StartHomeStoryState extends State<StartHomeStory> {
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _storyContentController = TextEditingController();
  File? _mediaFile;

  Future<void> _openStoryEditor(BuildContext context) async {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => StoryEditorPage(),
      ),
    );
  }

  Future<void> _pickMedia(BuildContext context) async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Pick Media'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.photo),
                title: Text('Photo from Gallery'),
                onTap: () async {
                  Navigator.of(context).pop(); // اغلاق النافذة
                  await _pickImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: Icon(Icons.camera),
                title: Text('Take a Photo'),
                onTap: () async {
                  Navigator.of(context).pop(); // اغلاق النافذة
                  await _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: Icon(Icons.videocam),
                title: Text('Record a Video'),
                onTap: () async {
                  Navigator.of(context).pop(); // اغلاق النافذة
                  await _pickVideo();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      _navigateToPreview(File(pickedFile.path), false);
    }
  }

  Future<void> _pickVideo() async {
    final pickedFile = await _picker.pickVideo(source: ImageSource.gallery);
    if (pickedFile != null) {
      _navigateToPreview(File(pickedFile.path), true);
    }
  }

  void _navigateToPreview(File mediaFile, bool isVideo) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PreviewMediaPage(
          mediaFile: mediaFile,
          storyContent: _storyContentController.text,
          isVideo: isVideo,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Stories'),centerTitle: true,),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('stories')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return Center(child: CircularProgressIndicator());

          final userStories = <String, List<QueryDocumentSnapshot>>{};
          final now = DateTime.now();

          for (var doc in snapshot.data!.docs) {
            final timestamp = doc['timestamp'];
            if (timestamp != null && timestamp is Timestamp) {
              final storyTime = timestamp.toDate();
              if (now.difference(storyTime).inMinutes < 5) {
                final username = doc['username'];
                if (!userStories.containsKey(username)) {
                  userStories[username] = [];
                }
                userStories[username]!.add(doc);
              }
            }
          }

          return ListView(
            children: userStories.entries.map((entry) {
                  final profileImageUrl = entry.value[0]['profileImageUrl'];

              return ListTile(
                title: Text(entry.key,
                    style: TextStyle(fontWeight: FontWeight.bold)),
                leading:CircleAvatar(
        backgroundImage: profileImageUrl != null
            ? NetworkImage(profileImageUrl)
            : null,
        child: profileImageUrl == null ? Icon(Icons.person) : null,
      ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => UserStoriesPage(
                          username: entry.key, stories: entry.value, currentUserId: widget.currentUserId,),
                    ),
                  );
                },
              );
            }).toList(),
          );
        },
      ),
      floatingActionButton: Column(
  mainAxisAlignment: MainAxisAlignment.end,
  children: [
    FloatingActionButton(
      heroTag: 'editStory', // تعيين heroTag فريد
      onPressed: () {
        _openStoryEditor(context);
      },
      child: Icon(Icons.edit),
      tooltip: 'Write a Story',
    ),
    SizedBox(height: 10),
    FloatingActionButton(
      heroTag: 'pickMedia', // تعيين heroTag فريد آخر
      onPressed: () {
        _pickMedia(context);
      },
      child: Icon(Icons.attach_file),
      tooltip: 'Pick an Image',
    ),
  ],
),

    );
  }
}
