// // import 'dart:async';
// // import 'package:cloud_firestore/cloud_firestore.dart';
// // import 'package:flutter/material.dart';
// // import 'package:video_player/video_player.dart';

// // class UserStoriesPage extends StatefulWidget {
// //   final String username;
// //   final List<QueryDocumentSnapshot> stories;

// //   UserStoriesPage({required this.username, required this.stories});

// //   @override
// //   _UserStoriesPageState createState() => _UserStoriesPageState();
// // }

// // class _UserStoriesPageState extends State<UserStoriesPage> {
// //   late PageController _pageController;
// //   VideoPlayerController? _videoController;
// //   bool _isVideoInitialized = false;
// //   int _currentPageIndex = 0;
// //   Timer? _timer;
// //   double _progress = 0.0;

// //   @override
// //   void initState() {
// //     super.initState();
// //     _pageController = PageController();
// //     _initializeStory(_currentPageIndex);
// //     _startTimer(); // بدء المؤقت عند تهيئة الصفحة
// //   }

// //   @override
// //   void dispose() {
// //     _videoController?.dispose();
// //     _pageController.dispose();
// //     _timer?.cancel(); // إلغاء المؤقت عند الإغلاق
// //     super.dispose();
// //   }

// //   Future<void> _initializeStory(int index) async {
// //     var story = widget.stories[index];

// //     if (_videoController != null && _videoController!.value.isInitialized) {
// //       await _videoController!.pause();
// //       await _videoController!.dispose();
// //     }

// //     if (story['videoUrl'] != null && story['videoUrl'].isNotEmpty) {
// //       _videoController = VideoPlayerController.network(story['videoUrl'])
// //         ..initialize().then((_) {
// //           setState(() {
// //             _isVideoInitialized = true;
// //           });
// //           _videoController!.play();
// //           _videoController!.addListener(() {
// //             if (_videoController!.value.position ==
// //                 _videoController!.value.duration) {
// //               _goToNextStory();
// //             }
// //           });
// //         });
// //     } else {
// //       setState(() {
// //         _isVideoInitialized = false;
// //       });
// //     }
// //   }

// //   void _startTimer() {
// //     // إلغاء المؤقت السابق إذا كان موجودًا
// //     _timer?.cancel();
// //     _progress = 0.0;

// //     // إعداد المؤقت حسب نوع المحتوى
// //     final story = widget.stories[_currentPageIndex];

// //     if (story['videoUrl'] != null && story['videoUrl'].isNotEmpty) {
// //       // إذا كان المحتوى فيديو، انتظر حتى انتهاء الفيديو
// //       _timer = Timer.periodic(Duration(milliseconds: 100), (timer) {
// //         setState(() {
// //           _progress = _videoController!.value.position.inMilliseconds /
// //               _videoController!.value.duration.inMilliseconds;
// //         });

// //         if (_videoController!.value.position ==
// //             _videoController!.value.duration) {
// //           _goToNextStory();
// //           timer.cancel();
// //         }
// //       });
// //     } else {
// //       // إذا كان المحتوى صورة أو نص، قم بتشغيل مؤقت لمدة 10 ثواني
// //       const duration = Duration(seconds: 10);

// //       _timer = Timer.periodic(Duration(milliseconds: 100), (timer) {
// //         setState(() {
// //           _progress += 00.1 / (duration.inSeconds * 1);
// //         });

// //         if (_progress >= 1.0) {
// //           _goToNextStory();
// //           timer.cancel();
// //         }
// //       });
// //     }
// //   }

// //   void _goToNextStory() {
// //     if (_currentPageIndex < widget.stories.length - 1) {
// //       _currentPageIndex++;
// //       _pageController.animateToPage(
// //         _currentPageIndex,
// //         duration: Duration(milliseconds: 300), // مدة الحركة
// //         curve: Curves.easeIn,
// //       );
// //       _initializeStory(_currentPageIndex);
// //       _startTimer(); // إعادة بدء المؤقت بعد الانتقال
// //     } else {
// //       Navigator.pop(context);
// //     }
// //   }

// //   Future<void> _deleteStory() async {
// //     try {
// //       await FirebaseFirestore.instance
// //           .collection('stories')
// //           .doc(widget.stories[_currentPageIndex].id)
// //           .delete();
// //       setState(() {
// //         widget.stories.removeAt(_currentPageIndex);
// //       });
// //       if (widget.stories.isEmpty) {
// //         Navigator.pop(context);
// //       } else {
// //         _initializeStory(_currentPageIndex);
// //       }
// //     } catch (e) {
// //       print("Error deleting story: $e");
// //     }
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       // appBar: AppBar(
// //       //   leading: Icon(Icons.arrow_back),
// //       // ),
// //       body: Stack(
// //   children: [
// //     PageView.builder(
// //       controller: _pageController,
// //       onPageChanged: (index) {
// //         setState(() {
// //           _currentPageIndex = index;
// //           _initializeStory(index);
// //           _startTimer(); // بدء المؤقت عند تغيير الصفحة
// //         });
// //       },
// //       itemCount: widget.stories.length,
// //       itemBuilder: (context, index) {
// //         var story = widget.stories[index];
// //         return GestureDetector(
// //           child: Center(
// //             child: SingleChildScrollView(
// //               child: Column(
// //                 mainAxisAlignment: MainAxisAlignment.center,
// //                 children: [
// //                   if (story['imageUrl'] != null && story['imageUrl'].isNotEmpty)
// //                     Hero(
// //                       tag: 'image-hero-${story.id}',
// //                       child: Image.network(story['imageUrl'], fit: BoxFit.cover),
// //                     )
// //                   else if (story['videoUrl'] != null && story['videoUrl'].isNotEmpty && _isVideoInitialized)
// //                     AspectRatio(
// //                       aspectRatio: _videoController!.value.aspectRatio,
// //                       child: VideoPlayer(_videoController!),
// //                     )
// //                   else
// //                     Text(
// //                       story['storyContent'] ?? '',
// //                       style: TextStyle(fontSize: 20),
// //                       textAlign: TextAlign.center,
// //                     ),
// //                 ],
// //               ),
// //             ),
// //           ),
// //         );
// //       },
// //     ),
// //     Positioned(
// //       top: 40.0,
// //       left: 10.0,
// //       child: IconButton(
// //         icon: Icon(Icons.arrow_back, color: Colors.black),
// //         onPressed: () {
// //           Navigator.pop(context); // الرجوع إلى الشاشة السابقة
// //         },
// //       ),
// //     ),
// //     Positioned(
// //       top: 40.0,
// //       right: 10.0,
// //       child: IconButton(
// //         icon: Icon(Icons.delete, color: Colors.red),
// //         onPressed: _deleteStory,
// //       ),
// //     ),
// //     Positioned(
// //       top: 90.0, // وضع الشريط تحت الأيقونات
// //       left: 0,
// //       right: 0,
// //       child: Padding(
// //         padding: const EdgeInsets.symmetric(horizontal: 10.0),
// //         child: Row(
// //           mainAxisAlignment: MainAxisAlignment.center,
// //           children: List.generate(widget.stories.length, (index) {
// //             return Container(
// //               margin: const EdgeInsets.symmetric(horizontal: 2.0),
// //               height: 5.0,
// //               width: 30.0,
// //               decoration: BoxDecoration(
// //                 color: index == _currentPageIndex ? Colors.blue : Colors.grey,
// //                 borderRadius: BorderRadius.circular(5.0),
// //               ),
// //             );
// //           }),
// //         ),
// //       ),
// //     ),
// //     Positioned(
// //       top: 110.0, // إضافة بعض الفراغ أسفل شريط الحالة
// //       left: 0,
// //       right: 0,
// //       child: Padding(
// //         padding: const EdgeInsets.symmetric(horizontal: 10.0),
// //         child: LinearProgressIndicator(
// //           value: _progress,
// //           backgroundColor: Colors.grey[300],
// //           color: Colors.blue,
// //         ),
// //       ),
// //     ),
// //   ],
// // )

// //     );
// //   }
// // }
// import 'dart:async';
// import 'package:chatapp/AuthFirebase/login_screen.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:video_player/video_player.dart';

// class UserStoriesPage extends StatefulWidget {
//   final String username;
//   final List<QueryDocumentSnapshot> stories;
//   final String currentUserId;

//   UserStoriesPage({required this.username, required this.stories, required this.currentUserId});

//   @override
//   _UserStoriesPageState createState() => _UserStoriesPageState();
// }

// class _UserStoriesPageState extends State<UserStoriesPage> {
//   late PageController _pageController;
//   VideoPlayerController? _videoController;
//   bool _isVideoInitialized = false;
//   int _currentPageIndex = 0;
//   Timer? _timer;
//   double _progress = 0.0;

//   @override
//   void initState() {
//     super.initState();
//     _pageController = PageController();
//     _initializeStory(_currentPageIndex);
//     _startTimer();
//   }

//   @override
//   void dispose() {
//     _videoController?.dispose();
//     _pageController.dispose();
//     _timer?.cancel();
//     super.dispose();
//   }

//   Future<void> _initializeStory(int index) async {
//     var story = widget.stories[index];

//     if (_videoController != null && _videoController!.value.isInitialized) {
//       await _videoController!.pause();
//       await _videoController!.dispose();
//     }

//     if (story['videoUrl'] != null && story['videoUrl'].isNotEmpty) {
//       _videoController = VideoPlayerController.network(story['videoUrl'])
//         ..initialize().then((_) {
//           setState(() {
//             _isVideoInitialized = true;
//           });
//           _videoController!.play();
//           _videoController!.addListener(() {
//             if (_videoController!.value.position ==
//                 _videoController!.value.duration) {
//               _goToNextStory();
//             }
//           });
//         });
//     } else {
//       setState(() {
//         _isVideoInitialized = false;
//       });
//     }

//     // تسجيل من شاهد الاستوري
//     await _addViewToStory(story.id);
//   }

//   Future<void> _addViewToStory(String storyId) async {
//     final userId = widget.currentUserId; // يمكنك استبداله بمعرف المستخدم الحالي
//     final storyRef = FirebaseFirestore.instance.collection('stories').doc(storyId);

//     await storyRef.update({
//       'views': FieldValue.arrayUnion([userId])
//     });
//   }

//   void _startTimer() {
//     _timer?.cancel();
//     _progress = 0.0;

//     final story = widget.stories[_currentPageIndex];

//     if (story['videoUrl'] != null && story['videoUrl'].isNotEmpty) {
//       _timer = Timer.periodic(Duration(milliseconds: 100), (timer) {
//         setState(() {
//           _progress = _videoController!.value.position.inMilliseconds /
//               _videoController!.value.duration.inMilliseconds;
//         });

//         if (_videoController!.value.position ==
//             _videoController!.value.duration) {
//           _goToNextStory();
//           timer.cancel();
//         }
//       });
//     } else {
//       const duration = Duration(seconds: 10);

//       _timer = Timer.periodic(Duration(milliseconds: 100), (timer) {
//         setState(() {
//           _progress += 0.01 / (duration.inSeconds);
//         });

//         if (_progress >= 1.0) {
//           _goToNextStory();
//           timer.cancel();
//         }
//       });
//     }
//   }

//   void _goToNextStory() {
//     if (_currentPageIndex < widget.stories.length - 1) {
//       _currentPageIndex++;
//       _pageController.animateToPage(
//         _currentPageIndex,
//         duration: Duration(milliseconds: 300),
//         curve: Curves.easeIn,
//       );
//       _initializeStory(_currentPageIndex);
//       _startTimer();
//     } else {
//       Navigator.pop(context);
//     }
//   }

//   Future<void> _deleteStory() async {
//     try {
//       await FirebaseFirestore.instance
//           .collection('stories')
//           .doc(widget.stories[_currentPageIndex].id)
//           .delete();
//       setState(() {
//         widget.stories.removeAt(_currentPageIndex);
//       });
//       if (widget.stories.isEmpty) {
//         Navigator.pop(context);
//       } else {
//         _initializeStory(_currentPageIndex);
//       }
//     } catch (e) {
//       print("Error deleting story: $e");
//     }
//   }

//   void _showViewsDialog() async {
//   final story = widget.stories[_currentPageIndex];
//   final views = story['views'] ?? []; // قائمة معرفات المشاهدين
//   List<String> userNames = [];
//   final currentUserId = "معرف_المستخدم_الحالي"; // ضع معرف المستخدم الحالي هنا

//   // جلب الأسماء بناءً على المعرفات وتجاهل المستخدم الحالي
//   for (String userId in views) {
//     if (userId != currentUserId) { // تجاهل المستخدم الحالي
//       try {
//         DocumentSnapshot userDoc = await FirebaseFirestore.instance
//             .collection('Patients') // تأكد من اسم مجموعة المستخدمين
//             .doc(userId)
//             .get();
//         if (userDoc.exists) {
//           userNames.add(userDoc['name']); // افترض أن اسم المستخدم مخزن في حقل 'name'
//         }
//       } catch (e) {
//         print("Error fetching user name for ID $userId: $e");
//         userNames.add("Unknown User"); // إضافة اسم افتراضي إذا فشل جلب الاسم
//       }
//     }
//   }

//   // عرض قائمة الأسماء في النافذة المنبثقة
//   showDialog(
//     context: context,
//     builder: (context) {
//       return AlertDialog(
//         title: Text("من شاهد الاستوري"),
//         content: SizedBox(
//           width: double.maxFinite,
//           child: ListView.builder(
//             shrinkWrap: true,
//             itemCount: userNames.length,
//             itemBuilder: (context, index) {
//               return ListTile(
//                 title: Text(userNames[index]), // عرض اسم المستخدم
//               );
//             },
//           ),
//         ),
//         actions: [
//           TextButton(
//             child: Text("إغلاق"),
//             onPressed: () {
//               Navigator.of(context).pop();
//             },
//           ),
//         ],
//       );
//     },
//   );
// }


//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Stack(
//         children: [
//           PageView.builder(
//             controller: _pageController,
//             onPageChanged: (index) {
//               setState(() {
//                 _currentPageIndex = index;
//                 _initializeStory(index);
//                 _startTimer();
//               });
//             },
//             itemCount: widget.stories.length,
//             itemBuilder: (context, index) {
//               var story = widget.stories[index];
//               return GestureDetector(
//                 child: Center(
//                   child: SingleChildScrollView(
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         if (story['imageUrl'] != null && story['imageUrl'].isNotEmpty)
//                           Hero(
//                             tag: 'image-hero-${story.id}',
//                             child: Image.network(story['imageUrl'], fit: BoxFit.cover),
//                           )
//                         else if (story['videoUrl'] != null && story['videoUrl'].isNotEmpty && _isVideoInitialized)
//                           AspectRatio(
//                             aspectRatio: _videoController!.value.aspectRatio,
//                             child: VideoPlayer(_videoController!),
//                           )
//                         else
//                           Text(
//                             story['storyContent'] ?? '',
//                             style: TextStyle(fontSize: 20),
//                             textAlign: TextAlign.center,
//                           ),
//                       ],
//                     ),
//                   ),
//                 ),
//               );
//             },
//           ),
//           Positioned(
//             top: 40.0,
//             left: 10.0,
//             child: IconButton(
//               icon: Icon(Icons.arrow_back, color: Colors.black),
//               onPressed: () {
//                 Navigator.pop(context);
//               },
//             ),
//           ),
//           Positioned(
//             top: 40.0,
//             right: 10.0,
//             child: IconButton(
//               icon: Icon(Icons.delete, color: Colors.red),
//               onPressed: _deleteStory,
//             ),
//           ),
//           Positioned(
//             top: 90.0,
//             left: 0,
//             right: 0,
//             child: Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 10.0),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: List.generate(widget.stories.length, (index) {
//                   return Container(
//                     margin: const EdgeInsets.symmetric(horizontal: 2.0),
//                     height: 5.0,
//                     width: 30.0,
//                     decoration: BoxDecoration(
//                       color: index == _currentPageIndex ? Colors.blue : Colors.grey,
//                       borderRadius: BorderRadius.circular(5.0),
//                     ),
//                   );
//                 }),
//               ),
//             ),
//           ),
//           Positioned(
//             top: 110.0,
//             left: 0,
//             right: 0,
//             child: Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 10.0),
//               child: LinearProgressIndicator(
//                 value: _progress,
//                 backgroundColor: Colors.grey[300],
//                 color: Colors.blue,
//               ),
//             ),
//           ),
//           Positioned(
//             bottom: 40.0,
//             right: 10.0,
//             child: IconButton(
//               icon: Icon(Icons.remove_red_eye, color: Colors.blue),
//               onPressed: _showViewsDialog,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class UserStoriesPage extends StatefulWidget {
  final String username;
  final List<QueryDocumentSnapshot> stories;
final String currentUserId;
  UserStoriesPage({required this.username, required this.stories, required this.currentUserId});

  @override
  _UserStoriesPageState createState() => _UserStoriesPageState();
}

class _UserStoriesPageState extends State<UserStoriesPage> {
  late PageController _pageController;
  VideoPlayerController? _videoController;
  bool _isVideoInitialized = false;
  int _currentPageIndex = 0;
  Timer? _timer;
  double _progress = 0.0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _initializeStory(_currentPageIndex);
    _startTimer(); // بدء المؤقت عند تهيئة الصفحة
  }

  @override
  void dispose() {
    _videoController?.dispose();
    _pageController.dispose();
    _timer?.cancel(); // إلغاء المؤقت عند الإغلاق
    super.dispose();
  }

  Future<void> _initializeStory(int index) async {
    var story = widget.stories[index];

    if (_videoController != null && _videoController!.value.isInitialized) {
      await _videoController!.pause();
      await _videoController!.dispose();
    }

    if (story['videoUrl'] != null && story['videoUrl'].isNotEmpty) {
      _videoController = VideoPlayerController.network(story['videoUrl'])
        ..initialize().then((_) {
          setState(() {
            _isVideoInitialized = true;
          });
          _videoController!.play();
          _videoController!.addListener(() {
            if (_videoController!.value.position ==
                _videoController!.value.duration) {
              _goToNextStory();
            }
          });
        });
    } else {
      setState(() {
        _isVideoInitialized = false;
      });
    }
        await _addViewToStory(story.id);

  }
  Future<void> _addViewToStory(String storyId) async {
    final userId = widget.currentUserId; // يمكنك استبداله بمعرف المستخدم الحالي
    final storyRef = FirebaseFirestore.instance.collection('stories').doc(storyId);

    await storyRef.update({
      'views': FieldValue.arrayUnion([userId])
    });
  }
  void _startTimer() {
    _timer?.cancel();
    _progress = 0.0;
    final story = widget.stories[_currentPageIndex];

    if (story['videoUrl'] != null && story['videoUrl'].isNotEmpty) {
      _timer = Timer.periodic(Duration(milliseconds: 100), (timer) {
        setState(() {
          _progress = _videoController!.value.position.inMilliseconds /
              _videoController!.value.duration.inMilliseconds;
        });

        if (_videoController!.value.position ==
            _videoController!.value.duration) {
          _goToNextStory();
          timer.cancel();
        }
      });
    } else {
      const duration = Duration(seconds: 10);
      _timer = Timer.periodic(Duration(milliseconds: 100), (timer) {
        setState(() {
          _progress += 0.1 / (duration.inSeconds * 1);
        });

        if (_progress >= 1.0) {
          _goToNextStory();
          timer.cancel();
        }
      });
    }
  }

  void _goToNextStory() {
    if (_currentPageIndex < widget.stories.length - 1) {
      _currentPageIndex++;
      _pageController.animateToPage(
        _currentPageIndex,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
      _initializeStory(_currentPageIndex);
      _startTimer();
    } else {
      Navigator.pop(context);
    }
  }

  Future<void> _deleteStory() async {
    try {
      await FirebaseFirestore.instance
          .collection('stories')
          .doc(widget.stories[_currentPageIndex].id)
          .delete();
      setState(() {
        widget.stories.removeAt(_currentPageIndex);
      });
      if (widget.stories.isEmpty) {
        Navigator.pop(context);
      } else {
        _initializeStory(_currentPageIndex);
      }
    } catch (e) {
      print("Error deleting story: $e");
    }
  }

  void _showViewsDialog() async {
    final story = widget.stories[_currentPageIndex];
    final views = story['views'] ?? [];
    List<String> userNames = [];
    final currentUserId = widget.currentUserId; // ضع معرف المستخدم الحالي هنا

    for (String userId in views) {
      if (userId != currentUserId) {
        try {
          DocumentSnapshot userDoc = await FirebaseFirestore.instance
              .collection('Patients') // تأكد من اسم مجموعة المستخدمين
              .doc(userId)
              .get();
          if (userDoc.exists) {
            userNames.add(userDoc['name']);
          }
        } catch (e) {
          print("Error fetching user name for ID $userId: $e");
          userNames.add("Unknown User");
        }
      }
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Viewed by ${userNames.length} "),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: userNames.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(userNames[index]),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              child: Text("Cancle"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final story = widget.stories[_currentPageIndex];
    final ownerId = story['senderid']; // افترض أن معرف صاحب الاستوري موجود هنا
    final currentUserId = widget.currentUserId; // ضع معرف المستخدم الحالي هنا

    return Scaffold(
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentPageIndex = index;
                _initializeStory(index);
                _startTimer();
              });
            },
            itemCount: widget.stories.length,
            itemBuilder: (context, index) {
              var story = widget.stories[index];
              return GestureDetector(
                child: Center(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (story['imageUrl'] != null && story['imageUrl'].isNotEmpty)
                          Hero(
                            tag: 'image-hero-${story.id}',
                            child: Image.network(story['imageUrl'], fit: BoxFit.cover),
                          )
                        else if (story['videoUrl'] != null && story['videoUrl'].isNotEmpty && _isVideoInitialized)
                          AspectRatio(
                            aspectRatio: _videoController!.value.aspectRatio,
                            child: VideoPlayer(_videoController!),
                          )
                        else
                          Text(
                            story['storyContent'] ?? '',
                            style: TextStyle(fontSize: 20),
                            textAlign: TextAlign.center,
                          ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          Positioned(
            top: 40.0,
            left: 10.0,
            child: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
          Positioned(
            top: 40.0,
            right: 10.0,
            child: IconButton(
              icon: Icon(Icons.delete, color: Colors.red),
              onPressed: _deleteStory,
            ),
          ),
          Positioned(
            top: 110.0,
            left: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: LinearProgressIndicator(
                value: _progress,
                backgroundColor: Colors.grey[300],
                color: Colors.blue,
              ),
            ),
          ),
          if (currentUserId == ownerId)
            Positioned(
  bottom: 40.0,
  left: 0,
  right: 0,
  child: Center( // استخدام Center لجعل الأيقونة في المنتصف
    child: IconButton(
      icon: Icon(Icons.remove_red_eye, color: Colors.blue),
      onPressed: _showViewsDialog,
    ),
  ),
),

        ],
      ),
    );
  }
}
