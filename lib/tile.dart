import 'package:flutter/material.dart';
import 'package:whatsup/chat.dart';

class Tile extends StatefulWidget {
  final String username;
  final String receiverId;
  final String imageUrl;
  const Tile(
      {Key? key,
      required this.username,
      required this.receiverId,
      required this.imageUrl})
      : super(key: key);

  @override
  State<Tile> createState() => _TileState();
}

class _TileState extends State<Tile> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: GestureDetector(
        onTap: () {
          Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => Chat(
                    receiverId: widget.receiverId,
                    username: widget.username,
                  )));
        },
        child: ListTile(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          leading: CircleAvatar(
            backgroundImage: NetworkImage(widget.imageUrl),
            radius: 25,
          ),
          title: Text(widget.username),

          // color: Colors.blueGrey,
          // child: Text(widget.message),
        ),
      ),
    );
  }
}
