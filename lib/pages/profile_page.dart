import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:test_work_app/components/my_button.dart';
import 'package:test_work_app/services/AuthGate.dart';
import 'package:test_work_app/services/RegisterService.dart';
import 'package:test_work_app/services/SupaBaseService.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _isRefactor = false;
  TextEditingController nameController = TextEditingController();
  File? _imageFile;
  bool _isLoading = false;
  final ImagePicker _picker = ImagePicker();
  final SupabaseService _supabaseService = SupabaseService();
  final Registerservice _registerService = Registerservice();
  FirebaseAuth auth = FirebaseAuth.instance;
  Map<String, dynamic>? _userInfo;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    try {
      final info = await _registerService.getUserInfo();
      if (info != null) {
        setState(() {
          _userInfo = info as Map<String, dynamic>;
          nameController.text = _userInfo?['name'] ?? '';
        });
      }
    } catch (e) {
      print('Ошибка загрузки данных пользователя: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return _userInfo == null
        ? const Center(child: CircularProgressIndicator())
        : (_isRefactor ? refUserInfo() : userInfo());
  }

  Widget userInfo() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Профиль'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 60,
                backgroundImage: NetworkImage(_userInfo!["imageUrl"]),
                backgroundColor: Colors.grey[300],
              ),
              const SizedBox(height: 20),
              Text(
                _userInfo!["name"],
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                auth.currentUser?.email ?? 'Нет email',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 30),
              ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    _isRefactor = true;
                  });
                },
                icon: const Icon(Icons.edit),
                label: const Text('Редактировать профиль'),
              ),
              MyButton(text: "Выйти", color: Colors.deepOrangeAccent, onTap: () async {
                Registerservice registerservice = Registerservice();
                await registerservice.logOut();
                Navigator.pushReplacement( // Заменяем текущую страницу
                              context,
                              MaterialPageRoute(builder: (context) =>  AuthGate()),
                            );
                
                
              },),
              MyButton(text: "Удалить профиль", color: Colors.red, onTap: () {
                deleteProfile();
                
              },)
            ],
          ),
        ),
      ),
    );
  }

  



  Widget refUserInfo() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Редактирование профиля'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            setState(() {
              _isRefactor = false;
            });
          },
        ),
        actions: [
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: CircularProgressIndicator(),
            )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            GestureDetector(
              onTap: pickImage,
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundImage: _imageFile != null
                        ? FileImage(_imageFile!)
                        : NetworkImage(_userInfo!["imageUrl"]) as ImageProvider,
                    backgroundColor: Colors.grey[300],
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.camera_alt,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Имя',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _isRefactor = false;
                      nameController.text = _userInfo?['name'] ?? '';
                      _imageFile = null;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[300],
                  ),
                  child: const Text('Отмена'),
                ),
                ElevatedButton(
                  onPressed: _isLoading ? null : addInfo,
                  child: const Text('Сохранить'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _imageFile = File(image.path);
      });
    }
  }

  Future<void> addInfo() async {
    if (nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Введите имя')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      String? imageUrl = _userInfo?["imageUrl"];

      // Если выбрано новое изображение, загружаем его
      if (_imageFile != null) {
        imageUrl = await _supabaseService.uploadImage(
          imageFile: _imageFile!,
          bucketName: "images",
          fileNameEmail: auth.currentUser!.email!,
        );

        if (imageUrl == null) {
          throw Exception('Не удалось загрузить изображение');
        }
      }

      // Подготавливаем данные
      Map<String, dynamic> map = {
        "name": nameController.text.trim(),
        "imageUrl": imageUrl,
        "updatedAt": FieldValue.serverTimestamp(),
      };

      // Сохраняем информацию в Firestore
      final result = await _registerService.addInfo(map);

      if (result == "ok") {
        // Обновляем локальные данные
        await _loadUserInfo();
        
        // Возвращаемся к просмотру профиля
        setState(() {
          _isRefactor = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Профиль обновлен')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка: $result')),
        );
      }
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

  Future<void> deleteProfile() async{
    
    FirebaseFirestore db = FirebaseFirestore.instance;
    SupabaseService service = SupabaseService();
    await service.deleteImageByUrl(imageUrl: _userInfo!['imageUrl'], bucketName: "images");
    await db.collection("users").doc(auth.currentUser!.uid).delete();
    await auth.currentUser!.delete();
    await auth.signOut();
     Navigator.pushReplacement( // Заменяем текущую страницу
                              context,
                              MaterialPageRoute(builder: (context) =>  AuthGate()),
                            );
  }
}