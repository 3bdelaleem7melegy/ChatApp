import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class MessageInput extends StatefulWidget {
  final String chatId;
  final String currentUserId;
  final String otherUserId;
  final DocumentSnapshot? replyMessage;
  final VoidCallback onCancelReply;
  final bool isBlocked; // إضافة هذه المتغير

  MessageInput({
    required this.chatId,
    required this.currentUserId,
    required this.otherUserId,
    this.replyMessage,
    required this.onCancelReply,
    required this.isBlocked, // إضافة المتغير إلى الباني
  });

  @override
  _MessageInputState createState() => _MessageInputState();
}

class _MessageInputState extends State<MessageInput> {
  final TextEditingController _controller = TextEditingController();
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late User? user; // تغيير نوع المتغير ليكون قابلاً لأن يكون null
  bool isBlocked = false; // حالة الحظر

  @override
  void initState() {
    super.initState();
    _initializeUser(); // استدعاء دالة التهيئة
  }

  Future<void> _initializeUser() async {
    user = _auth.currentUser; // جلب المستخدم الحالي
    if (user == null) {
      // إذا لم يكن هناك مستخدم، يمكنك اتخاذ إجراءات أخرى هنا
      print('No user is logged in');
    }
    setState(() {}); // إعادة بناء الواجهة بعد التهيئة
  }

  void _markMessagesAsDelivered() async {
    final chatRef = FirebaseFirestore.instance
        .collection('chats')
        .doc(widget.chatId)
        .collection('messages');

    final snapshot = await chatRef
        .where('receiverId', isEqualTo: widget.otherUserId)
        .where('status', isEqualTo: 'sent')
        .get();

    for (var doc in snapshot.docs) {
      await doc.reference.update({'status': 'delivered'});
    }
  }

  Future<String> _checkBlockedStatus(
      String currentUserId, String otherUserId) async {
    final chatRef =
        FirebaseFirestore.instance.collection('chats').doc(widget.chatId);
    final chatDoc = await chatRef.get();
    if (chatDoc.exists) {
      final history = chatDoc.data()?['history'];
      if (history != null) {
        return history['${currentUserId}_${otherUserId}'] ?? 'unblocked';
      }
    }
    return 'unblocked';
  }

//   Future<void> _sendMessage({String? imageUrl, String? videoUrl}) async {
//     if (user == null) {
//       // إذا لم يكن هناك مستخدم، إظهار رسالة خطأ
//       print('User is not initialized');
//       return;
//     }

//     final text = _controller.text.trim();
//     if (text.isEmpty && imageUrl == null && videoUrl == null) return;
// // تحقق مما إذا كانت المحادثة موجودة
//     final chatRef =
//         FirebaseFirestore.instance.collection('chats').doc(widget.chatId);

//     final chatDoc = await chatRef.get();
//     if (!chatDoc.exists) {
//       // إنشاء مستند المحادثة إذا لم يكن موجودًا
//       await chatRef.set({
//         'users': [widget.currentUserId, widget.otherUserId],
//         // 'createdAt': FieldValue.serverTimestamp(),
//         'lastMessageTimestamp': FieldValue.serverTimestamp(), // إضافة هذا الحقل

//       });
//     } else {
//       // تحديث حقل `lastMessageTimestamp` إذا كانت المحادثة موجودة
//       await chatRef.update({
//         'lastMessageTimestamp': FieldValue.serverTimestamp(),
//       });
//     }

// var connectivityResult = await (Connectivity().checkConnectivity());

//   String status = 'sent'; // الحالة المبدئية

//   // إذا كان متصلًا بالإنترنت، يتم تحديث الحالة إلى "delivered" بعد الإرسال
//   if (connectivityResult != ConnectivityResult.none) {
//     status = 'delivered';
//   }
//   else {
//     status = 'sent';
//   }
//     await FirebaseFirestore.instance
//         .collection('chats')
//         .doc(widget.chatId)
//         .collection('messages')
//         .add({
//       'text': text,
//       'senderId': widget.currentUserId,
//       'receiverId': widget.otherUserId,
//       'timestamp': FieldValue.serverTimestamp(),
//       'imageUrl': imageUrl ?? '',
//       'videoUrl': videoUrl ?? '',
//       'name': user!.displayName ??
//           'Unknown', // استخدام user بعد التحقق من أنه ليس null
//       'sender': user!.email ?? 'Unknown',
//       'replyTo': widget.replyMessage != null
//           ? widget.replyMessage!.id
//           : null, // إضافة معلومات الرد
//       'status': status, // الحالة المبدئية
//     });

// if (connectivityResult != ConnectivityResult.none) {
//     _markMessagesAsDelivered();
//   }
//     setState(() {
//       widget.onCancelReply(); // إعادة تعيين الرسالة التي يتم الرد عليها
//     });

//     _controller.clear();

//   if (connectivityResult != ConnectivityResult.none) {
//     _markMessagesAsDelivered();
//   }

//   setState(() {
//     widget.onCancelReply();
//   });

//   _controller.clear();

// }
  Future<void> blockUser() async {
    final chatRef =
        FirebaseFirestore.instance.collection('chats').doc(widget.chatId);

    await chatRef.update({
      'isBlocked': true,
    });

    print('User has been blocked');
  }

  Future<void> unblockUser() async {
    final chatRef =
        FirebaseFirestore.instance.collection('chats').doc(widget.chatId);

    await chatRef.update({
      'isBlocked': false,
    });

    print('User has been unblocked');
  }

  Future<void> _sendMessage({String? imageUrl, String? videoUrl}) async {
    if (user == null) {
      // إذا لم يكن هناك مستخدم، إظهار رسالة خطأ
      print('User is not initialized');
      return;
    }

    final text = _controller.text.trim();
    if (text.isEmpty && imageUrl == null && videoUrl == null) return;

    final chatRef =
        FirebaseFirestore.instance.collection('chats').doc(widget.chatId);
    final chatDoc = await chatRef.get();

    // تحقق مما إذا كان المستخدم الآخر محظورًا
    if (chatDoc.exists) {
      bool isBlocked = chatDoc.data()?['isBlocked'] ?? false;

      if (isBlocked &&
          widget.currentUserId == chatDoc.data()?['blockedUserId']) {
        print('You are blocked from sending messages to this user.');
        return; // منع الإرسال إذا كان المستخدم محظورًا
      }
    }

    if (!chatDoc.exists) {
      // إنشاء مستند المحادثة إذا لم يكن موجودًا
      await chatRef.set({
        'users': [widget.currentUserId, widget.otherUserId],
        'lastMessageTimestamp': FieldValue.serverTimestamp(),
        'isBlocked': false, // الحالة الابتدائية للحظر
        'blockedUserId': null, // المستخدم المحظور
      });
    } else {
      // تحديث حقل `lastMessageTimestamp` إذا كانت المحادثة موجودة
      await chatRef.update({
        'lastMessageTimestamp': FieldValue.serverTimestamp(),
      });
    }

    var connectivityResult = await (Connectivity().checkConnectivity());

    String status = 'sent';

    if (connectivityResult != ConnectivityResult.none) {
      status = 'delivered';
    } else {
      status = 'sent';
    }

    await FirebaseFirestore.instance
        .collection('chats')
        .doc(widget.chatId)
        .collection('messages')
        .add({
      'text': text,
      'senderId': widget.currentUserId,
      'receiverId': widget.otherUserId,
      'timestamp': FieldValue.serverTimestamp(),
      'imageUrl': imageUrl ?? '',
      'videoUrl': videoUrl ?? '',
      'name': user!.displayName ?? 'Unknown',
      'sender': user!.email ?? 'Unknown',
      'replyTo': widget.replyMessage != null ? widget.replyMessage!.id : null,
      'status': status,
    });

    if (connectivityResult != ConnectivityResult.none) {
      _markMessagesAsDelivered();
    }

    setState(() {
      widget.onCancelReply();
    });

    _controller.clear();
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
      setState(() {
        _imageFile = File(pickedFile.path);
      });

      final imageUrl = await _uploadImageToFirebase();
      _sendMessage(imageUrl: imageUrl);
    }
  }

  Future<void> _pickVideo() async {
    final pickedFile = await _picker.pickVideo(source: ImageSource.gallery);
    if (pickedFile != null) {
      File videoFile = File(pickedFile.path);

      // رفع الفيديو إلى Firebase
      final videoUrl = await _uploadVideoToFirebase(videoFile);
      if (videoUrl != null) {
        // إرسال الرسالة مع الفيديو
        await _sendMessage(videoUrl: videoUrl);
      } else {
        print('Failed to upload video');
      }
    }
  }

  Future<String?> _uploadImageToFirebase() async {
    if (_imageFile == null) return null;

    try {
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('chat_images')
          .child('${DateTime.now().millisecondsSinceEpoch}.jpg');
      final uploadTask = storageRef.putFile(_imageFile!);
      final snapshot = await uploadTask.whenComplete(() => null);
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }

  Future<String?> _uploadVideoToFirebase(File? videoFile) async {
    if (videoFile == null) return null;

    try {
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('chat_videos')
          .child('${DateTime.now().millisecondsSinceEpoch}.mp4');
      final uploadTask = storageRef.putFile(videoFile);
      final snapshot = await uploadTask.whenComplete(() => null);
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      print('Error uploading video: $e');
      return null;
    }
  }

  Future<void> _updateMessageStatus(String messageId, String status) async {
    await FirebaseFirestore.instance
        .collection('chats')
        .doc(widget.chatId)
        .collection('messages')
        .doc(messageId)
        .update({'status': status});
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (widget.replyMessage != null) ...[
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    widget.replyMessage!['text'],
                    style: TextStyle(color: Colors.black),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close),
                  onPressed: widget.onCancelReply, // إلغاء الرد
                ),
              ],
            ),
          ),
        ],
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              IconButton(
                icon: Icon(Icons.attach_file),
                onPressed: () => _pickMedia(context),
              ),
              Expanded(
                child: TextField(
                  controller: _controller,
                  decoration: InputDecoration(
                    hintText: 'Enter a message...',
                  ),
                  enabled:
                      !widget.isBlocked, // تعطيل حقل الإدخال إذا كان محظورًا
                ),
              ),
              IconButton(
                icon: Icon(Icons.send),
                onPressed: widget.isBlocked
                    ? null
                    : () => _sendMessage(), // تعطيل زر الإرسال إذا كان محظورًا
              ),
            ],
          ),
        ),
      ],
    );
  }
}
