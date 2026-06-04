import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static final SupabaseClient client = Supabase.instance.client;
  
  // Resources related
  static Future<List<Map<String, dynamic>>> getResources() async {
    final response = await client.from('resources').select('*').order('created_at', ascending: false);
    return response;
  }
  
  static Future<void> addResource(Map<String, dynamic> resource) async {
    await client.from('resources').insert(resource);
  }
  
  static Future<void> deleteResource(String id) async {
    await client.from('resources').delete().eq('id', id);
  }
  
  // Storage related
  static Future<String> uploadFile(String bucketName, String fileName, List<int> fileBytes) async {
    await client.storage.from(bucketName).uploadBinary(fileName, Uint8List.fromList(fileBytes));
    return client.storage.from(bucketName).getPublicUrl(fileName);
  }
  
  // Library related
  static Future<List<Map<String, dynamic>>> getLibraryBooks() async {
    final response = await client.from('library_books').select('*');
    return response;
  }
  
  static Future<void> addBorrowRecord(Map<String, dynamic> borrowData) async {
    await client.from('borrowed_books').insert(borrowData);
  }
}
