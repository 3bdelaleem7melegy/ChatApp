import 'dart:io';
import 'dart:typed_data';
import 'package:chatapp/Chats/HomeChat.dart';
import 'package:chatapp/Chats/LastSeenSettings.dart';
import 'package:chatapp/Chats/messagepage.dart';
import 'package:chatapp/Chats/settingotherperson.dart';
import 'package:chatapp/Chats/videopalyer.dart';
import 'package:chatapp/User%20Details%20And%20Update/userProfile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

class ChatPage extends StatefulWidget {
  final String currentUserId;
  final String otherUserId;
  final String otherUserName;
  final String otherUserImageUrl;
  final String otherUserPhone;
  final String otherUserBio;

  ChatPage({
    required this.currentUserId,
    required this.otherUserId,
    required this.otherUserName,
    required this.otherUserImageUrl,
    required this.otherUserPhone,
    required this.otherUserBio,
  });

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> with WidgetsBindingObserver {
  DocumentSnapshot? replyMessage; // الرسالة التي يتم الرد عليها
  bool isBlocked = false; // حالة الحظر

  // @override
  // void initState() {
  //   super.initState();
  //   _updateLastSeen(true); // تحديث آخر ظهور عند دخول المحادثة
  // }
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _updateLastSeen(true); // عند دخول المستخدم للتطبيق
    _checkBlockStatus(); // تحقق من حالة الحظر عند تحميل الشاشة
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _updateLastSeen(false); // عند خروج المستخدم من التطبيق
    super.dispose();
  }

  // مراقبة حالة التطبيق
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      _updateLastSeen(false); // إذا انتقل التطبيق إلى الخلفية أو أصبح غير نشط
    } else if (state == AppLifecycleState.resumed) {
      _updateLastSeen(true); // إذا عاد التطبيق إلى الواجهة
    }
  }

  // تحديث آخر ظهور وحالة الاتصال
  void _updateLastSeen(bool isOnline) async {
    await FirebaseFirestore.instance
        .collection('Patients')
        .doc(widget.currentUserId)
        .set({
      'lastSeen': FieldValue.serverTimestamp(),
      'isOnline': isOnline, // تحديث حالة الاتصال
    }, SetOptions(merge: true));
  }

  // دالة بناء واجهة "آخر ظهور"
  // Widget _buildLastSeen() {
  //   return FutureBuilder<DocumentSnapshot>(
  //     future: FirebaseFirestore.instance
  //         .collection('Patients')
  //         .doc(widget.otherUserId)
  //         .get(),
  //     builder: (context, snapshot) {
  //       if (snapshot.connectionState == ConnectionState.waiting) {
  //         return Text('Loading...');
  //       } else if (snapshot.hasError) {
  //         return Text('Error: ${snapshot.error}');
  //       } else if (snapshot.hasData && snapshot.data!.exists) {
  //         bool isLastSeenVisible = snapshot.data!['isLastSeenVisible'] ?? true;
  //         Timestamp? lastSeen = snapshot.data!['lastSeen'];
  //         bool isOnline = snapshot.data!['isOnline'] ?? false;

  //         if (isOnline) {
  //           return Text(
  //             'online',
  //             style: TextStyle(color: Colors.green, fontSize: 18),
  //           );
  //         }
  //         if (isLastSeenVisible && lastSeen != null) {
  //           DateTime lastSeenDate = lastSeen.toDate();
  //           DateTime now = DateTime.now();

  //           String lastSeenText;
  //           int daysDifference = now.difference(lastSeenDate).inDays;

  //           if (daysDifference == 0) {
  //             lastSeenText =
  //                 'last seen today at ${DateFormat('hh:mm a').format(lastSeenDate)}';
  //           } else if (daysDifference == 1) {
  //             lastSeenText =
  //                 'last seen yesterday at ${DateFormat('hh:mm a').format(lastSeenDate)}';
  //           }
  //           //  else if (daysDifference == 2) {
  //           //   lastSeenText =
  //           //       'last seen the day before yesterday at ${DateFormat('hh:mm a').format(lastSeenDate)}';
  //           // }
  //           else {
  //             lastSeenText =
  //                 'last seen at ${DateFormat('MMM d, hh:mm a').format(lastSeenDate)}';
  //           }

  //           return Text(
  //             lastSeenText,
  //             style: TextStyle(color: Colors.black, fontSize: 18),
  //           );
  //         } else {
  //           return Text('');
  //         }
  //       } else {
  //         return Text('');
  //       }
  //     },
  //   );
  // }
  Widget _buildLastSeen() {
  return FutureBuilder<DocumentSnapshot>(
    future: FirebaseFirestore.instance
        .collection('chats')
        .doc(getChatId())
        .get(),
    builder: (context, chatSnapshot) {
      if (!chatSnapshot.hasData || !chatSnapshot.data!.exists) {
        return Text(''); // إذا لم تكن هناك بيانات، لا نظهر "آخر ظهور"
      }

      // الحصول على بيانات المحادثة
      var chatData = chatSnapshot.data!.data() as Map<String, dynamic>;

      // التحقق من وجود الحقول
      bool isBlocked = chatData['isBlocked'] ?? false;
      String? blockedUserId = chatData['blockedUserId'];

      // التحقق مما إذا كان المستخدم الحالي محظورًا
      if (isBlocked && blockedUserId == widget.currentUserId) {
        return Text(''); // إخفاء "آخر ظهور" في حالة الحظر
      }

      // إذا لم يكن هناك حظر، نعرض آخر ظهور كما هو
      return FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('Patients')
            .doc(widget.otherUserId)
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Text('Loading...');
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else if (snapshot.hasData && snapshot.data!.exists) {
            var userData = snapshot.data!.data() as Map<String, dynamic>;
            bool isLastSeenVisible = userData['isLastSeenVisible'] ?? true;
            Timestamp? lastSeen = userData['lastSeen'];
            bool isOnline = userData['isOnline'] ?? false;

            if (isOnline) {
              return Text(
                'online',
                style: TextStyle(color: Colors.green, fontSize: 18),
              );
            }
            if (isLastSeenVisible && lastSeen != null) {
              DateTime lastSeenDate = lastSeen.toDate();
              DateTime now = DateTime.now();

              String lastSeenText;
              int daysDifference = now.difference(lastSeenDate).inDays;

              if (daysDifference == 0) {
                lastSeenText =
                    'last seen today at ${DateFormat('hh:mm a').format(lastSeenDate)}';
              } else if (daysDifference == 1) {
                lastSeenText =
                    'last seen yesterday at ${DateFormat('hh:mm a').format(lastSeenDate)}';
              } else {
                lastSeenText =
                    'last seen at ${DateFormat('MMM d, hh:mm a').format(lastSeenDate)}';
              }

              return Text(
                lastSeenText,
                style: TextStyle(color: Colors.black, fontSize: 15),
              );
            } else {
              return Text('');
            }
          } else {
            return Text('');
          }
        },
      );
    },
  );
}


  String getChatId() {
    return widget.currentUserId.hashCode <= widget.otherUserId.hashCode
        ? '${widget.currentUserId}-${widget.otherUserId}'
        : '${widget.otherUserId}-${widget.currentUserId}';
  }

  void _showFullImage(BuildContext context, String? imageUrl, String chatId,
      String messageId) async {
    if (imageUrl == null || imageUrl.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Invalid image URL')),
      );
      return;
    }

    Uint8List? imageData = await _downloadImage(imageUrl);
    if (imageData == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error downloading image')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          child: Container(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.memory(imageData),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    TextButton(
                      child: Text('Close'),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                    TextButton(
                      child: Text('Save Image'),
                      onPressed: () async {
                        final result =
                            await ImageGallerySaver.saveImage(imageData);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Image saved to gallery!')),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<Uint8List?> _downloadImage(String url) async {
    try {
      final ByteData imageData =
          await NetworkAssetBundle(Uri.parse(url)).load("");
      return imageData.buffer.asUint8List();
    } catch (e) {
      print('Error downloading image: $e');
      return null;
    }
  }

  Future<void> _deleteMessage(String chatId, String messageId, String? imageUrl,
      String? videoUrl) async {
    try {
      await FirebaseFirestore.instance
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .doc(messageId)
          .delete();

      // حذف الصورة إذا كانت موجودة
      if (imageUrl != null && imageUrl.isNotEmpty) {
        await FirebaseStorage.instance.refFromURL(imageUrl).delete();
      }

      // حذف الفيديو إذا كان موجودًا
      if (videoUrl != null && videoUrl.isNotEmpty) {
        await FirebaseStorage.instance.refFromURL(videoUrl).delete();
      }

      print('Message and media deleted successfully');
    } catch (e) {
      print('Error deleting message or media: $e');
    }
  }

  Future<String?> _generateThumbnail(String videoUrl) async {
    try {
      final thumbnailPath = await VideoThumbnail.thumbnailFile(
        video: videoUrl,
        thumbnailPath: (await getTemporaryDirectory()).path,
        imageFormat: ImageFormat.JPEG,
        maxHeight: 200, // Thumbnail height
        quality: 75, // Quality of the thumbnail
      );
      print('Thumbnail generated at: $thumbnailPath');
      return thumbnailPath;
    } catch (e) {
      print('Error generating thumbnail: $e');
      return null;
    }
  }
// void _markMessagesAsDelivered() async {
//   final chatRef = FirebaseFirestore.instance
//       .collection('chats')
//       .doc(getChatId())
//       .collection('messages');

//   final snapshot = await chatRef.where('receiverId', isEqualTo: widget.currentUserId)
//       .where('status', isEqualTo: 'sent')
//       .get();

//   for (var doc in snapshot.docs) {
//     await doc.reference.update({'status': 'delivered'});
//   }
// }
  void _markMessagesAsSeen() async {
    final chatRef = FirebaseFirestore.instance
        .collection('chats')
        .doc(getChatId())
        .collection('messages');

    final snapshot = await chatRef
        .where('receiverId', isEqualTo: widget.currentUserId)
        .where('status', isEqualTo: 'delivered')
        .get();

    for (var doc in snapshot.docs) {
      await doc.reference.update({'status': 'seen'});
    }
  }

  void _deleteChat() async {
    final chatMessages = FirebaseFirestore.instance
        .collection('chats')
        .doc(getChatId())
        .collection('messages');

    final messagesSnapshot = await chatMessages.get();

    for (var doc in messagesSnapshot.docs) {
      await doc.reference.delete();
    }

    print("Chat deleted");
  }

  void _confirmDeleteChat(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Delete'),
          content: Text('Are you sure you want to delete this conversation?'),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(); // إغلاق الحوار
              },
            ),
            TextButton(
              child: Text('Delete'),
              onPressed: () {
                _deleteChat();
                Navigator.of(context).pop(); // إغلاق الحوار بعد الحذف
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _checkBlockStatus() async {
    final chatRef =
        FirebaseFirestore.instance.collection('chats').doc(getChatId());
    final chatDoc = await chatRef.get();

    if (chatDoc.exists) {
      setState(() {
        isBlocked = chatDoc['isBlocked'] ?? false; // تحديث حالة الحظر
      });
    }
  }

  Future<void> _toggleBlockStatus() async {
    final chatRef =
        FirebaseFirestore.instance.collection('chats').doc(getChatId());

    // الحصول على الحالة الحالية من قاعدة البيانات
    final chatDoc = await chatRef.get();
    if (chatDoc.exists) {
      bool currentBlockStatus = chatDoc.data()?['isBlocked'] ?? false;

      // عكس حالة الحظر
      await chatRef.update({
        'isBlocked': !currentBlockStatus,
        'blockedUserId': currentBlockStatus
            ? null
            : widget.otherUserId, // تحديث ID المستخدم المحظور
      });

      print(currentBlockStatus
          ? 'User has been unblocked'
          : 'User has been blocked');
    }
  }

  bool isUserBlockedByCurrentUser(String? blockedUserId) {
    // تحقق مما إذا كان الشخص المحظور هو المستخدم الحالي
    return blockedUserId ==
        widget
            .currentUserId; // assuming 'blockedUserId' is the id of the blocked user
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        toolbarHeight: 100, // تحديد ارتفاع أكبر لشريط الأدوات
        title: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment
                .center, // تعديل المحاذاة العمودية لتكون في المنتصف
            mainAxisAlignment: MainAxisAlignment
                .spaceBetween, // جعل العناصر متباعدة لليمين واليسار
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: Icon(Icons.arrow_back),
                  ),
                  GestureDetector(
                      onTap: () {
                        // التنقل إلى الصفحة الجديدة عند الضغط على الصورة
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Settingotherperson(
                              currentUserId: widget.currentUserId,
                              otherUserId: widget.otherUserId,
                              otherUserName: widget.otherUserName,
                              otherUserImageUrl: widget.otherUserImageUrl,
                              otherUserPhone: widget.otherUserPhone,
                              otherUserBio: widget.otherUserBio,
                            ),
                          ),
                        );
                      },
                      child: StreamBuilder<DocumentSnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('chats')
                            .doc(getChatId())
                            .snapshots(),
                        builder: (context, snapshot) {
                          // عند عدم وجود بيانات أو عدم وجود محادثة
                          if (!snapshot.hasData || !snapshot.data!.exists) {
                            return CircleAvatar(
                              radius: 30,
                              backgroundColor: Colors.grey, // لون افتراضي
                              child: Icon(Icons.person,
                                  color:
                                      Colors.white), // أيقونة مستخدم افتراضية
                            );
                          }

                          // الحصول على حالة الحظر
                          bool isBlocked =
                              snapshot.data!.get('isBlocked') ?? false;
                          String? blockedUserId =
                              snapshot.data!.get('blockedUserId');

                          // التحقق مما إذا كان المستخدم الحالي هو المحظور
                          bool isCurrentUserBlocked = isBlocked &&
                              blockedUserId == widget.currentUserId;

                          // عرض الصورة بناءً على حالة الحظر
                          return isCurrentUserBlocked
                              ? CircleAvatar(
                                  radius: 30,
                                  backgroundColor:
                                      Colors.grey, // خلفية رمادية عند الحظر
                                  child: Icon(Icons.person,
                                      color: Colors.black), // أيقونة حظر
                                )
                              : CircleAvatar(
                                  radius: 30,
                                  backgroundImage:
                                      NetworkImage(widget.otherUserImageUrl),
                                  onBackgroundImageError:
                                      (exception, stackTrace) {
                                    print("Error loading image: $exception");
                                  },
                                );
                        },
                      )),
                  SizedBox(width: 10), // مسافة صغيرة بين الصورة والعناصر الأخرى
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: () {
                          // التنقل إلى الصفحة الجديدة عند الضغط على الاسم
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => Settingotherperson(
                                currentUserId: widget.currentUserId,
                                otherUserId: widget.otherUserId,
                                otherUserName: widget.otherUserName,
                                otherUserImageUrl: widget.otherUserImageUrl,
                                otherUserPhone: widget.otherUserPhone,
                                otherUserBio: widget.otherUserBio,
                              ),
                            ),
                          );
                        },
                        child: Text(
                          '${widget.otherUserName}',
                          style: TextStyle(fontSize: 18),
                        ),
                      ),

                      _buildLastSeen(), // إضافة آخر ظهور
                    ],
                  ),
                ],
              ),
              // إضافة PopupMenuButton إلى اليمين
              StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('chats')
                    .doc(getChatId())
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData || !snapshot.data!.exists) {
                    return SizedBox(); // إذا لم تكن هناك بيانات، لا تظهر أيقونة الحظر
                  }

                  // الحصول على حالة الحظر
                  bool isBlocked = snapshot.data!.get('isBlocked') ?? false;
                  String? blockedUserId = snapshot.data!.get('blockedUserId');

                  return PopupMenuButton<String>(
                    icon: Icon(Icons
                        .more_vert), // الأيقونة الرئيسية التي تحتوي على الخيارات
                    onSelected: (value) {
                      if (value == 'block') {
                        if (!isBlocked ||
                            !isUserBlockedByCurrentUser(blockedUserId)) {
                          _toggleBlockStatus();
                        }
                      } else if (value == 'delete') {
                        _confirmDeleteChat(context);
                      }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'block',
                        child: Row(
                          children: [
                            Icon(
                              isBlocked ? Icons.block : Icons.block_outlined,
                              color: isBlocked ? Colors.red : Colors.grey,
                            ),
                            SizedBox(width: 8),
                            Text(isBlocked ? 'Unblock User' : 'Block User'),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, color: Colors.grey),
                            SizedBox(width: 8),
                            Text('Delete Chat'),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          // إظهار زر الحظر فقط للمستخدم الحالي

          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('chats')
                  .doc(getChatId())
                  .collection('messages')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasData) {
                  // _markMessagesAsDelivered();
                  _markMessagesAsSeen();
                }
                // تحقق من حالة البلوك قبل عرض الرسائل
                final messages = snapshot.data!.docs;

                return ListView.builder(
                  reverse: true,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    var message = messages[index];

                    bool isSentByCurrentUser =
                        message['senderId'] == widget.currentUserId;

                    return Align(
                      alignment: isSentByCurrentUser
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: GestureDetector(
                        onLongPress: () {
                          _showMessageOptions(message);
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: isSentByCurrentUser
                                ? const Color.fromARGB(255, 99, 230, 106)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: EdgeInsets.all(10),
                          margin:
                              EdgeInsets.symmetric(vertical: 5, horizontal: 8),
                          child: Column(
                            crossAxisAlignment: isSentByCurrentUser
                                ? CrossAxisAlignment.end
                                : CrossAxisAlignment.start,
                            children: [
                              // Text(
                              //   message['senderId'] == widget.currentUserId
                              //       ? 'You'
                              //       : widget.otherUserName,
                              //   style: TextStyle(
                              //     fontSize: 12,
                              //     color: Colors.black,
                              //   ),
                              // ),
                              SizedBox(
                                height: 5,
                              ),
                              if (message['replyTo'] !=
                                  null) // عرض الرسالة التي يتم الرد عليها
                                FutureBuilder<DocumentSnapshot>(
                                  future: FirebaseFirestore.instance
                                      .collection('chats')
                                      .doc(getChatId())
                                      .collection('messages')
                                      .doc(message['replyTo'])
                                      .get(),
                                  builder: (context, snapshot) {
                                    if (snapshot.hasData &&
                                        snapshot.data!.exists) {
                                      var replyData = snapshot.data!.data()
                                          as Map<String, dynamic>;

                                      if (replyData['text'] != null &&
                                          replyData['text'].isNotEmpty) {
                                        return Column(children: [
                                          Text(
                                            message['senderId'] ==
                                                    widget.currentUserId
                                                ? 'You'
                                                : widget.otherUserName,
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.black,
                                            ),
                                          ),
                                          Text(
                                            'Replying to: ${replyData['text']}',
                                            style: TextStyle(
                                              fontStyle: FontStyle.italic,
                                              color: Colors.black,
                                            ),
                                          )
                                        ]);
                                      } else if (replyData['imageUrl'] !=
                                              null &&
                                          replyData['imageUrl'].isNotEmpty) {
                                        return Column(
                                          children: [
                                            Text(
                                              message['senderId'] ==
                                                      widget.currentUserId
                                                  ? 'You'
                                                  : widget.otherUserName,
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.black,
                                              ),
                                            ),
                                            Container(
                                              width: 100, // عرض الصورة المصغرة
                                              height:
                                                  100, // ارتفاع الصورة المصغرة
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                child: Image.network(
                                                  replyData[
                                                      'imageUrl'], // عرض الصورة المصغرة
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                            ),
                                            SizedBox(
                                                height:
                                                    8), // مسافة بين الصورة والنص
                                          ],
                                        );
                                      } else if (replyData['videoUrl'] !=
                                              null &&
                                          replyData['videoUrl'].isNotEmpty) {
                                        return Column(
                                          children: [
                                            Text(
                                              message['senderId'] ==
                                                      widget.currentUserId
                                                  ? 'You'
                                                  : widget.otherUserName,
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.black,
                                              ),
                                            ),
                                            Container(
                                              width: 100, // Thumbnail width
                                              height: 100, // Thumbnail height
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                child: FutureBuilder<String?>(
                                                  future: _generateThumbnail(
                                                      replyData[
                                                          'videoUrl']), // Generate thumbnail
                                                  builder: (context, snapshot) {
                                                    if (snapshot
                                                            .connectionState ==
                                                        ConnectionState
                                                            .waiting) {
                                                      return Center(
                                                          child:
                                                              CircularProgressIndicator()); // Show loading indicator
                                                    } else if (snapshot
                                                            .hasError ||
                                                        snapshot.data == null) {
                                                      return Center(
                                                          child: Text(
                                                              'Error loading thumbnail')); // Error handling
                                                    } else {
                                                      final thumbnailPath = snapshot
                                                          .data; // Get the thumbnail path

                                                      return Image.file(
                                                        File(
                                                            thumbnailPath!), // Display the thumbnail image
                                                        fit: BoxFit.cover,
                                                      );
                                                    }
                                                  },
                                                ),
                                              ),
                                            ),
                                            SizedBox(width: 4),
                                          ],
                                        );
                                      }
                                    }
                                    return SizedBox.shrink();
                                  },
                                ),
                              if (message['imageUrl'] != null &&
                                  message['imageUrl'].isNotEmpty)
                                GestureDetector(
                                  onTap: () {
                                    _showFullImage(context, message['imageUrl'],
                                        getChatId(), message.id);
                                  },
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment
                                        .end, // ضبط المحاذاة إلى اليسار
                                    children: [
                                      Image.network(
                                        message['imageUrl'],
                                        height: 300,
                                        width: 200,
                                        fit: BoxFit.cover,
                                      ),
                                      SizedBox(
                                          height: 5), // مسافة بين الصورة والوقت
                                      Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              message['timestamp'] !=
                                                      null // تحقق من وجود timestamp
                                                  ? DateFormat.jm().format(message[
                                                          'timestamp']
                                                      .toDate()) // تحويل وقت الرسالة إلى صيغة مقروءة
                                                  : 'Unknown', // نص بديل إذا كانت القيمة null
                                              style: TextStyle(
                                                fontSize:
                                                    11, // حجم خط أصغر لوقت الرسالة
                                                color: Colors.black,
                                                // لون رمادي لوقت الرسالة
                                                // fontWeight: FontWeight.bold
                                              ),
                                            ),
                                            SizedBox(
                                              width: 3,
                                            ),
                                            Icon(
                                              message['status'] == 'sent'
                                                  ? Icons.check
                                                  : message['status'] ==
                                                          'delivered'
                                                      ? Icons.done_all
                                                      : Icons
                                                          .done_all, // علامة مرئية للرسالة التي تم رؤيتها
                                              color: message['status'] == 'seen'
                                                  ? Colors.blue
                                                  : Colors.black,
                                              size: 15,
                                            ),
                                          ]),
                                    ],
                                  ),
                                ),
                              if (message['videoUrl'] != null &&
                                  message['videoUrl'].isNotEmpty)
                                GestureDetector(
                                  onTap: () {
                                    _showFullVideo(context, message['videoUrl'],
                                        getChatId(), message.id);
                                  },
                                  child: FutureBuilder<String?>(
                                    future:
                                        _generateThumbnail(message['videoUrl']),
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState ==
                                          ConnectionState.waiting) {
                                        return Center(
                                            child: CircularProgressIndicator());
                                      } else if (snapshot.hasError) {
                                        print(
                                            'Error generating thumbnail: ${snapshot.error}');
                                        return Text('Error loading thumbnail');
                                      } else {
                                        final thumbnailPath = snapshot.data;

                                        return Column(
                                          crossAxisAlignment: CrossAxisAlignment
                                              .end, // ضبط المحاذاة
                                          children: [
                                            Container(
                                              height: 300,
                                              width: 200,
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                image: DecorationImage(
                                                  image: thumbnailPath != null
                                                      ? FileImage(
                                                          File(thumbnailPath))
                                                      : AssetImage(
                                                          'assets/12.jpg'), // صورة مؤقتة إذا كان thumbnail فارغًا
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                              child: Center(
                                                child: Icon(
                                                  Icons.play_circle_fill,
                                                  size: 50,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                            SizedBox(
                                                height:
                                                    5), // مسافة بين الصورة والوقت
                                            SizedBox(
                                                height:
                                                    5), // مسافة بين الصورة والوقت
                                            Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Text(
                                                    message['timestamp'] !=
                                                            null // تحقق من وجود timestamp
                                                        ? DateFormat.jm()
                                                            .format(message[
                                                                    'timestamp']
                                                                .toDate()) // تحويل وقت الرسالة إلى صيغة مقروءة
                                                        : 'Unknown', // نص بديل إذا كانت القيمة null
                                                    style: TextStyle(
                                                      fontSize:
                                                          11, // حجم خط أصغر لوقت الرسالة
                                                      color: Colors.black,
                                                      // لون رمادي لوقت الرسالة
                                                      // fontWeight: FontWeight.bold
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    width: 3,
                                                  ),
                                                  Icon(
                                                    message['status'] == 'sent'
                                                        ? Icons.check
                                                        : message['status'] ==
                                                                'delivered'
                                                            ? Icons.done_all
                                                            : Icons
                                                                .done_all, // علامة مرئية للرسالة التي تم رؤيتها
                                                    color: message['status'] ==
                                                            'seen'
                                                        ? Colors.blue
                                                        : Colors.black,
                                                    size: 15,
                                                  ),
                                                ]),
                                          ],
                                        );
                                      }
                                    },
                                  ),
                                ),
                              if (message['text'].isNotEmpty)
                                Column(children: [
                                  Row(
                                      mainAxisSize: MainAxisSize
                                          .min, // استخدم الحد الأدنى من الحجم

                                      children: [
                                        Text(
                                          message['text'] ?? '',
                                          style: TextStyle(
                                            color: isSentByCurrentUser
                                                ? Colors.black
                                                : Colors.black,
                                          ),
                                        ),

                                        SizedBox(
                                            width:
                                                4), // مساحة بين الأيقونة ووقت الرسالة
                                        Text(
                                          message['timestamp'] !=
                                                  null // تحقق من وجود timestamp
                                              ? DateFormat.jm().format(message[
                                                      'timestamp']
                                                  .toDate()) // تحويل وقت الرسالة إلى صيغة مقروءة
                                              : '', // نص بديل إذا كانت القيمة null
                                          style: TextStyle(
                                            fontSize:
                                                11, // حجم خط أصغر لوقت الرسالة
                                            color: Colors.black,
                                            // لون رمادي لوقت الرسالة
                                            // fontWeight: FontWeight.bold
                                          ),
                                        ),
                                        SizedBox(
                                          width: 3,
                                        ),
                                        Icon(
                                          message['status'] == 'sent'
                                              ? Icons.check
                                              : message['status'] == 'delivered'
                                                  ? Icons.done_all
                                                  : Icons
                                                      .done_all, // علامة مرئية للرسالة التي تم رؤيتها
                                          color: message['status'] == 'seen'
                                              ? Colors.blue
                                              : Colors.black,
                                          size: 15,
                                        ),
                                      ]),
                                ]),
                              // if (isSentByCurrentUser) // عرض الأيقونة فقط إذا كانت الرسالة مرسلة من المستخدم الحالي
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),

          // MessageInput(
          //   chatId: getChatId(),
          //   currentUserId: widget.currentUserId,
          //   otherUserId: widget.otherUserId,
          //   replyMessage: replyMessage, // تمرير الرسالة التي يتم الرد عليها
          //   onCancelReply: () {
          //     setState(() {
          //       replyMessage = null; // إلغاء الرد
          //     });
          //   },
          // ),

          // StreamBuilder<DocumentSnapshot>(
          //   stream: FirebaseFirestore.instance
          //       .collection('chats')
          //       .doc(getChatId())
          //       .snapshots(),
          //   builder: (context, snapshot) {
          //     // عند عدم وجود بيانات، نظهر حقل الإدخال بدون بيانات
          //     if (!snapshot.hasData) {
          //       return Column(
          //         children: [
          //           MessageInput(
          //             chatId: getChatId(),
          //             currentUserId: widget.currentUserId,
          //             otherUserId: widget.otherUserId,
          //             replyMessage: replyMessage,
          //             onCancelReply: () {
          //               setState(() {
          //                 replyMessage = null;
          //               });
          //             },
          //             isBlocked:
          //                 false, // افتراض عدم وجود حظر عند عدم وجود بيانات
          //           ),
          //           Container(
          //             padding: EdgeInsets.all(16),
          //             child: Text(
          //               "لا توجد محادثة بعد.",
          //               style: TextStyle(color: Colors.grey, fontSize: 16),
          //             ),
          //           ),
          //         ],
          //       );
          //     }

          //     // إذا كانت البيانات موجودة، تحقق من حالة الحظر
          //     if (!snapshot.data!.exists) {
          //       return Column(
          //         children: [
          //           MessageInput(
          //             chatId: getChatId(),
          //             currentUserId: widget.currentUserId,
          //             otherUserId: widget.otherUserId,
          //             replyMessage: replyMessage,
          //             onCancelReply: () {
          //               setState(() {
          //                 replyMessage = null;
          //               });
          //             },
          //             isBlocked:
          //                 false, // افتراض عدم وجود حظر عند عدم وجود بيانات
          //           ),
          //           Container(
          //             padding: EdgeInsets.all(16),
          //             child: Text(
          //               "لا توجد محادثة بعد.",
          //               style: TextStyle(color: Colors.grey, fontSize: 16),
          //             ),
          //           ),
          //         ],
          //       );
          //     }

          //     // الحصول على حالة الحظر
          //     bool isBlocked = snapshot.data!.get('isBlocked') ?? false;
          //     String? blockedUserId = snapshot.data!.get('blockedUserId');

          //     // التحقق مما إذا كان المستخدم الآخر هو المحظور
          //     bool isCurrentUserBlocked =
          //         isBlocked && blockedUserId == widget.currentUserId;

          //     return Column(
          //       children: [
          //         // حقل الإدخال
          //         MessageInput(
          //           chatId: getChatId(),
          //           currentUserId: widget.currentUserId,
          //           otherUserId: widget.otherUserId,
          //           replyMessage: replyMessage,
          //           onCancelReply: () {
          //             setState(() {
          //               replyMessage = null;
          //             });
          //           },
          //           isBlocked: isCurrentUserBlocked, // تمرير حالة الحظر
          //         ),
          //         if (isCurrentUserBlocked) ...[
          //           Container(
          //             padding: EdgeInsets.all(16),
          //             color: Colors.redAccent,
          //             child: Column(
          //               crossAxisAlignment: CrossAxisAlignment.start,
          //               children: [
          //                 Text(
          //                   "لقد تم حظرك من قبل هذا المستخدم، لا يمكنك إرسال الرسائل.",
          //                   style: TextStyle(color: Colors.white, fontSize: 16),
          //                 ),
          //               ],
          //             ),
          //           ),
          //         ],
          //       ],
          //     );
          //   },
          // ),
          StreamBuilder<DocumentSnapshot>(
  stream: FirebaseFirestore.instance
      .collection('chats')
      .doc(getChatId())
      .snapshots(),
  builder: (context, snapshot) {
    // عند عدم وجود بيانات، نظهر رسالة "لا توجد محادثة بعد."
    if (!snapshot.hasData) {
      return Center(
        child: Text("لا توجد محادثة بعد."),
      );
    }

    // إذا كانت البيانات موجودة، تحقق من حالة الحظر
    if (!snapshot.data!.exists) {
      return Column(
                  children: [
                    MessageInput(
                      chatId: getChatId(),
                      currentUserId: widget.currentUserId,
                      otherUserId: widget.otherUserId,
                      replyMessage: replyMessage,
                      onCancelReply: () {
                        setState(() {
                          replyMessage = null;
                        });
                      },
                      isBlocked:
                          false, // افتراض عدم وجود حظر عند عدم وجود بيانات
                    ),
                    Container(
                      padding: EdgeInsets.all(16),
                      child: Text(
                        "لا توجد محادثة بعد.",
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                    ),
                  ],
                );
    }

    // الحصول على حالة الحظر
    bool isBlocked = snapshot.data!.get('isBlocked') ?? false;
    String? blockedUserId = snapshot.data!.get('blockedUserId');

    // التحقق مما إذا كان المستخدم الآخر هو المحظور
    bool isCurrentUserBlocked =
        isBlocked && blockedUserId == widget.currentUserId;

    if (isCurrentUserBlocked) {
      // إذا كان المستخدم محظورًا، عرض رسالة فقط
      return Container(
        padding: EdgeInsets.all(16),
        color: Colors.redAccent,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "لقد تم حظرك من قبل هذا المستخدم، لا يمكنك إرسال الرسائل.",
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ],
        ),
      );
    }

    // إذا لم يكن المستخدم محظورًا، عرض حقل الإدخال
    return Column(
      children: [
        MessageInput(
          chatId: getChatId(),
          currentUserId: widget.currentUserId,
          otherUserId: widget.otherUserId,
          replyMessage: replyMessage,
          onCancelReply: () {
            setState(() {
              replyMessage = null;
            });
          },
          isBlocked: false, // ليس محظورًا هنا
        ),
        // يمكن إضافة المزيد من العناصر هنا حسب الحاجة
      ],
    );
  },
),

        ],
      ),
    );
  }

  void _showMessageOptions(DocumentSnapshot message) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Wrap(
          children: <Widget>[
            ListTile(
              leading: Icon(Icons.reply),
              title: Text('Reply'),
              onTap: () {
                setState(() {
                  replyMessage = message; // تعيين الرسالة للرد
                });
                Navigator.pop(context); // إغلاق القائمة
              },
            ),
            ListTile(
              leading: Icon(Icons.delete),
              title: Text('Delete'),
              onTap: () {
                Navigator.pop(context); // إغلاق القائمة
                _deleteMessage(getChatId(), message.id, message['imageUrl'],
                    message['videoUrl']);
              },
            ),
          ],
        );
      },
    );
  }
}

void _showFullVideo(
    BuildContext context, String videoUrl, String chatId, String messageId) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => VideoPlayerScreen(
        videoUrl: videoUrl,
        chatId: chatId,
        messageId: messageId,
      ),
    ),
  );
}
