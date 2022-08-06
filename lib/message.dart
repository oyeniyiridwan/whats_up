import 'package:flutter/material.dart';

class Message extends StatelessWidget {
  final String message;
  final bool isMe;
  final String time;
  const Message({
    Key? key,
    required this.message,
    required this.time,
    required this.isMe,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20),
      child: Row(
          mainAxisAlignment:
              isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Stack(children: [
              SizedBox(
                child: Padding(
                  padding: const EdgeInsets.only(
                      top: 8, left: 8, right: 8, bottom: 20),
                  child: Card(
                    color: isMe ? Colors.lime : Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15)),
                    child: Container(
                        constraints: const BoxConstraints(
                            maxHeight: 200,
                            maxWidth: 200,
                            minHeight: 25,
                            minWidth: 100),
                        // height: 60,
                        // width: 140,
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Text(message),
                        )),
                  ),
                ),
              ),
              Positioned(
                top: 12,
                right: isMe ? 5 : null,
                left: isMe ? null : 5,
                child: Container(
                  height: 15,
                  width: 30,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                        bottomRight: Radius.circular(isMe ? 40 : 0),
                        bottomLeft: Radius.circular(isMe ? 0 : 40)),
                    shape: BoxShape.rectangle,
                    color: isMe ? Colors.lime : Colors.white,
                  ),
                ),
              ),
              Positioned(
                bottom: isMe ? 0 : 0,
                right: isMe ? 0 : 15,
                child: Row(
                  children: [
                    Text(
                      time,
                      style: TextStyle(
                        color: isMe ? Colors.lime : Colors.white,
                      ),
                    ),
                    if (isMe)
                      Row(
                        children: const [
                          SizedBox(
                            width: 10,
                          ),
                          Icon(
                            Icons.done_all,
                            color: Colors.blue,
                          ),
                        ],
                      )
                  ],
                ),
              ),
            ]),
          ]),
    );
  }
}
