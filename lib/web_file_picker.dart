// // web_file_picker.dart
// import 'dart:html' as html;
// import 'dart:typed_data';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'dart:async';

// Future<String?> uploadImage() async {
//   final uploadInput = html.FileUploadInputElement();
//   uploadInput.accept = 'image/*';
//   uploadInput.click();

//   final completer = Completer<String?>();

//   uploadInput.onChange.listen((event) async {
//     final files = uploadInput.files;
//     if (files!.isNotEmpty) {
//       final reader = html.FileReader();
//       reader.readAsArrayBuffer(files[0]);

//       reader.onLoadEnd.listen((e) async {
//         final bytes = reader.result as Uint8List;
//         final ref = FirebaseStorage.instance.ref('chat_images/${files[0].name}');
//         await ref.putData(bytes);
//         final downloadUrl = await ref.getDownloadURL();
//         completer.complete(downloadUrl);
//       });
//     } else {
//       completer.complete(null);
//     }
//   });

//   return completer.future;
// }
