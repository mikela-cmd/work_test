import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:test_work_app/components/my_listItem.dart';
import 'package:test_work_app/services/RegisterService.dart';

class HomePage extends StatelessWidget {
  HomePage({super.key});

  final Registerservice registerservice = Registerservice();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<QuerySnapshot>(
      future: registerservice.getAllUsers(),
      builder: (context, snapshot) {
        // Показываем индикатор загрузки
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        // Проверяем ошибки
        if (snapshot.hasError) {
          return Center(child: Text('Ошибка: ${snapshot.error}'));
        }

        // Проверяем наличие данных
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('Нет пользователей'));
        }

        // Получаем документы
        final users = snapshot.data!.docs;

        return ListView.builder(
          itemCount: users.length,
          itemBuilder: (context, index) {
            final userData = users[index].data() as Map<String, dynamic>;
            return ItemUser(
              src: userData['imageUrl'] ?? 'https://sexologists.ru/upload/iblock/01d/9fqku2wsevq4xltl70o7qluvb746xc76.jpg', // Используйте значение по умолчанию
              name: userData['name'] ?? 'No-name',
            );
          },
        );
      },
    );
  }
}