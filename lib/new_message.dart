import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk.dart';

class NewMesssage extends StatefulWidget {
  final String uid;
  final String receiverId;
  final ScrollController controller;
  const NewMesssage(
      {Key? key,
      required this.uid,
      required this.receiverId,
      required this.controller})
      : super(key: key);

  @override
  State<NewMesssage> createState() => _NewMesssageState();
}

class _NewMesssageState extends State<NewMesssage> {
  final TextEditingController _controller = TextEditingController();
  //String message = "";
  void _submit() async {
    if (_controller.text.trim() != "") {
      await FirebaseFirestore.instance.collection("chats").add({
        "text": _controller.text,
        "createdAt": Timestamp.now(),
        "sender": widget.uid,
        "receiver": widget.receiverId,
      });

      _controller.clear();
    }
  }

  final _firebaseMessaging = FirebaseMessaging.instance;
  void config() {
    _firebaseMessaging.getToken().then((token) {
      assert(token != null);
      updateParseInstallation(token);
    });
  }

  Future updateParseInstallation(token) async {
    var install = await ParseInstallation.currentInstallation();
    install.set("device token", token);
    var response = await install.save();
    if (response.success) {
      print(response.result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return SizedBox(
      height: 60,
      width: width,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Row(
              children: [
                SizedBox(
                  width: width - 60,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextFormField(
                      controller: _controller,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: "Message",
                      ),
                      // onFieldSubmitted: (value) {
                      //   setState(() {
                      //     message = value;
                      //   });
                      // },
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () {
                    FocusScope.of(context).unfocus();
                    widget.controller.jumpTo(
                        widget.controller.position.maxScrollExtent + 40);
                    _submit();
                  },
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
