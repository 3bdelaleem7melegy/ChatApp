import 'package:chatapp/AuthFirebase/firebaseAuth.dart';
import 'package:chatapp/firebase_options.dart';
import 'package:chatapp/Screens/MainPage.dart';
import 'package:chatapp/Chats/HomeChat.dart';
import 'package:chatapp/AuthFirebase/login_screen.dart';
import 'package:chatapp/AuthFirebase/register_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print("Handling a background message: ${message.messageId}");
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  var initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');
  var initializationSettings =
      InitializationSettings(android: initializationSettingsAndroid);

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);
// if (Platform.isAndroid) {
//     await Firebase.initializeApp(
//       options: FirebaseOptions(
//         apiKey: "AIzaSyAdcQHKb6gcXC3zW6B_t2y_m3taounvwjI",
//         appId: "1:202575584342:android:1e5aab32306ff714106ff7",
//         messagingSenderId: "202575584342",
//         projectId: "chat-5c87a",
//       ),
//     );
//   } else {
//     await Firebase.initializeApp();
//   }
  // await FirebaseAppCheck.instance.activate();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late User user;
bool isDarkMode = false; // حالة الوضع المظلم

  MyApp({super.key});

  Future<void> _getUser() async {
    user = _auth.currentUser!;
  }

  
  @override
  Widget build(BuildContext context) {
    _getUser();

    return MaterialApp(
        theme: isDarkMode ? ThemeData.dark() : ThemeData.light(),
        debugShowCheckedModeBanner: false,
        // theme: ThemeData(brightness: Brightness.dark, fontFamily: 'Poppins'),

        initialRoute: '/',
        //
        onGenerateRoute: (settings) {
          switch (settings.name) {
            // case '/':
            //   return MaterialPageRoute(builder: (context) =>  SignIn());
            case '/':
              return MaterialPageRoute(
                  builder: (context) => FutureBuilder(
                        future: Future.value(
                            _auth.currentUser), // Wrap in Future.value
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Center(child: CircularProgressIndicator());
                          }
                          if (snapshot.hasData) {
                            // إذا كان المستخدم مسجلاً للدخول، انتقل إلى صفحة الدردشة
                            return MainPage(currentUserId: user.uid,);
                          } else {
                            // إذا لم يكن هناك مستخدم، انتقل إلى صفحة تسجيل الدخول
                            return SignIn();
                          }
                        },
                      ));
            case '/login':
              return MaterialPageRoute(
                  builder: (context) => const FireBaseAuth());
            // case '/ChatScreen':
            //   return MaterialPageRoute(builder: (context) => const ChatScreen());
            //   case '/MainPage':
            // return MaterialPageRoute(builder: (context) =>  MainPage());
            case '/UsersListPage':
              return MaterialPageRoute(
                  builder: (context) => HomeChat(
                        currentUserId: patient!.id,
                      ));
                        case '/AllChatsPage':
            

            case '/Register':
              return MaterialPageRoute(builder: (context) => const Register());
          }
          return null;
        });
  }
}
