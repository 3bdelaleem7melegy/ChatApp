import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LastSeenSettingsPage extends StatefulWidget {
  final String currentUserId;

  LastSeenSettingsPage({required this.currentUserId});

  @override
  _LastSeenSettingsPageState createState() => _LastSeenSettingsPageState();
}

class _LastSeenSettingsPageState extends State<LastSeenSettingsPage> {
  bool isLastSeenVisible = true;

  @override
  void initState() {
    super.initState();
    _fetchLastSeenVisibility();
  }

  Future<void> _fetchLastSeenVisibility() async {
    DocumentSnapshot snapshot = await FirebaseFirestore.instance.collection('Patients').doc(widget.currentUserId).get();
    if (snapshot.exists) {
      setState(() {
        isLastSeenVisible = snapshot['isLastSeenVisible'] ?? true;
      });
    }
  }

  Future<void> _toggleLastSeenVisibility(bool isVisible) async {
    setState(() {
      isLastSeenVisible = isVisible;
    });
    await FirebaseFirestore.instance.collection('Patients').doc(widget.currentUserId).set({
      'isLastSeenVisible': isVisible,
    }, SetOptions(merge: true));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Last Seen Settings')),
      body: SwitchListTile(
        title: Text('Show Last Seen'),
        value: isLastSeenVisible,
        onChanged: _toggleLastSeenVisibility,
      ),
    );
  }
}
