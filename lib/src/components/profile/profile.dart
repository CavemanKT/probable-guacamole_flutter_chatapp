import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_firebase_chat_core/flutter_firebase_chat_core.dart';
import 'package:pm/src/components/profile/EditProfile.dart';

/// Displays detailed information about a SampleItem.
class Profile extends StatefulWidget {
  const Profile({super.key});

  static const routeName = '/profile';

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  String? _currentUserFullName;
  String? _currentUserImageUrl;

  @override
  void initState() {
    super.initState();
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      fetchCurrentUserFullName(user?.uid);
    });
  }

  void fetchCurrentUserFullName(_userUid) async {
    if (_userUid != null) {
      final user = await FirebaseFirestore.instance
          .collection('users')
          .doc(_userUid)
          .get();
      if (user.exists) {
        final userData = user.data();
        if (userData != null) {
          print(userData);
          setState(() {
            _currentUserFullName =
                "${userData['firstName']} ${userData['lastName']}".trim();
            _currentUserImageUrl = userData['imageUrl'];
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('user profile'),
      ),
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            User? user = snapshot.data;
            return Center(
              child: Column(
                children: [
                  if (user != null)
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: CircleAvatar(
                        backgroundImage: NetworkImage(_currentUserImageUrl ??
                            'https://i.pravatar.cc/300'),
                        radius: 25,
                      ),
                    ),
                  if (user != null)
                    Text('Display Name: ${_currentUserFullName}'),
                  if (user != null) Text('Email: ${user.email}'),
                  if (user != null)
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, EditProfile.routeName);
                      },
                      child: const Text('Edit Profile'),
                    ),
                ],
              ),
            );
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }
}
