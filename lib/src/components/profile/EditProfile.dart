import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class EditProfile extends StatefulWidget {
  static const String routeName = '/edit_profile';
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final user = FirebaseAuth.instance.currentUser;
  late File _image;
  late String _firstName;
  late String _lastName;
  late TextEditingController textEditingControllerFirstName =
      TextEditingController(text: _firstName);
  late TextEditingController textEditingControllerLastName =
      TextEditingController(text: _lastName);

  @override
  void initState() {
    super.initState();
    FirebaseFirestore.instance.collection('users').doc(user?.uid).get().then(
      (doc) {
        if (doc.exists) {
          print(doc.data());
          setState(() {
            _image = File(doc.data()?['imageUrl']);
            _firstName = doc.data()?['firstName'];
            _lastName = doc.data()?['lastName'];
          });
        }
      },
    );
  }

  final picker = ImagePicker();
  Future<void> _selectImage() async {
    final XFile? pickedFile =
        await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
      String name = 'uploads/${pickedFile.name}';
      _uploadImage(_image, name);
    } else {
      print('No image selected.');
    }
  }

  Future<void> _uploadImage(File file, String name) async {
    try {
      if (!file.existsSync()) {
        print('File does not exist at path: ${file.path}');
        return;
      }
      if (_image != File('')) {
        final storageRef = FirebaseStorage.instance.ref();

        final task = await storageRef
            .child('profilePictures/${user?.uid}.jpg')
            .putFile(_image);

        final url = await task.ref.getDownloadURL();

        await FirebaseFirestore.instance
            .collection('users')
            .doc(user?.uid)
            .update({'imageUrl': url});
      }
    } on FirebaseException catch (e) {
      print(e);
    } finally {
      Navigator.pop(context);
    }
  }

  Future<void> updateUserName(String newFirstName, String newLastName) async {
    print(newFirstName);
    print(newLastName);
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user?.uid)
          .update({
        'firstName': newFirstName,
        'lastName': newLastName,
      });
    } catch (e) {
      print(e);
    } finally {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    print(user);

    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: <Widget>[
            GestureDetector(
              onTap: _selectImage,
              child: Center(
                child: CircleAvatar(
                    backgroundColor: Colors.white,
                    radius: 50,
                    child: ClipRRect(
                        borderRadius: BorderRadius.circular(50),
                        child: Image.network(
                          _image.path,
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                        ))),
              ),
            ),
            SizedBox(height: 20),
            Center(
              child: TextField(
                controller: textEditingControllerFirstName,
                style: TextStyle(color: Colors.blue),
              ),
            ),
            SizedBox(height: 20),
            Center(
              child: TextField(
                controller: textEditingControllerLastName,
                style: TextStyle(color: Colors.blue),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _uploadImage(_image, 'uploads/${user?.uid}.jpg');
                updateUserName(textEditingControllerFirstName.text,
                    textEditingControllerLastName.text);
              },
              child: Text('Update'),
            ),
          ],
        ),
      ),
    );
  }
}
