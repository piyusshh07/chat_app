import 'dart:io';

import 'package:chat_app/widgets/user_image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

final _firebase = FirebaseAuth.instance;

class Authscreen extends StatefulWidget {
  const Authscreen({super.key});

  @override
  State<StatefulWidget> createState() {
    return _AuthScreenState();
  }
}

class _AuthScreenState extends State<Authscreen> {
  final _form = GlobalKey<FormState>();
  var _islogin = false;
  var _enteredEmail = '';
  var _enteredPassword = '';
  var _enteredUsername='';
  File? selectedImage;
  var _isAuthenticating=false;

  void _submit() async {
    final _isvalid = _form.currentState!.validate();
    if (!_isvalid||!_islogin && selectedImage ==null) {
      return;
    }

    _form.currentState!.save();
    try {
      setState(() {
        _isAuthenticating=true;
      });
      if (_islogin) {
        final _usercredentials = await _firebase.signInWithEmailAndPassword(
            email: _enteredEmail, password: _enteredPassword);
      } else {
        final _usercredentials = await _firebase.createUserWithEmailAndPassword(
            email: _enteredEmail, password: _enteredPassword);
        final storageref=FirebaseStorage.instance.ref()
            .child('user_images')
            .child('${_usercredentials.user!.uid}.jpg');
        await storageref.putFile(selectedImage!);
        final imageurl=await storageref.getDownloadURL();

        await FirebaseFirestore.instance
            .collection('Users')
            .doc(_usercredentials.user!.uid)
            .set({
          'username':_enteredUsername,
          'email': _enteredEmail,
          'image_url': imageurl,

        });


      }
    } on FirebaseAuthException catch (error) {
      if (error.code == 'email-already-in-use') {
        //...
      }
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.message ?? 'Authentication failed')
          )
      );
      setState(() {
        _isAuthenticating=false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: Center(
          child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              margin: const EdgeInsets.only(
                  top: 30, bottom: 20, right: 20, left: 20),
              width: 200,
              child: Image.asset('assets/images/chat.png'),
            ),
            Card(
              margin: EdgeInsets.all(20),
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Form(
                    key: _form,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if(!_islogin) UserImagePicker(
                          onPickImage: (pickedimage){
                          selectedImage=pickedimage;
                        },),
                        TextFormField(
                          decoration: const InputDecoration(
                              label: Text("Email Address")),
                          keyboardType: TextInputType.text,
                          autocorrect: false,
                          textCapitalization: TextCapitalization.none,
                          validator: (value) {
                            if (value == null ||
                                value.trim().isEmpty ||
                                !value.contains('@')) {
                              return 'Please enter Valid email Address';
                            }
                            return null;
                          },
                          onSaved: (value) {
                            _enteredEmail = value!;
                          },
                        ),
                        if(!_islogin)
                        TextFormField(
                          decoration:InputDecoration(
                            label: Text("Username"),
                          ),
                          validator: (value){
                            if(value==null||value.isEmpty||value.trim().length<4){
                              return "username should be at least 4 characters";
                            }
                            return null;
                          },
                          onSaved: (value){
                            _enteredUsername=value!;
                          },
                        ),
                        TextFormField(
                          decoration:
                              const InputDecoration(label: Text("Password")),
                          obscureText: true,
                          validator: (value) {
                            if (value == null || value.trim().length <= 6) {
                              return 'Password must be at least 6 characters';
                            }
                            return null;
                          },
                          onSaved: (value) {
                            _enteredPassword = value!;
                          },
                        ),
                        SizedBox(height: 15),
                        if(_isAuthenticating)
                          const CircularProgressIndicator()
                        ,
                        if(!_isAuthenticating)
                        ElevatedButton(
                          onPressed: _submit,
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context)
                                  .colorScheme
                                  .primaryContainer),
                          child: Text(_islogin ? 'Login' : "Signup"),
                        ),
                        if(!_isAuthenticating)
                        TextButton(
                            onPressed: () {
                              setState(() {
                                _islogin = !_islogin;
                              });
                            },
                            child: Text(_islogin
                                ? "Create new Account"
                                : 'I already have an account')),
                      ],
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      )),
    );
  }
}
