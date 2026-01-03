import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:test_work_app/pages/add_info_page.dart';
import 'package:test_work_app/pages/main_page.dart';

class AddOrHome extends StatefulWidget {
  const AddOrHome({super.key});

  @override
  State<AddOrHome> createState() => _AddOrHomeState();
}

class _AddOrHomeState extends State<AddOrHome> {
  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseFirestore db = FirebaseFirestore.instance;

  Future<DocumentSnapshot<Map<String, dynamic>>?> getUserInfo() async {
    try {
      final user = auth.currentUser;
      if (user == null || user.email == null) return null;
      
      return await db.collection("users").doc(user.email).get();
    } catch (e) {
      print('Ошибка получения данных пользователя: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>?>(
      future: getUserInfo(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        
        if (snapshot.hasError) {
          return const Scaffold(
            body: Center(child: Text('Ошибка загрузки данных')),
          );
        }
        
        // Проверяем наличие данных
        
        
        final userData = snapshot.data!.data();
        print(userData);
        
        // Проверяем, что данные не null и содержат нужные поля
        if (userData == null || 
            userData['name'] == null || 
            userData['name'].toString().isEmpty ||
            userData['imageUrl'] == null || 
            userData['imageUrl'].toString().isEmpty) {
          return AddInfoPage();
        }
        
        return const MainApp();
      },
    );
  }
}