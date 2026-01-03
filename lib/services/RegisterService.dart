import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:test_work_app/services/SupaBaseService.dart';

class Registerservice {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<String> register({required String email, required String password}) async {
    try {
      final UserCredential userCredential = await auth
          .createUserWithEmailAndPassword(email: email, password: password);
      
      // Проверка на null (хотя при успешной регистрации user не должен быть null)
      if (userCredential.user == null) {
        return "error";
      }
      
      Map<String, dynamic> map = {
        "email": email, 
        "createdAt": Timestamp.now(),
        "uid": userCredential.user!.uid, // Сохраняем UID в документе
      };
      
      await firestore
          .collection('users')
          .doc(userCredential.user!.uid) // Используем UID вместо email
          .set(map);
      
      return "ok";
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        print('The password provided is too weak.');
        return "error password";
      } else if (e.code == 'email-already-in-use') {
        return "login";
      } else {
        return "error: ${e.code}";
      }
    } catch (e) {
      print("Ошибка регистрации: $e");
      return "error";
    }
  }

  Future<String> login({required String email, required String password}) async {
    try {
      await auth.signInWithEmailAndPassword(email: email, password: password);
      return "ok";
    } on FirebaseAuthException catch (e) {
      print("Ошибка входа: ${e.code} - ${e.message}");
      
      // Можно возвращать разные коды ошибок
      if (e.code == 'user-not-found' || e.code == 'wrong-password') {
        return "invalid_credentials";
      } else if (e.code == 'too-many-requests') {
        return "too_many_attempts";
      } else {
        return "error";
      }
    } catch (e) {
      print("Неизвестная ошибка входа: $e");
      return "error";
    }
  }

  Future<String> logOut() async {
    try {
      await auth.signOut();
      return "ok";
    } catch (e) {
      print("Ошибка выхода: $e");
      return "error";
    }
  }

  Future<String> addInfo(Map<String, dynamic> map) async {
    try {
      // currentUser - синхронный метод, не требует await
      User? user = auth.currentUser;
      
      if (user == null) {
        return "user_not_authenticated";
      }
      
      // Проверяем email
      if (user.email == null || user.email!.isEmpty) {
        return "user_has_no_email";
      }
      
      // Объединяем новые данные с существующими (merge)
      final Map<String, dynamic> dataToSave = {
        ...map,
        'updatedAt': Timestamp.now(),
      };
      
      await firestore
          .collection("users")
          .doc(user.uid) // Лучше использовать UID, а не email
          .set(dataToSave, SetOptions(merge: true));
      
      return "ok";
    } on FirebaseException catch (e) {
      print("Firestore ошибка: ${e.code} - ${e.message}");
      return "firestore_error";
    } catch (e) {
      print("Ошибка addInfo: $e");
      return "error";
    }
  }
  
  // Дополнительный метод для получения информации о пользователе
  Future<Map<String, dynamic>?> getUserInfo() async {
    try {
      User? user = auth.currentUser;
      
      if (user == null) {
        return null;
      }
      
      DocumentSnapshot doc = await firestore
          .collection('users')
          .doc(user.uid)
          .get();
      
      if (doc.exists) {
        return doc.data() as Map<String, dynamic>;
      }
      
      return null;
    } catch (e) {
      print("Ошибка получения данных пользователя: $e");
      return null;
    }
  }

  Future<QuerySnapshot<Map<String, dynamic>>> getAllUsers() async {
    
    return await firestore.collection('users').get();
  }

  
}