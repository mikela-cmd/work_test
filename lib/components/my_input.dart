import 'package:flutter/material.dart';

class MyInput extends StatelessWidget {
  String text;
  TextEditingController controller;
  MyInput({super.key, required this.text, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 15),
      child: Column(
        children: [
          Container(
            child: Text(
              text,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            alignment: Alignment.centerLeft,
          ),
          TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: text,
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.black),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.blueGrey),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
