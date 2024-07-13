import 'package:chat_app/widgets/message_bubble.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatMessages extends  StatelessWidget{
  ChatMessages({super.key});

  @override
  Widget build(BuildContext context) {
final authenticateduser=FirebaseAuth.instance.currentUser!;
    return StreamBuilder(
        stream: FirebaseFirestore.instance.collection('chat').orderBy('CreatedAt',descending: true).snapshots(),
        builder: (ctx,chatSnapshots){
          if(chatSnapshots.connectionState==ConnectionState.waiting){
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          if(!chatSnapshots.hasData||chatSnapshots.data!.docs.isEmpty){
            return const Center(child: Text("no messages found"),);
          }
          if(chatSnapshots.hasError){
            return const Center(child: Text("Something went wrong"),);
          }
          final Loadmessages=chatSnapshots.data!.docs;
          return ListView.builder(
            padding: EdgeInsets.only(bottom: 40,left: 13,right: 13),
              reverse: true,
              itemCount: Loadmessages.length,itemBuilder: (ctx,index)
         {
           final chatmessage=Loadmessages[index].data();
          final nextchatmessage=index +1 <Loadmessages.length ? Loadmessages[index + 1].data() : null;

         final currentmessageUserid=chatmessage['UserId'];
         final nextmessageUserid=nextchatmessage !=null ? nextchatmessage['UserId'] : null;
         final nextuserissame=nextmessageUserid==currentmessageUserid;

         if(nextuserissame){
           return MessageBubble.next(message:chatmessage['text'] ,isMe: authenticateduser.uid==currentmessageUserid,);
         }else
           {
             return MessageBubble.first(userImage:chatmessage['UserImage'] , username: chatmessage['Username'], message: chatmessage['text'], isMe: authenticateduser.uid==currentmessageUserid);
           }
         }



          );
        }
    );

  }
}