import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:whatsup/message.dart';
import 'package:whatsup/new_message.dart';

class Chat extends StatefulWidget {
  final String receiverId;
  final String username;
  const Chat({Key? key, required this.receiverId, required this.username})
      : super(key: key);

  @override
  State<Chat> createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  get uid {
    return FirebaseAuth.instance.currentUser!.uid;
  }

  final ScrollController _controller = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.username),
      ),
      body: Stack(
        children: [
          StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection("chats")
                .orderBy('createdAt', descending: false)
                .snapshots(),
            builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
              final document = snapshot.data.docs;
              return Container(
                height: MediaQuery.of(context).size.height + 30,
                padding: const EdgeInsets.only(top: 20.0, bottom: 80),
                child: ListView.builder(
                  controller: _controller,
                  // reverse: true,
                  itemBuilder: (BuildContext context, int index) {
                    final time = DateFormat("H:mm a")
                        .format((document[index]["createdAt"]).toDate())
                        .toString();
                    if (document[index]["sender"] == uid &&
                        document[index]["receiver"] == widget.receiverId) {
                      return Message(
                        message: document[index]["text"],
                        time: time,
                        isMe: true,
                      );
                    } else if (document[index]["sender"] == widget.receiverId &&
                        document[index]["receiver"] == uid) {
                      return Message(
                        message: document[index]["text"],
                        time: time,
                        isMe: false,
                      );
                    } else {
                      return const SizedBox(height: 0);
                    }
                  },
                  itemCount: document.length,
                ),
              );
            },
          ),
          Positioned(
            bottom: 0,
            child: NewMesssage(
              receiverId: widget.receiverId,
              uid: uid,
              controller: _controller,
            ),
          )
        ],
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {
      //     FirebaseFirestore.instance.collection("users/chats/messages").add({
      //       "text": "hello homie",
      //       "createdAt": Timestamp.now(),
      //       "info": [widget.receiverId, uid],
      //       "sender": uid,
      //       "receiver": widget.receiverId,
      //     });
      //   },
      // ),
    );
  }
}
