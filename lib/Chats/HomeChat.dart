import 'package:chatapp/Chats/LastSeenSettings.dart';
import 'package:chatapp/Chats/chatpage.dart';
import 'package:chatapp/User%20Details%20And%20Update/userProfile.dart';
import 'package:chatapp/main.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:cached_network_image/cached_network_image.dart';

class HomeChat extends StatefulWidget {
  final String currentUserId;

  HomeChat({
    required this.currentUserId,
  });

  @override
  _HomeChatState createState() => _HomeChatState();
}

class _HomeChatState extends State<HomeChat> {
  String searchPhoneNumber = '';
  FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  @override
  void initState() {
    super.initState();

    // طلب إذن الإشعارات
    _firebaseMessaging.requestPermission();

    // استدعاء توكن الـ FCM
    _firebaseMessaging.getToken().then((token) {
      print("FCM Token: $token");
      // احفظ التوكن في Firebase إذا كنت بحاجة إلى ذلك
    });

    // استقبال الرسائل عندما يكون التطبيق في الخلفية أو في الوضع الأمامي
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("Message received: ${message.notification?.body}");
      _showNotification(
          message.notification?.title, message.notification?.body);
    });
  }

  void _showNotification(String? title, String? body) async {
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'channel_id', 'channel_name',
        importance: Importance.max, priority: Priority.high);
    var platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
      0,
      title,
      body,
      platformChannelSpecifics,
      payload: 'Default_Sound',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('Chats'),
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert), // أيقونة النقاط الثلاث
            onSelected: (String result) {
              // تنفيذ العمليات عند اختيار العنصر
              if (result == 'Option 1') {
                // تنفيذ الخيار الأول
              } else if (result == 'Option 2') {
                // تنفيذ الخيار الثاني
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              PopupMenuItem<String>(
                value: 'Option 1',
                child: Text('last seen and online'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => LastSeenSettingsPage(
                        currentUserId: widget.currentUserId,
                      ),
                    ),
                  );
                },
              ),
              PopupMenuItem<String>(
                value: 'Option 2',
                child: Text('My Account'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => UserProfile(),
                    ),
                  );
                },
              ),
            ],
          ),
        ]),

        // leading: IconButton(
        //     onPressed: () {
        //       Navigator.pop(context);
        //     },
        //     icon: Icon(Icons.arrow_back)),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search by phone number',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  searchPhoneNumber = value;
                });
              },
            ),
          ),
          Expanded(
            child: searchPhoneNumber.isEmpty
                ? _buildChatList() // إذا كانت خانة البحث فارغة، أظهر المحادثات
                : _buildUserList(), // إذا كان هناك بحث، أظهر قائمة المستخدمين
          ),
        ],
      ),
    );
  }

  Widget _buildUserList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('Patients')
          .where('phoneNumber', isEqualTo: searchPhoneNumber)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }

        final users = snapshot.data!.docs;

        if (users.isEmpty) {
          return Center(child: Text('No users found with this phone number.'));
        }

        return ListView.builder(
          itemCount: users.length,
          itemBuilder: (context, index) {
            var user = users[index];
            if (user.id == widget.currentUserId) return SizedBox();

            Map<String, dynamic> userData = user.data() as Map<String, dynamic>;

            return ListTile(
              leading: userData['imageUrl'] != null &&
                      userData['imageUrl'].isNotEmpty
                  ? CircleAvatar(
                      radius: 30,
                      backgroundImage: NetworkImage(userData['imageUrl'] ?? ''),
                    )
                  : CircleAvatar(child: Icon(Icons.person)),
              title: Text(userData['name'] ?? ''),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChatPage(
                      currentUserId: widget.currentUserId,
                      otherUserId: user.id,
                      otherUserName: user['name'],
                      otherUserImageUrl: user['imageUrl'],
                      otherUserPhone: user['phoneNumber'],
                      otherUserBio: user['bio'],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildChatList() {
    // return StreamBuilder<QuerySnapshot>(
    //   stream: FirebaseFirestore.instance
    //       .collection('chats')
    //       .where('users', arrayContains: widget.currentUserId)
    //       .orderBy('lastMessageTimestamp', descending: true)
    //       .snapshots(),
    //   builder: (context, snapshot) {
    //     if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
    //       return Center(child: Text('Not have any user'));
    //     }

    //     final chats = snapshot.data!.docs;

    //     return ListView.builder(
    //       itemCount: chats.length,
    //       itemBuilder: (context, index) {
    //         var chat = chats[index];
    //         var otherUserId = (chat['users'] as List)
    //             .firstWhere((userId) => userId != widget.currentUserId);
    //         var chatId = chat.id;

    //         return StreamBuilder<DocumentSnapshot>(
    //           stream: FirebaseFirestore.instance
    //               .collection('Patients')
    //               .doc(otherUserId)
    //               .snapshots(),
    //           builder: (context, userSnapshot) {
    //             if (!userSnapshot.hasData) {
    //               return ListTile(title: Text('Loading...'));
    //             }

    //             var otherUser = userSnapshot.data!;
    //             return ListTile(
    //               leading: CircleAvatar(
    //                 backgroundImage: NetworkImage(otherUser['imageUrl']),
    //               ),
    //               title: Text(otherUser['name']),
    //               subtitle: StreamBuilder<QuerySnapshot>(
    //                 stream: FirebaseFirestore.instance
    //                     .collection('chats')
    //                     .doc(chatId)
    //                     .collection('messages')
    //                     .orderBy('timestamp', descending: true)
    //                     .limit(1)
    //                     .snapshots(),
    //                 builder: (context, messageSnapshot) {
    //                   if (messageSnapshot.hasData &&
    //                       messageSnapshot.data!.docs.isNotEmpty) {
    //                     var lastMessage = messageSnapshot.data!.docs.first;
    //                     if (lastMessage['text'] != null &&
    //                         lastMessage['text'].isNotEmpty) {
    //                       return Text(lastMessage['text']); // نص الرسالة
    //                     } else if (lastMessage['imageUrl'] != null) {
    //                       return Row(
    //                         children: [
    //                           Icon(Icons.image, size: 20, color: Colors.grey),
    //                           SizedBox(width: 4),
    //                           Text('Photo'),
    //                         ],
    //                       );
    //                     } else if (lastMessage['videoUrl'] != null) {
    //                       return Row(
    //                         children: [
    //                           Icon(Icons.videocam,
    //                               size: 20, color: Colors.grey),
    //                           SizedBox(width: 4),
    //                           Text('Video'),
    //                         ],
    //                       );
    //                     } else {
    //                       return Text('');
    //                     }
    //                   } else {
    //                     return Text('');
    //                   }
    //                 },
    //               ),
    //               onTap: () {
    //                 Navigator.push(
    //                   context,
    //                   MaterialPageRoute(
    //                     builder: (context) => ChatPage(
    //                       currentUserId: widget.currentUserId,
    //                       otherUserId: otherUserId,
    //                       otherUserName: otherUser['name'],
    //                       otherUserImageUrl: otherUser['imageUrl'],
    //                       otherUserPhone: otherUser['phoneNumber'],
    //                       otherUserBio: otherUser['bio'],
    //                     ),
    //                   ),
    //                 );
    //               },
    //             );
    //           },
    //         );
    //       },
    //     );
    //   },
    // );
    return StreamBuilder<QuerySnapshot>(
  stream: FirebaseFirestore.instance
      .collection('chats')
      .where('users', arrayContains: widget.currentUserId)
      .orderBy('lastMessageTimestamp', descending: true)
      .snapshots(),
  builder: (context, snapshot) {
    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
      return Center(child: Text('Not have any user'));
    }

    final chats = snapshot.data!.docs;

    return ListView.builder(
      itemCount: chats.length,
      itemBuilder: (context, index) {
        var chat = chats[index];
        var otherUserId = (chat['users'] as List)
            .firstWhere((userId) => userId != widget.currentUserId);
        var chatId = chat.id;

        return StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('Patients')
              .doc(otherUserId)
              .snapshots(),
          builder: (context, userSnapshot) {
            if (!userSnapshot.hasData) {
              return ListTile(title: Text('Loading...'));
            }

            var otherUser = userSnapshot.data!;

            // التحقق من حالة الحظر
            return StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('chats')
                  .doc(chatId)
                  .snapshots(),
              builder: (context, chatSnapshot) {
                if (!chatSnapshot.hasData) {
                  return ListTile(title: Text('Loading...'));
                }

                bool isBlocked = chatSnapshot.data!.get('isBlocked') ?? false;
                String? blockedUserId = chatSnapshot.data!.get('blockedUserId');
                bool isCurrentUserBlocked = isBlocked && blockedUserId == widget.currentUserId;

                return ListTile(
                  leading: isCurrentUserBlocked
                      ? CircleAvatar(
                          backgroundColor: Colors.grey, // لون رمادي عند الحظر
                          child: Icon(Icons.person, color: Colors.black), // أيقونة حظر
                        )
                      : CircleAvatar(
                          backgroundImage: NetworkImage(otherUser['imageUrl']),
                        ),
                  title: Text(otherUser['name']),
                  subtitle: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('chats')
                        .doc(chatId)
                        .collection('messages')
                        .orderBy('timestamp', descending: true)
                        .limit(1)
                        .snapshots(),
                    builder: (context, messageSnapshot) {
                      if (messageSnapshot.hasData &&
                          messageSnapshot.data!.docs.isNotEmpty) {
                        var lastMessage = messageSnapshot.data!.docs.first;
                        if (lastMessage['text'] != null &&
                            lastMessage['text'].isNotEmpty) {
                          return Text(lastMessage['text']); // نص الرسالة
                        } else if (lastMessage['imageUrl'] != null) {
                          return Row(
                            children: [
                              Icon(Icons.image, size: 20, color: Colors.grey),
                              SizedBox(width: 4),
                              Text('Photo'),
                            ],
                          );
                        } else if (lastMessage['videoUrl'] != null) {
                          return Row(
                            children: [
                              Icon(Icons.videocam, size: 20, color: Colors.grey),
                              SizedBox(width: 4),
                              Text('Video'),
                            ],
                          );
                        } else {
                          return Text('');
                        }
                      } else {
                        return Text('');
                      }
                    },
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatPage(
                          currentUserId: widget.currentUserId,
                          otherUserId: otherUserId,
                          otherUserName: otherUser['name'],
                          otherUserImageUrl: otherUser['imageUrl'],
                          otherUserPhone: otherUser['phoneNumber'],
                          otherUserBio: otherUser['bio'],
                        ),
                      ),
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  },
);

  }

  String getChatId(String currentUserId, String otherUserId) {
    return currentUserId.hashCode <= otherUserId.hashCode
        ? '$currentUserId-$otherUserId'
        : '$otherUserId-$currentUserId';
  }
}
