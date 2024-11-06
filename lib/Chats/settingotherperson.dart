import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Settingotherperson extends StatefulWidget {
  final String currentUserId;
  final String otherUserId;
  final String otherUserName;
  final String otherUserImageUrl;
  final String otherUserPhone;
  final String otherUserBio;

  const Settingotherperson({
    required this.currentUserId,
    required this.otherUserId,
    required this.otherUserName,
    required this.otherUserImageUrl,
    required this.otherUserPhone,
    required this.otherUserBio,
  });

  @override
  State<Settingotherperson> createState() => _SettingotherpersonState();
}

class _SettingotherpersonState extends State<Settingotherperson> {
  void showImagePickerOption(BuildContext context) {
    showModalBottomSheet(
        backgroundColor: Colors.blue[100],
        context: context,
        builder: (builder) {
          return Padding(
            padding: const EdgeInsets.all(18.0),
            child: SizedBox(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height / 4.5,
            ),
          );
        });
  }

  String getChatId() {
    return widget.currentUserId.hashCode <= widget.otherUserId.hashCode
        ? '${widget.currentUserId}-${widget.otherUserId}'
        : '${widget.otherUserId}-${widget.currentUserId}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        physics: const ClampingScrollPhysics(),
        shrinkWrap: true,
        children: <Widget>[
          Stack(
            alignment: Alignment.center,
            children: <Widget>[
              Column(
                children: [
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        stops: [0.1, 0.5],
                        colors: [
                          Colors.indigo,
                          Colors.indigoAccent,
                        ],
                      ),
                    ),
                    height: MediaQuery.of(context).size.height / 5,
                    child: Stack(
                      children: [
                        // زر في أعلى اليمين

                        // زر في أعلى اليسار
                        Positioned(
                          top: 10,
                          left: 10,
                          child: IconButton(
                            icon: const Icon(
                              Icons.arrow_back,
                              color: Colors.white,
                              size: 20,
                            ),
                            onPressed: () {
                              Navigator.pop(
                                context,
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    alignment: Alignment.center,
                    height: MediaQuery.of(context).size.height / 5,
                    padding: const EdgeInsets.only(top: 100),
                    child: Text(
                      widget.otherUserName,
                      style: const TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.teal, width: 5),
                  shape: BoxShape.circle,
                ),
                child: Stack(
                  children: [
                    GestureDetector(
                      onTap: () {
                        // عند الضغط على الصورة، عرضها كاملة في نافذة منبثقة
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            content: SizedBox(
                              height: 400, // ارتفاع النافذة المنبثقة
                              width: 400, // عرض النافذة المنبثقة
                              child: StreamBuilder<DocumentSnapshot>(
                                stream: FirebaseFirestore.instance
                                    .collection('chats')
                                    .doc(getChatId())
                                    .snapshots(),
                                builder: (context, snapshot) {
                                  // عند عدم وجود بيانات أو عدم وجود محادثة
                                  if (!snapshot.hasData ||
                                      !snapshot.data!.exists) {
                                    return Image.asset("assets/person.jpg",
                                        fit: BoxFit.cover);
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
                                      ? Image.asset("assets/person.jpg",
                                          fit: BoxFit.cover)
                                      : Image.network(
                                          widget.otherUserImageUrl ??
                                              "assets/person.jpg",
                                          fit: BoxFit.cover,
                                        );
                                },
                              ),
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
                              radius: 100,
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
                                  radius: 100,
                                  backgroundColor:
                                      Colors.grey, // خلفية رمادية عند الحظر
                                  child: Icon(Icons.person,
                                      color: Colors.black,size: 80,), // أيقونة حظر
                                )
                              : CircleAvatar(
                                  radius: 100,
                                  backgroundImage: NetworkImage(
                                      widget.otherUserImageUrl ??
                                          "assets/person.jpg"),
                                  onBackgroundImageError:
                                      (exception, stackTrace) {
                                    print("Error loading image: $exception");
                                  },
                                );
                        },
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      left: 140,
                      child: GestureDetector(
                        onTap: () {
                          showImagePickerOption(context);
                        },
                        child: Container(
                          width: 60, // يمكنك تعديل العرض والارتفاع حسب الحاجة
                          height: 60,
                          color: Colors
                              .transparent, // إذا كنت تريد جعل المنطقة غير مرئية
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Container(
            margin: const EdgeInsets.only(left: 15, right: 15, top: 20),
            padding: const EdgeInsets.only(left: 20),
            height: MediaQuery.of(context).size.height / 15,
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.blueGrey[50],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(30),
                      child: Container(
                        height: 27,
                        width: 27,
                        color: Colors.blue[800],
                        child: const Icon(
                          Icons.phone,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Text(widget.otherUserPhone),
                  ],
                ),
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.only(left: 15, right: 15, top: 20),
            padding: const EdgeInsets.only(left: 20),
            height: MediaQuery.of(context).size.height / 15,
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.blueGrey[50],
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: Container(
                    height: 27,
                    width: 27,
                    color: Colors.indigo[600],
                    child: const Icon(
                      Icons.pending_sharp,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                Container(
                  child: Text(widget.otherUserBio),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
