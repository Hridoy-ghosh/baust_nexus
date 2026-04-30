import 'package:flutter/material.dart';
import '../models/user_model.dart';

class AuthService extends ChangeNotifier {
  UserModel? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;
  
  final List<UserModel> _users = [];
  final List<UserModel> _pendingUsers = [];

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isLoggedIn => _currentUser != null;
  bool get isAdmin => _currentUser?.isAdmin ?? false;
  bool get isTeacher => _currentUser?.isTeacher ?? false;
  bool get isStudent => _currentUser?.isStudent ?? false;

  AuthService() {
    _initAdmin();
  }

  void _initAdmin() {
    if (_users.isEmpty) {
      _users.add(UserModel(
        id: 'admin_1',
        name: 'Admin',
        email: 'admin@baust.edu.bd',
        password: 'admin123',
        role: 'admin',
        adminId: 'ADMIN001',
        status: 'approved',
        createdAt: DateTime.now(),
      ));
    }
  }

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
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    await Future.delayed(const Duration(seconds: 1));
    
    final user = UserModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name, email: email, password: password,
      role: 'student', studentId: studentId,
      department: department, level: level, term: term,
      phoneNumber: phoneNumber,
      status: 'pending', // Student pending for admin approval
      createdAt: DateTime.now(),
      completedCredits: 0, totalCredits: 160, cgpa: 0.0,
    );
    _users.add(user);
    _pendingUsers.add(user);
    _isLoading = false;
    _errorMessage = 'Account created! Please wait for admin approval.';
    notifyListeners();
  }

  Future<void> signUpTeacher({
    required String name,
    required String email,
    required String password,
    required String teacherId,
    required String department,
    required String designation,
    String? phoneNumber,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    await Future.delayed(const Duration(seconds: 1));
    
    final user = UserModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name, email: email, password: password,
      role: 'teacher', teacherId: teacherId,
      department: department, designation: designation,
      phoneNumber: phoneNumber,
      status: 'pending', // Teacher pending for admin approval
      createdAt: DateTime.now(),
    );
    _users.add(user);
    _pendingUsers.add(user);
    _isLoading = false;
    _errorMessage = 'Account created! Please wait for admin approval.';
    notifyListeners();
  }

  Future<void> signIn(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 500));
    
    for (var user in _users) {
      if (user.email == email && user.password == password) {
        if (user.status != 'approved') {
          _errorMessage = 'Your account is pending admin approval.';
          _isLoading = false; notifyListeners(); return;
        }
        _currentUser = user;
        _isLoading = false; notifyListeners(); return;
      }
    }
    _errorMessage = 'Invalid email or password.';
    _isLoading = false; notifyListeners();
  }

  Future<void> signOut() async {
    _currentUser = null;
    notifyListeners();
  }

  List<UserModel> getPendingUsers() => List.from(_pendingUsers);

  void approveUser(String userId) {
    for (int i = 0; i < _users.length; i++) {
      if (_users[i].id == userId) {
        final old = _users[i];
        _users[i] = UserModel(
          id: old.id, name: old.name, email: old.email, password: old.password,
          role: old.role, status: 'approved',
          studentId: old.studentId, teacherId: old.teacherId, adminId: old.adminId,
          department: old.department, level: old.level, term: old.term,
          designation: old.designation, phoneNumber: old.phoneNumber,
          cgpa: old.cgpa, completedCredits: old.completedCredits,
          totalCredits: old.totalCredits, createdAt: old.createdAt,
          approvedAt: DateTime.now(), approvedBy: _currentUser?.id ?? 'admin_1',
        );
        _pendingUsers.removeWhere((u) => u.id == userId);
        notifyListeners(); break;
      }
    }
  }

  void rejectUser(String userId) {
    _pendingUsers.removeWhere((u) => u.id == userId);
    _users.removeWhere((u) => u.id == userId);
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}