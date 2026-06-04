import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/auth_service.dart';
import '../config/app_colors.dart';
import '../config/app_constants.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  String? _department;
  String? _level;
  String? _term;
  String? _designation;
  bool _isSaving = false;
  bool _initialized = false;

  Future<File?> _getLocalProfilePicture(String userId) async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/profile_$userId.png');
    if (await file.exists()) {
      return file;
    }
    return null;
  }

  Future<void> _pickAndSaveProfilePicture(String userId) async {
    try {
      final result = await FilePicker.platform.pickFiles(type: FileType.image);
      if (result != null && result.files.isNotEmpty) {
        final pickedFile = result.files.single;
        final bytes = pickedFile.bytes ?? await File(pickedFile.path!).readAsBytes();
        
        final dir = await getApplicationDocumentsDirectory();
        final saveFile = File('${dir.path}/profile_$userId.png');
        await saveFile.writeAsBytes(bytes);
        
        setState(() {}); // refresh local avatar
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile picture updated!'), backgroundColor: AppColors.success),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update profile picture: $e'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      final user = context.read<AuthService>().currentUser;
      if (user != null) {
        _nameController.text = user.name;
        _phoneController.text = user.phoneNumber ?? '';
        _department = user.department ?? AppConstants.departments.first['name'] as String;
        _level = user.level ?? AppConstants.levels.first['level'] as String;
        _term = user.term ?? 'Term I';
        _designation = user.designation ?? AppConstants.designations.first;
      }
      _initialized = true;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = context.read<AuthService>();
    final user = auth.currentUser;
    if (user == null) return;

    final updates = <String, dynamic>{
      'name': _nameController.text.trim(),
      'phone_number': _phoneController.text.trim(),
    };

    if (user.isStudent) {
      updates['department'] = _department;
      updates['level'] = _level;
      updates['term'] = _term;
    } else if (user.isTeacher) {
      updates['department'] = _department;
      updates['designation'] = _designation;
    }

    if (updates.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nothing to update.'), backgroundColor: AppColors.info),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    await auth.updateProfile(updates);

    setState(() {
      _isSaving = false;
    });

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile updated successfully!'), backgroundColor: AppColors.success),
    );
  }

  Widget _buildDropdownField<T>({
    required String label,
    required T? value,
    required List<T> options,
    required void Function(T?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        DropdownButtonFormField<T>(
          initialValue: value,
          items: options.map((option) => DropdownMenuItem<T>(value: option, child: Text(option.toString()))).toList(),
          onChanged: onChanged,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey.shade50,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();
    final user = auth.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text('My Profile', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
      ),
      body: user == null
          ? const Center(child: Text('No user profile available.'))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () => _pickAndSaveProfilePicture(user.id),
                          child: Stack(
                            alignment: Alignment.bottomRight,
                            children: [
                              FutureBuilder<File?>(
                                future: _getLocalProfilePicture(user.id),
                                builder: (context, snapshot) {
                                  final file = snapshot.data;
                                  if (file != null) {
                                    return CircleAvatar(
                                      radius: 32,
                                      backgroundImage: FileImage(file),
                                    );
                                  }
                                  return CircleAvatar(
                                    radius: 32,
                                    backgroundColor: AppColors.primary,
                                    child: Text(
                                      user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                                      style: GoogleFonts.poppins(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold),
                                    ),
                                  );
                                },
                              ),
                              Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: AppColors.primary,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.camera_alt, size: 12, color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(user.name, style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 4),
                              Text(user.email, style: GoogleFonts.poppins(color: Colors.grey.shade600)),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  Chip(label: Text(user.role.toUpperCase())),
                                  Chip(label: Text(user.status.toUpperCase())),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text('Account Information', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextFormField(
                          initialValue: user.email,
                          decoration: InputDecoration(
                            labelText: 'Email',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          enabled: false,
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: _nameController,
                          decoration: InputDecoration(
                            labelText: 'Full Name',
                            hintText: 'Enter your name',
                            prefixIcon: const Icon(Icons.person_outline),
                            filled: true,
                            fillColor: Colors.grey.shade50,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter your name';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          decoration: InputDecoration(
                            labelText: 'Phone Number',
                            hintText: 'Enter phone number',
                            prefixIcon: const Icon(Icons.phone_outlined),
                            filled: true,
                            fillColor: Colors.grey.shade50,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                          ),
                        ),
                        const SizedBox(height: 14),
                        if (user.isStudent) ...[
                          _buildDropdownField<String>(
                            label: 'Department',
                            value: _department,
                            options: AppConstants.departments.map((item) => item['name'] as String).toList(),
                            onChanged: (value) => setState(() => _department = value),
                          ),
                          const SizedBox(height: 14),
                          _buildDropdownField<String>(
                            label: 'Level',
                            value: _level,
                            options: AppConstants.levels.map((item) => item['level'] as String).toList(),
                            onChanged: (value) => setState(() => _level = value),
                          ),
                          const SizedBox(height: 14),
                          _buildDropdownField<String>(
                            label: 'Term',
                            value: _term,
                            options: const ['Term I', 'Term II'],
                            onChanged: (value) => setState(() => _term = value),
                          ),
                        ] else if (user.isTeacher) ...[
                          _buildDropdownField<String>(
                            label: 'Department',
                            value: _department,
                            options: AppConstants.departments.map((item) => item['name'] as String).toList(),
                            onChanged: (value) => setState(() => _department = value),
                          ),
                          const SizedBox(height: 14),
                          _buildDropdownField<String>(
                            label: 'Designation',
                            value: _designation,
                            options: AppConstants.designations,
                            onChanged: (value) => setState(() => _designation = value),
                          ),
                        ] else ...[
                          _buildDropdownField<String>(
                            label: 'Department',
                            value: _department,
                            options: AppConstants.departments.map((item) => item['name'] as String).toList(),
                            onChanged: (value) => setState(() => _department = value),
                          ),
                        ],
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: _isSaving ? null : _saveProfile,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                          child: Text(
                            _isSaving ? 'Saving...' : 'Update Profile',
                            style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
