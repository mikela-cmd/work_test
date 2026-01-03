// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';

class ItemUser extends StatelessWidget {
  String src;
  String name;
  ItemUser({
    Key? key,
    required this.src,
    required this.name,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: const Color.fromARGB(255, 232, 226, 204)
      ),
      padding: EdgeInsets.all(10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          ClipOval(child: Image.network(src, width: 75, height: 75,)),
          const SizedBox(width: 10,),
          Text(name)

        ],
      ),
    );
  }
}
