// ignore_for_file: file_names, library_private_types_in_public_api, unused_field, deprecated_member_use

import 'package:chatapp/User%20Details%20And%20Update/userDetails.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as path;

class UserProfile extends StatefulWidget {
  const UserProfile({super.key});

  @override
  _UserProfileState createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late User user;

  Future<void> _getUser() async {
    user = _auth.currentUser!;
  }

  Future _signOut() async {
    await _auth.signOut();
  }

  @override
  void initState() {
    super.initState();
    _getUser();
  }

  Uint8List? _image;
  File? selectedIMage;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: NotificationListener<OverscrollIndicatorNotification>(
          onNotification: (OverscrollIndicatorNotification overscroll) {
            overscroll.disallowIndicator();
            return mounted;
          },
          child: ListView(
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
                            Positioned(
                              top: 10,
                              right: 10,
                              child: IconButton(
                                icon: const Icon(
                                  Icons.gps_off,
                                  color: Colors.white,
                                  size: 20,
                                ),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const UserDetails(),
                                    ),
                                  );
                                },
                              ),
                            ),
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
                        padding: const EdgeInsets.only(top: 75),
                        child: Text(
                          user.displayName!,
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
                        StreamBuilder<DocumentSnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection('Patients')
                              .doc(user.uid)
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData || snapshot.data == null) {
                              return const CircleAvatar(
                                radius: 100,
                                backgroundImage:
                                    AssetImage("assets/person.jpg"),
                              );
                            }

                            var userData =
                                snapshot.data!.data() as Map<String, dynamic>?;

                            // Check if the data is null and whether it contains the 'profileImageUrl' key
                            String? profileImageUrl = (userData != null &&
                                    userData.containsKey('imageUrl'))
                                ? userData['imageUrl']
                                : null;

                            return GestureDetector(
                              onTap: () {
                                // عند الضغط على الصورة، عرضها كاملة في نافذة منبثقة
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    content: SizedBox(
                                      height: 400, // ارتفاع النافذة المنبثقة
                                      width: 400, // عرض النافذة المنبثقة
                                      child: Image.network(
                                        profileImageUrl ??
                                            "assets/person.jpg", // الصورة الكاملة
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                );
                              },
                              child: CircleAvatar(
                                radius: 100,
                                backgroundImage: profileImageUrl != null
                                    ? NetworkImage(profileImageUrl)
                                    : const AssetImage("assets/person.jpg")
                                        as ImageProvider,
                              ),
                            );
                          },
                        ),
                        Positioned(
                          bottom: -0,
                          left: 140,
                          child: IconButton(
                            onPressed: () {
                              showImagePickerOption(context);
                            },
                            icon: const Icon(Icons.add_a_photo),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Container(
                margin: const EdgeInsets.only(left: 15, right: 15),
                padding: const EdgeInsets.only(left: 20),
                height: MediaQuery.of(context).size.height / 7,
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
                            color: Colors.red[900],
                            child: const Icon(
                              Icons.mail_rounded,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Text(
                          user.email!,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 15,
                    ),
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
                        getphone(),

                        const SizedBox(
                          width: 10,
                        ),
                        // Text(
                        //   user.phoneNumber?.isEmpty ?? true
                        //       ? "Not Added"
                        //       : user.phoneNumber!,
                        //   style: const TextStyle(
                        //     fontSize: 16,
                        //     fontWeight: FontWeight.w600,
                        //     color: Colors.black54,
                        //   ),
                        // ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                margin: const EdgeInsets.only(left: 15, right: 15, top: 20),
                padding: const EdgeInsets.only(left: 20, top: 20),
                height: MediaQuery.of(context).size.height / 7,
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.blueGrey[50],
                ),
                child: Column(
                  children: [
                    Row(
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
                        const Text(
                          'Bio',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      child: getBio(),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget getBio() {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('Patients')
          .doc(user.uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        var userData = snapshot.data;
        return Container(
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.only(top: 10, left: 40),
          child: Text(
            userData!['bio'] == null ? "No Bio" : userData['bio'],
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.black38,
            ),
          ),
        );
      },
    );
  }

  Widget getphone() {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('Patients')
          .doc(user.uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        var userData = snapshot.data;
        return Container(
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.only(top: 10, left: 40),
          child: Text(
            userData!['phoneNumber'] == null
                ? "no phoneNumber"
                : userData['phoneNumber'],
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.black38,
            ),
          ),
        );
      },
    );
  }

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
              child: Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        _pickImageFromGallery();
                      },
                      child: const SizedBox(
                        child: Column(
                          children: [
                            Icon(
                              Icons.image,
                              size: 70,
                            ),
                            Text("Gallery")
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        _pickImageFromCamera();
                      },
                      child: const SizedBox(
                        child: Column(
                          children: [
                            Icon(
                              Icons.camera_alt,
                              size: 70,
                            ),
                            Text("Camera")
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        });
  }

// //Gallery
//   Future _pickImageFromGallery() async {
//     final returnImage =
//         await ImagePicker().pickImage(source: ImageSource.gallery);
//     if (returnImage == null) return;
//     setState(() {
//       selectedIMage = File(returnImage.path);
//       _image = File(returnImage.path).readAsBytesSync();
//     });
//     Navigator.of(context).pop(); //close the model sheet
//   }

// //Camera
//   Future _pickImageFromCamera() async {
//     final returnImage =
//         await ImagePicker().pickImage(source: ImageSource.camera);
//     if (returnImage == null) return;
//     setState(() {
//       selectedIMage = File(returnImage.path);
//       _image = File(returnImage.path).readAsBytesSync();
//     });
//     Navigator.of(context).pop();
//   }
// Upload the image to Firebase Storage
  Future<void> _uploadImageToFirebase(File image) async {
    try {
      // Generate a unique file name based on the current time and the image file name
      String fileName = path.basename(image.path);

      // Create a reference to Firebase Storage
      final storageRef =
          FirebaseStorage.instance.ref().child('profile_images/$fileName');

      // Upload the file to Firebase Storage
      UploadTask uploadTask = storageRef.putFile(image);

      // Get the download URL after the upload completes
      TaskSnapshot snapshot = await uploadTask.whenComplete(() {});
      String downloadUrl = await snapshot.ref.getDownloadURL();

      // Save the download URL to Firestore under the current user's document
      await FirebaseFirestore.instance
          .collection('Patients')
          .doc(user.uid)
          .update({
        'imageUrl': downloadUrl,
      });

      setState(() {
        _image = File(image.path).readAsBytesSync();
      });

      // Optionally, show a success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile image updated successfully')),
      );
    } catch (e) {
      // Handle any errors during the upload process
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to upload image: $e')),
      );
    }
  }

// Modified function to pick the image from the gallery
  Future<void> _pickImageFromGallery() async {
    final pickedImage =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      File imageFile = File(pickedImage.path);
      await _uploadImageToFirebase(imageFile);
    }
    Navigator.of(context).pop(); // Close the modal sheet
  }

// Modified function to pick the image from the camera
  Future<void> _pickImageFromCamera() async {
    final pickedImage =
        await ImagePicker().pickImage(source: ImageSource.camera);
    if (pickedImage != null) {
      File imageFile = File(pickedImage.path);
      await _uploadImageToFirebase(imageFile);
    }
    Navigator.of(context).pop(); // Close the modal sheet
  }
}
