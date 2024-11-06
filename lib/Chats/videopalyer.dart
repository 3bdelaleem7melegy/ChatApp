import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:gallery_saver/gallery_saver.dart';

class VideoPlayerScreen extends StatefulWidget {
  final String videoUrl;
  final String chatId;
  final String messageId;

  VideoPlayerScreen({
    required this.videoUrl,
    required this.chatId,
    required this.messageId,
  });

  @override
  _VideoPlayerScreenState createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(widget.videoUrl)
      ..initialize().then((_) {
        setState(() {});
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _deleteMessage() async {
    try {
      await FirebaseFirestore.instance
          .collection('chats')
          .doc(widget.chatId)
          .collection('messages')
          .doc(widget.messageId)
          .delete();

      await FirebaseStorage.instance.refFromURL(widget.videoUrl).delete();

      print('Message and video deleted successfully');
    } catch (e) {
      print('Error deleting message or video: $e');
    }
  }

  Future<void> _saveVideo() async {
    final bool? success = await GallerySaver.saveVideo(widget.videoUrl);
    if (success != null && success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Video saved to gallery!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving video.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Video Player')),
      body: Center(
        child: _controller.value.isInitialized
            ? AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: VideoPlayer(_controller),
              )
            : CircularProgressIndicator(),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: () {
              setState(() {
                _controller.value.isPlaying
                    ? _controller.pause()
                    : _controller.play();
              });
            },
            child: Icon(
              _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
            ),
          ),
          SizedBox(height: 16), // Space between buttons
          FloatingActionButton(
            onPressed: _deleteMessage,
            child: Icon(Icons.delete),
          ),
          SizedBox(height: 16), // Space between buttons
          FloatingActionButton(
            onPressed: _saveVideo, // حفظ الفيديو
            child: Icon(Icons.save_alt),
          ),
        ],
      ),
    );
  }
}
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:flutter/material.dart';
// import 'package:video_player/video_player.dart';
// import 'package:gallery_saver/gallery_saver.dart';
// import 'package:permission_handler/permission_handler.dart'; // لإدارة الأذونات

// class VideoPlayerScreen extends StatefulWidget {
//   final String videoUrl;
//   final String chatId;
//   final String messageId;

//   VideoPlayerScreen({
//     required this.videoUrl,
//     required this.chatId,
//     required this.messageId,
//   });

//   @override
//   _VideoPlayerScreenState createState() => _VideoPlayerScreenState();
// }

// class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
//   late VideoPlayerController _controller;

//   @override
//   void initState() {
//     super.initState();
//     _controller = VideoPlayerController.network(widget.videoUrl)
//       ..initialize().then((_) {
//         setState(() {});
//       });
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   Future<void> _deleteMessage() async {
//     try {
//       await FirebaseFirestore.instance
//           .collection('chats')
//           .doc(widget.chatId)
//           .collection('messages')
//           .doc(widget.messageId)
//           .delete();

//       await FirebaseStorage.instance.refFromURL(widget.videoUrl).delete();

//       print('Message and video deleted successfully');
//     } catch (e) {
//       print('Error deleting message or video: $e');
//     }
//   }

//   Future<void> _saveVideo() async {
//     // طلب الإذن للتخزين
//     PermissionStatus permissionStatus = await Permission.storage.request();
//     if (permissionStatus.isGranted) {
//       final bool? success = await GallerySaver.saveVideo(widget.videoUrl);
//       if (success != null && success) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Video saved to gallery!')),
//         );
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Error saving video.')),
//         );
//       }
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Storage permission denied.')),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Video Player')),
//       body: Center(
//         child: _controller.value.isInitialized
//             ? AspectRatio(
//                 aspectRatio: _controller.value.aspectRatio,
//                 child: VideoPlayer(_controller),
//               )
//             : CircularProgressIndicator(),
//       ),
//       floatingActionButton: Column(
//         mainAxisAlignment: MainAxisAlignment.end,
//         children: [
//           FloatingActionButton(
//             onPressed: () {
//               setState(() {
//                 _controller.value.isPlaying
//                     ? _controller.pause()
//                     : _controller.play();
//               });
//             },
//             child: Icon(
//               _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
//             ),
//           ),
//           SizedBox(height: 16), // Space between buttons
//           FloatingActionButton(
//             onPressed: _deleteMessage,
//             child: Icon(Icons.delete),
//           ),
//           SizedBox(height: 16), // Space between buttons
//           FloatingActionButton(
//             onPressed: _saveVideo, // حفظ الفيديو
//             child: Icon(Icons.save_alt),
//           ),
//         ],
//       ),
//     );
//   }
// }
