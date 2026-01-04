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
      
      return await db.collection("users").doc(auth.currentUser!.uid).get();
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
        // Пока загрузка
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        
        // Если ошибка
        if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Text('Ошибка загрузки данных: ${snapshot.error}'),
            ),
          );
        }
        
        // Если данные null или документ не существует
        if (snapshot.data == null || !snapshot.data!.exists) {
          return const AddInfoPage();
        }
        
        // Получаем данные документа
        final userData = snapshot.data!.data();
        
        // Если данные null или отсутствуют нужные поля
        if (userData!['imageUrl'] == null || 
            userData['name'] == null) {
          return const AddInfoPage();
        }
        
        // Проверка через containsKey (альтернативный вариант)
        // if (!userData.containsKey("imageUrl") || 
        //     !userData.containsKey("name") ||
        //     userData["imageUrl"] == null || 
        //     userData["name"] == null) {
        //   return const AddInfoPage();
        // }
        
        // Все данные есть, показываем главную страницу
        return const MainApp();
      },
    );
  }
}