import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  final supabase = Supabase.instance.client;
  
  Future<String?> uploadImage({
    required File imageFile,
    required String bucketName,
    String? fileNameEmail
  }) async {
    try {
      // Определяем путь для сохранения
      final filePath = 'public/$fileNameEmail';
      
      // Читаем файл как байты
      final bytes = await imageFile.readAsBytes();
      
      // Загружаем в Supabase Storage - БЕЗ ПРИСВАИВАНИЯ В ПЕРЕМЕННУЮ
      await supabase.storage
          .from(bucketName)
          .uploadBinary(
            filePath,
            bytes,
            fileOptions: FileOptions(
              upsert: true,
              contentType: 'image/jpg',
            ),
          );
      
      // Получаем публичный URL
      final publicUrl = supabase.storage
          .from(bucketName)
          .getPublicUrl(filePath);
      
      return publicUrl;
      
    } on StorageException catch (e) {
      print('Ошибка загрузки: ${e.message}');
      return null;
    } catch (e) {
      print('Ошибка: $e');
      return null;
    }
  }

  Future<void> deleteImageByUrl({
  required String imageUrl,
  required String bucketName,
}) async {
  try {
    // Предполагаем, что URL имеет формат: https://.../storage/v1/object/public/bucketName/filePath
    // Ищем часть пути после bucketName/
    final bucketMarker = '/$bucketName/';
    final bucketIndex = imageUrl.indexOf(bucketMarker);
    
    if (bucketIndex == -1) {
      print('Не удалось найти bucket в URL');
     
    }
    
    // Извлекаем путь файла
    final filePath = imageUrl.substring(bucketIndex + bucketMarker.length);
    
    // Удаляем файл
    await supabase.storage
        .from(bucketName)
        .remove([filePath]);
    
    print('Файл $filePath успешно удален');
    
    
  } on StorageException catch (e) {
    print('Ошибка удаления файла по URL: ${e.message}');
    
  } catch (e) {
    print('Ошибка: $e');
    
  }
}
}