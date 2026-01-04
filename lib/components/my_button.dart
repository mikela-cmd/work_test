// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';

class MyButton extends StatelessWidget {
  String text;
  Color color;
  final void Function()? onTap;
  MyButton({Key? key, required this.text, required this.color, this.onTap})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        
        margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Material(
          elevation: 15,
          borderRadius: BorderRadius.circular(25),
          child: Container(
            padding: EdgeInsets.all(15),
            child: Center(
              child: Text(
                text,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(30),
            ),
          ),
        ),
      ),
    );
  }
}
