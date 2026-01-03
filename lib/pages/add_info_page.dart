import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:test_work_app/components/my_button.dart';
import 'package:test_work_app/components/my_input.dart';
import 'package:test_work_app/pages/main_page.dart';
import 'package:test_work_app/services/RegisterService.dart';
import 'package:test_work_app/services/SupaBaseService.dart';

class AddInfoPage extends StatefulWidget {
  
  
  const AddInfoPage({super.key});

  @override
  State<AddInfoPage> createState() => _AddInfoPageState();
}

class _AddInfoPageState extends State<AddInfoPage> {
  //final String email;
  File? _imageFile;
  bool _isLoading = false;
  final ImagePicker _picker = ImagePicker();
  TextEditingController nameController = TextEditingController();
  FirebaseAuth auth = FirebaseAuth.instance;
  final SupabaseService _supabaseService = SupabaseService();
  final Registerservice _registerService = Registerservice();

  Future<void> pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _imageFile = File(image.path);
      });
    }
  }

  Future<void> addInfo() async {
    // 1. Проверяем, что изображение выбрано
    if (_imageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Выберите изображение')),
      );
      return;
    }

    // 2. Проверяем имя
    if (nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Введите имя')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // 3. Загружаем изображение С await!
      final String? imageUrl = await _supabaseService.uploadImage(
        imageFile: _imageFile!,
        bucketName: "images",
        fileNameEmail: auth.currentUser!.email, 
      );

      if (imageUrl == null) {
        throw Exception('Не удалось загрузить изображение');
      }

      // 4. Подготавливаем данные
      Map<String, dynamic> map = {
        "name": nameController.text.trim(),
        "imageUrl": imageUrl,
        "updatedAt": FieldValue.serverTimestamp(),
      };

      // 5. Сохраняем информацию в Firestore
      final result = await _registerService.addInfo(map);
      
      
      
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Добавить информацию'),
      ),
      body: Center(
        child: Container(
          height: MediaQuery.of(context).size.height / 2,
          padding: EdgeInsets.symmetric(vertical: 20),
          margin: EdgeInsets.symmetric(horizontal: 20, vertical: 50),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Material(
            borderRadius: BorderRadius.circular(15),
            elevation: 5,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: ListView(
                children: [
                  GestureDetector(
                    onTap: _isLoading ? null : pickImage,
                    child: ClipOval(
                      child: _imageFile != null
                          ? Image.file(
                              _imageFile!,
                              width: 150,
                              height: 150,
                              
                            )
                          : Container(
                              width: 150,
                              height: 150,
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.add_a_photo,
                                size: 50,
                                color: Colors.grey[600],
                              ),
                            ),
                    ),
                  ),
                  SizedBox(height: 20),
                  MyInput(
                    text: "Имя",
                    controller: nameController,
                  ),
                  SizedBox(height: 20),
                  _isLoading
                      ? Center(child: CircularProgressIndicator())
                      : MyButton(
                          color: Colors.indigoAccent,
                          text: "Сохранить",
                          onTap: () => tap(),
                        )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
  
  void tap() async {
    await addInfo();
                            Navigator.pushReplacement( // Заменяем текущую страницу
                              context,
                              MaterialPageRoute(builder: (context) => const MainApp()),
                            );
  }
}