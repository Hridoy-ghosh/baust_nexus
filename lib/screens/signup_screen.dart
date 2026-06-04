import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/auth_service.dart';
import '../config/app_colors.dart';
import '../config/app_constants.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmPassCtrl = TextEditingController();
  final _idCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  
  String _role = 'student';
  String _department = 'CSE';
  String _level = 'Level 1';
  String _term = 'Term I';
  String _designation = 'Lecturer';
  bool _obscurePass = true;
  bool _obscureConfirm = true;
  int _step = 0;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmPassCtrl.dispose();
    _idCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthService>();

    if (_role == 'student') {
      await auth.signUpStudent(
        name: _nameCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
        password: _passCtrl.text,
        studentId: _idCtrl.text.trim(),
        department: _department,
        level: _level,
        term: _term,
        phoneNumber: _phoneCtrl.text.trim().isNotEmpty ? _phoneCtrl.text.trim() : null,
      );
      if (mounted) {
        final message = auth.errorMessage ?? 'Account created! Please wait for admin approval.';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: AppColors.info),
        );
        Navigator.pushReplacementNamed(context, '/login');
      }
    } else if (_role == 'teacher') {
      await auth.signUpTeacher(
        name: _nameCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
        password: _passCtrl.text,
        teacherId: _idCtrl.text.trim(),
        department: _department,
        designation: _designation,
        phoneNumber: _phoneCtrl.text.trim().isNotEmpty ? _phoneCtrl.text.trim() : null,
      );
      if (mounted) {
        final message = auth.errorMessage ?? 'Account created! Waiting for admin approval.';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: AppColors.info),
        );
        Navigator.pushReplacementNamed(context, '/login');
      }
    } else if (_role == 'admin') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Admin account request sent!'),
          backgroundColor: AppColors.info,
        ),
      );
      if (mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        title: Text('Create Account', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // Step Indicator
            Row(children: [
              _stepDot(0, 'Account'),
              Expanded(child: Container(height: 2, color: Colors.grey.shade300)),
              _stepDot(1, 'Details'),
              Expanded(child: Container(height: 2, color: Colors.grey.shade300)),
              _stepDot(2, 'Complete'),
            ]),
            const SizedBox(height: 30),
            
            if (_step == 0) ...[
              Text('Personal Information', style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              _buildTextField(_nameCtrl, 'Full Name', 'Enter your name', Icons.person, (v) => v?.isEmpty == true ? 'Required' : null),
              const SizedBox(height: 14),
              _buildTextField(_emailCtrl, 'Email', 'Enter email', Icons.email, (v) => v?.isEmpty == true ? 'Required' : null, TextInputType.emailAddress),
              const SizedBox(height: 14),
              _buildTextField(_passCtrl, 'Password', 'Min 6 characters', Icons.lock, (v) => v!.length < 6 ? 'Min 6 chars' : null, TextInputType.text, _obscurePass, IconButton(icon: Icon(_obscurePass ? Icons.visibility_off : Icons.visibility), onPressed: () => setState(() => _obscurePass = !_obscurePass))),
              const SizedBox(height: 14),
              _buildTextField(_confirmPassCtrl, 'Confirm Password', 'Re-enter password', Icons.lock_outline, (v) => v != _passCtrl.text ? 'Not match' : null, TextInputType.text, _obscureConfirm, IconButton(icon: Icon(_obscureConfirm ? Icons.visibility_off : Icons.visibility), onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm))),
              const SizedBox(height: 14),
              _buildDropdown('Role', _role, ['student', 'teacher', 'admin'], (v) => setState(() => _role = v!)),
            ] else if (_step == 1) ...[
              Text('${_role == 'student' ? 'Student' : _role == 'teacher' ? 'Teacher' : 'Admin'} Details', style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              _buildTextField(_idCtrl, _role == 'student' ? 'Student ID' : _role == 'teacher' ? 'Teacher ID' : 'Admin ID', 'Enter ID', Icons.badge, (v) => v?.isEmpty == true ? 'Required' : null),
              const SizedBox(height: 14),
              if (_role != 'admin') ...[
                _buildDropdown('Department', _department, AppConstants.departments.map((d) => d['name'].toString()).toList(), (v) => setState(() => _department = v!)),
                const SizedBox(height: 14),
              ],
              if (_role == 'student') ...[
                _buildDropdown('Level', _level, AppConstants.levels.map((l) => l['level'].toString()).toList(), (v) => setState(() => _level = v!)),
                const SizedBox(height: 14),
                _buildDropdown('Term', _term, ['Term I', 'Term II'], (v) => setState(() => _term = v!)),
              ],
              if (_role == 'teacher') ...[
                _buildDropdown('Designation', _designation, AppConstants.designations, (v) => setState(() => _designation = v!)),
              ],
              const SizedBox(height: 14),
              _buildTextField(_phoneCtrl, 'Phone (Optional)', 'Enter phone', Icons.phone, null, TextInputType.phone),
            ] else ...[
              Text('Confirm', style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              _infoCard([
                _infoRow('Name', _nameCtrl.text),
                _infoRow('Email', _emailCtrl.text),
                _infoRow('Role', _role.toUpperCase()),
                _infoRow('ID', _idCtrl.text),
                if (_role != 'admin') _infoRow('Department', _department),
                if (_role == 'student') _infoRow('Level', _level),
                if (_role == 'student') _infoRow('Term', _term),
                if (_role == 'teacher') _infoRow('Designation', _designation),
              ]),
            ],
            
            const SizedBox(height: 30),
            Row(children: [
              if (_step > 0) Expanded(child: OutlinedButton(
                onPressed: () => setState(() => _step--),
                style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                child: Text('Back', style: GoogleFonts.poppins(fontSize: 15)),
              )),
              if (_step > 0) const SizedBox(width: 12),
              Expanded(child: ElevatedButton(
                onPressed: () {
                  if (_step < 2) {
                    if (_formKey.currentState!.validate()) setState(() => _step++);
                  } else {
                    _signUp();
                  }
                },
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                child: Text(_step == 2 ? 'Create Account' : 'Next', style: GoogleFonts.poppins(fontSize: 15)),
              )),
            ]),
          ]),
        ),
      ),
    );
  }

  Widget _stepDot(int step, String label) {
    final active = _step >= step;
    return Column(children: [
      Container(width: 30, height: 30, decoration: BoxDecoration(color: active ? AppColors.primary : Colors.grey.shade300, shape: BoxShape.circle), child: Center(child: Text('${step + 1}', style: GoogleFonts.poppins(color: active ? Colors.white : Colors.grey, fontWeight: FontWeight.bold)))),
      const SizedBox(height: 4),
      Text(label, style: GoogleFonts.poppins(fontSize: 10, color: active ? AppColors.primary : Colors.grey)),
    ]);
  }

  Widget _buildTextField(
    TextEditingController ctrl,
    String label,
    String hint,
    IconData icon,
    String? Function(String?)? validator, [
    TextInputType? kb,
    bool obscure = false,
    Widget? suffix,
  ]) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600)),
      const SizedBox(height: 8),
      TextFormField(
        controller: ctrl,
        keyboardType: kb,
        obscureText: obscure,
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: Icon(icon),
          suffixIcon: suffix,
        ),
        validator: validator,
      ),
    ]);
  }

  Widget _buildDropdown(String label, String value, List<String> items, Function(String?) onChanged) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600)),
      const SizedBox(height: 8),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: value,
            isExpanded: true,
            items: items.map((i) => DropdownMenuItem(value: i, child: Text(i))).toList(),
            onChanged: onChanged,
          ),
        ),
      ),
    ]);
  }

  Widget _infoCard(List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Column(children: children),
    );
  }
  
  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(children: [
        SizedBox(width: 100, child: Text(label, style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey))),
        Expanded(child: Text(value, style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600))),
      ]),
    );
  }
}