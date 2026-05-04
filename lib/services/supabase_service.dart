import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  final _supabase = Supabase.instance.client;

  // Auth
  Future<AuthResponse> signUp(String email, String password) async {
    return await _supabase.auth.signUp(email: email, password: password);
  }

  Future<AuthResponse> signIn(String email, String password) async {
    return await _supabase.auth.signInWithPassword(email: email, password: password);
  }

  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  User? get currentUser => _supabase.auth.currentUser;

  // Database (Saved Items)
  Future<void> saveItem(String type, String itemId, Map<String, dynamic> data) async {
    if (currentUser == null) throw Exception('Not logged in');
    await _supabase.from('saved_items').insert({
      'user_id': currentUser!.id,
      'item_type': type,
      'item_id': itemId,
      'item_data': data,
    });
  }

  Future<List<Map<String, dynamic>>> getSavedItems({String? type}) async {
    if (currentUser == null) throw Exception('Not logged in');
    
    var query = _supabase
        .from('saved_items')
        .select()
        .eq('user_id', currentUser!.id);
        
    if (type != null) {
      query = query.eq('item_type', type);
    }
    
    return await query.order('created_at', ascending: false);
  }

  Future<void> deleteSavedItem(String itemId) async {
    if (currentUser == null) throw Exception('Not logged in');
    await _supabase
        .from('saved_items')
        .delete()
        .match({'user_id': currentUser!.id, 'item_id': itemId});
  }
}
