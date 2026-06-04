import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';

class AuthService extends ChangeNotifier {
  // ============ PROPERTIES ============
  UserModel? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;
  final SupabaseClient _db = Supabase.instance.client;

  // ============ GETTERS ============
  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isLoggedIn => _currentUser != null;
  bool get isAdmin => _currentUser?.isAdmin ?? false;
  bool get isTeacher => _currentUser?.isTeacher ?? false;
  bool get isStudent => _currentUser?.isStudent ?? false;
  
  // ✅ নতুন getter: নির্দিষ্ট ডিপার্টমেন্টের অ্যাডমিন চেক করার জন্য
  bool get isCafeAdmin => _currentUser?.role == 'admin' && _currentUser?.department == 'Cafe';
  bool get isLibraryAdmin => _currentUser?.role == 'admin' && _currentUser?.department == 'Library';
  bool get isGeneralAdmin => _currentUser?.role == 'admin' && 
      _currentUser?.department != 'Cafe' && 
      _currentUser?.department != 'Library';

  // ============ CONSTRUCTOR ============
  AuthService() {
    _checkExistingSession();
  }

  // ============ CHECK EXISTING SESSION ============
  void _checkExistingSession() {
    try {
      final user = _db.auth.currentUser;
      if (user != null) {
        _loadUserProfile(user.id);
      }
    } catch (e) {
      debugPrint('No existing session: $e');
    }
  }

  // ============ LOAD USER PROFILE FROM DATABASE ============
  Future<void> _loadUserProfile(String userId) async {
    try {
      final data = await _db.from('users').select().eq('id', userId).single();
      
      _currentUser = UserModel(
        id: data['id'].toString(),
        name: data['name'] ?? '',
        email: data['email'] ?? '',
        password: '',
        role: data['role'] ?? 'student',
        status: data['status'] ?? 'pending',
        studentId: data['student_id'],
        teacherId: data['teacher_id'],
        adminId: data['admin_id'],
        department: data['department'],
        level: data['level'],
        term: data['term'],
        designation: data['designation'],
        phoneNumber: data['phone_number'],
        completedCredits: data['completed_credits']?.toInt() ?? 0,
        totalCredits: data['total_credits']?.toInt() ?? 160,
        cgpa: data['cgpa']?.toDouble() ?? 0.0,
      );
      notifyListeners();
      debugPrint('✅ Profile Loaded: ${_currentUser?.name} (${_currentUser?.role}) - Dept: ${_currentUser?.department}');
    } catch (e) {
      debugPrint('Error loading profile: $e');
    }
  }

  // ============ STUDENT SIGN UP ============
  Future<void> signUpStudent({
    required String name,
    required String email,
    required String password,
    required String studentId,
    required String department,
    required String level,
    required String term,
    String? phoneNumber,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final existing = await _db.from('users').select().eq('email', email);
      if (existing.isNotEmpty) {
        _errorMessage = '❌ Email already registered!';
        _isLoading = false;
        notifyListeners();
        return;
      }

      await _db.from('users').insert({
        'name': name,
        'email': email,
        'password': password,
        'role': 'student',
        'status': 'pending',
        'student_id': studentId,
        'department': department,
        'level': level,
        'term': term,
        'phone_number': phoneNumber,
        'completed_credits': 0,
        'total_credits': 160,
        'cgpa': 0.0,
        'created_at': DateTime.now().toIso8601String(),
      });

      _isLoading = false;
      _errorMessage = '✅ Account created! Please wait for admin approval.';
      notifyListeners();
      debugPrint('✅ Student Registered: $name ($email) - Pending');
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Registration failed: ${e.toString()}';
      notifyListeners();
      debugPrint('❌ SignUp Error: $e');
    }
  }

  // ============ TEACHER SIGN UP ============
  Future<void> signUpTeacher({
    required String name,
    required String email,
    required String password,
    required String teacherId,
    required String department,
    required String designation,
    String? phoneNumber,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final existing = await _db.from('users').select().eq('email', email);
      if (existing.isNotEmpty) {
        _errorMessage = '❌ Email already registered!';
        _isLoading = false;
        notifyListeners();
        return;
      }

      await _db.from('users').insert({
        'name': name,
        'email': email,
        'password': password,
        'role': 'teacher',
        'status': 'pending',
        'teacher_id': teacherId,
        'department': department,
        'designation': designation,
        'phone_number': phoneNumber,
        'created_at': DateTime.now().toIso8601String(),
      });

      _isLoading = false;
      _errorMessage = '✅ Account created! Please wait for admin approval.';
      notifyListeners();
      debugPrint('✅ Teacher Registered: $name ($email) - Pending');
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Registration failed: ${e.toString()}';
      notifyListeners();
      debugPrint('❌ SignUp Error: $e');
    }
  }

  // ============ SIGN IN ============
  Future<void> signIn(String email, String password) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final data = await _db
          .from('users')
          .select()
          .eq('email', email)
          .eq('password', password)
          .maybeSingle();

      if (data == null) {
        final localAdmin = _localAdminFallback(email, password);
        if (localAdmin != null) {
          _currentUser = localAdmin;
          _isLoading = false;
          notifyListeners();
          debugPrint('✅ Local admin login: ${_currentUser?.email} (${_currentUser?.department})');
          return;
        }

        _errorMessage = '❌ Invalid email or password. Please try again.';
        _isLoading = false;
        notifyListeners();
        debugPrint('❌ Login Failed: Invalid credentials for $email');
        return;
      }

      if (data['status'] != 'approved') {
        _errorMessage = '⏳ Your account is pending admin approval. Please wait.';
        _isLoading = false;
        notifyListeners();
        debugPrint('❌ Login Failed: ${data['name']} - Pending Approval');
        return;
      }

      _currentUser = UserModel(
        id: data['id'].toString(),
        name: data['name'] ?? '',
        email: data['email'] ?? '',
        password: '',
        role: data['role'] ?? 'student',
        status: data['status'] ?? 'approved',
        studentId: data['student_id'],
        teacherId: data['teacher_id'],
        adminId: data['admin_id'],
        department: data['department'],
        level: data['level'],
        term: data['term'],
        designation: data['designation'],
        phoneNumber: data['phone_number'],
        completedCredits: data['completed_credits']?.toInt() ?? 0,
        totalCredits: data['total_credits']?.toInt() ?? 160,
        cgpa: data['cgpa']?.toDouble() ?? 0.0,
      );

      _isLoading = false;
      notifyListeners();
      debugPrint('✅ Login Successful: ${_currentUser?.name} (${_currentUser?.role}) - Dept: ${_currentUser?.department}');
    } catch (e) {
      _isLoading = false;
      _errorMessage = '❌ Login failed. Please try again.';
      notifyListeners();
      debugPrint('❌ SignIn Error: $e');
    }
  }

  // ============ SIGN OUT ============
  Future<void> signOut() async {
    _currentUser = null;
    notifyListeners();
    debugPrint('👋 User signed out');
  }

  // ============ GET PENDING USERS FROM DATABASE ============
  Future<List<UserModel>> getPendingUsers() async {
    try {
      final data = await _db
          .from('users')
          .select()
          .eq('status', 'pending')
          .order('created_at', ascending: false);

      return data.map<UserModel>((row) => UserModel(
        id: row['id'].toString(),
        name: row['name'] ?? '',
        email: row['email'] ?? '',
        password: '',
        role: row['role'] ?? 'student',
        status: 'pending',
        studentId: row['student_id'],
        teacherId: row['teacher_id'],
        department: row['department'],
        level: row['level'],
        term: row['term'],
        designation: row['designation'],
        phoneNumber: row['phone_number'],
        createdAt: DateTime.tryParse(row['created_at'] ?? ''),
      )).toList();
    } catch (e) {
      debugPrint('❌ Error getting pending users: $e');
      return [];
    }
  }

  // ============ APPROVE USER IN DATABASE ============
  Future<void> approveUser(String userId) async {
    try {
      await _db.from('users').update({
        'status': 'approved',
        'approved_at': DateTime.now().toIso8601String(),
        'approved_by': _currentUser?.id ?? 'system',
      }).eq('id', userId);
      notifyListeners();
      debugPrint('✅ User Approved: $userId');
    } catch (e) {
      debugPrint('❌ Approve Error: $e');
    }
  }

  // ============ REJECT USER IN DATABASE ============
  Future<void> rejectUser(String userId) async {
    try {
      await _db.from('users').delete().eq('id', userId);
      notifyListeners();
      debugPrint('❌ User Rejected: $userId');
    } catch (e) {
      debugPrint('❌ Reject Error: $e');
    }
  }

  // ============ UPDATE USER PROFILE IN DATABASE ============
  Future<void> updateProfile(Map<String, dynamic> updates) async {
    if (_currentUser != null) {
      try {
        await _db.from('users').update(updates).eq('id', _currentUser!.id);
        await _loadUserProfile(_currentUser!.id);
        debugPrint('✅ Profile Updated');
      } catch (e) {
        debugPrint('❌ Update Error: $e');
      }
    }
  }

  // ============ GET ALL USERS FROM DATABASE ============
  Future<List<UserModel>> getAllUsers() async {
    try {
      final data = await _db.from('users').select().order('created_at', ascending: false);
      return data.map<UserModel>((row) => UserModel(
        id: row['id'].toString(),
        name: row['name'] ?? '',
        email: row['email'] ?? '',
        password: '',
        role: row['role'] ?? 'student',
        status: row['status'] ?? 'pending',
        studentId: row['student_id'],
        teacherId: row['teacher_id'],
        department: row['department'],
        level: row['level'],
        term: row['term'],
        designation: row['designation'],
        phoneNumber: row['phone_number'],
      )).toList();
    } catch (e) {
      debugPrint('❌ Error getting all users: $e');
      return [];
    }
  }

  // ============ CHECK IF EMAIL EXISTS IN DATABASE ============
  Future<bool> isEmailRegistered(String email) async {
    try {
      final data = await _db.from('users').select().eq('email', email);
      return data.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  // ============ GET USER BY ID FROM DATABASE ============
  Future<UserModel?> getUserById(String userId) async {
    try {
      final data = await _db.from('users').select().eq('id', userId).maybeSingle();
      if (data == null) return null;
      
      return UserModel(
        id: data['id'].toString(),
        name: data['name'] ?? '',
        email: data['email'] ?? '',
        password: '',
        role: data['role'] ?? 'student',
        status: data['status'] ?? 'pending',
        studentId: data['student_id'],
        teacherId: data['teacher_id'],
        department: data['department'],
      );
    } catch (e) {
      return null;
    }
  }

  // ============ LOCAL ADMIN FALLBACK ============
  UserModel? _localAdminFallback(String email, String password) {
    final lookup = {
      'admin@baust.edu.bd': {'password': 'admin123', 'department': 'Administration', 'name': 'General Admin', 'role': 'admin'},
      'cafe.admin@baust.edu': {'password': 'CafeAdmin123', 'department': 'Cafe', 'name': 'Cafeteria Admin', 'role': 'admin'},
      'library.admin@baust.edu': {'password': 'LibraryAdmin123', 'department': 'Library', 'name': 'Library Admin', 'role': 'admin'},
    };

    final entry = lookup[email.toLowerCase()];
    if (entry == null || entry['password'] != password) return null;

    return UserModel(
      id: 'local-${email.toLowerCase()}',
      name: entry['name']!,
      email: email.toLowerCase(),
      role: 'admin',
      status: 'approved',
      department: entry['department'],
    );
  }

  // ============ CLEAR ERROR MESSAGE ============
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}