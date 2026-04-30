class UserModel {
  final String id;
  final String name;
  final String email;
  final String password;
  final String role; // student, teacher, admin
  final String status; // pending, approved, rejected
  final String? studentId;
  final String? teacherId;
  final String? adminId;
  final String? department;
  final String? level;
  final String? term;
  final String? designation; // Lecturer, Asst. Professor, Professor
  final String? phoneNumber;
  final double? cgpa;
  final int? completedCredits;
  final int? totalCredits;
  final DateTime? createdAt;
  final DateTime? approvedAt;
  final String? approvedBy;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.password = '',
    required this.role,
    this.status = 'pending',
    this.studentId,
    this.teacherId,
    this.adminId,
    this.department,
    this.level,
    this.term,
    this.designation,
    this.phoneNumber,
    this.cgpa,
    this.completedCredits,
    this.totalCredits,
    this.createdAt,
    this.approvedAt,
    this.approvedBy,
  });

  bool get isApproved => status == 'approved';
  bool get isPending => status == 'pending';
  bool get isStudent => role == 'student';
  bool get isTeacher => role == 'teacher';
  bool get isAdmin => role == 'admin';
}