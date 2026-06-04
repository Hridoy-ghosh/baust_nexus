import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';
import '../config/app_colors.dart';

class ManageUsersScreen extends StatelessWidget {
  const ManageUsersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();

    return Scaffold(
      appBar: AppBar(
        title: Text('Manage Users',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        elevation: 0,
      ),
      body: FutureBuilder<List<UserModel>>(
        future: auth.getAllUsers(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError || snapshot.data == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 60, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text('Error loading users',
                      style: GoogleFonts.poppins(fontSize: 16)),
                ],
              ),
            );
          }

          final users = snapshot.data!;
          if (users.isEmpty) {
            return Center(
              child: Text('No users found',
                  style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey)),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundColor:
                                AppColors.primary.withValues(alpha: 0.2),
                            child: Text(
                              user.name.isNotEmpty
                                  ? user.name[0].toUpperCase()
                                  : '?',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(user.name,
                                    style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 15)),
                                Text(user.email,
                                    style: GoogleFonts.poppins(
                                        fontSize: 12, color: Colors.grey)),
                              ],
                            ),
                          ),
                          Chip(
                            label: Text(
                              user.status ?? 'unknown',
                              style: const TextStyle(fontSize: 12),
                            ),
                            backgroundColor: (user.status == 'approved')
                                ? AppColors.success.withValues(alpha: 0.2)
                                : AppColors.warning.withValues(alpha: 0.2),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Role: ${user.role} • Dept: ${user.department ?? 'N/A'}',
                        style: GoogleFonts.poppins(
                            fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
