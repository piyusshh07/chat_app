import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class NewMessage extends StatefulWidget{
 const  NewMessage({super.key});
  @override
  State<NewMessage> createState() {
   return _NewMessageState();
  }
}
class _NewMessageState extends State<NewMessage>{

   final _messagecontroller =TextEditingController();


   @override
  void dispose() {
     _messagecontroller.dispose();
  super.dispose();
  }

  void SubmitMessage()async{
     final enteredMessage=_messagecontroller.text;

     if(enteredMessage.trim().isEmpty){
       return;
     }

     _messagecontroller.clear();
     FocusScope.of(context).unfocus();

    final _currentuser= FirebaseAuth.instance.currentUser!;

      final  userdata=await FirebaseFirestore.instance
          .collection('Users')
          .doc(_currentuser.uid)
          .get();

FirebaseFirestore.instance.collection('chat').add({
  'text': enteredMessage,
  'CreatedAt': Timestamp.now(),
  'UserId': _currentuser.uid ,
  'Username': userdata.data()!['username'],
  'UserImage': userdata.data()!['image_url'],
});

  }

  @override
  Widget build(BuildContext context) {
    return
      Padding(
        padding: EdgeInsets.only(left: 15,right: 1,bottom: 14),
        child: Row(
          children: [
            Expanded(
                child: TextField(
                  controller: _messagecontroller,
                textCapitalization: TextCapitalization.sentences,
                  autocorrect: true,
                  enableSuggestions: true,
                  decoration: InputDecoration(
                    label: Text('Send a Message')
                  ),
            )),
            IconButton(onPressed: SubmitMessage,
              icon: Icon(Icons.send),
              color: Theme.of(context).colorScheme.primary,)
          ],
        ),
      )
      ;
  }
}