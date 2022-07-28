import 'package:flutter/material.dart';

class Posture extends StatelessWidget {
  final color;
  const Posture({Key? key, this.color}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned(
        top: 12,
        right: 40,
        left: 5,
        child: Container(
          height: 15,
          width: 30,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                  bottomRight: Radius.circular(0),
                  bottomLeft: Radius.circular(40)),
              shape: BoxShape.rectangle,
              color: color),
        ));
  }
}
