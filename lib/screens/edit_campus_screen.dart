import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../config/app_colors.dart';

class EditCampusScreen extends StatefulWidget {
  const EditCampusScreen({super.key});
  @override
  State<EditCampusScreen> createState() => _EditCampusScreenState();
}

class _EditCampusScreenState extends State<EditCampusScreen> {
  final List<Map<String, dynamic>> _campusSettings = [
    {
      'icon': Icons.local_library,
      'title': 'Library Hours',
      'desc': 'Update opening/closing times',
      'color': AppColors.success,
      'fields': [
        {'label': 'Opening Time', 'value': '8:00 AM'},
        {'label': 'Closing Time', 'value': '5:00 PM'},
        {'label': 'Location', 'value': 'Administration Building, Ground Floor'},
      ]
    },
    {
      'icon': Icons.restaurant,
      'title': 'Cafeteria Menu',
      'desc': 'Update daily/weekly menu & prices',
      'color': AppColors.error,
      'fields': [
        {'label': 'Monday Menu', 'value': 'Porota, Dal, Egg, Tea - 45 Tk'},
        {'label': 'Tuesday Menu', 'value': 'Rice, Curry, Salad - 50 Tk'},
        {'label': 'Operating Hours', 'value': '11:00 AM - 1:30 PM'},
      ]
    },
    {
      'icon': Icons.directions_bus,
      'title': 'Bus Schedule',
      'desc': 'Update routes, timings & fares',
      'color': AppColors.info,
      'fields': [
        {'label': 'Morning Departure', 'value': '7:00 AM'},
        {'label': 'Evening Departure', 'value': '4:30 PM'},
        {'label': 'Fare per Trip', 'value': '40 Tk'},
      ]
    },
    {
      'icon': Icons.calendar_today,
      'title': 'Academic Calendar',
      'desc': 'Update semester dates & holidays',
      'color': AppColors.primary,
      'fields': [
        {'label': 'Semester Start', 'value': 'January 15, 2026'},
        {'label': 'Semester End', 'value': 'May 30, 2026'},
        {'label': 'Holidays', 'value': 'Weekends + National Holidays'},
      ]
    },
    {
      'icon': Icons.checkroom,
      'title': 'Dress Code',
      'desc': 'Modify dress code guidelines',
      'color': Colors.purple,
      'fields': [
        {'label': 'Weekday Attire', 'value': 'Formal/Semi-formal'},
        {'label': 'Weekend Attire', 'value': 'Casual'},
        {'label': 'Special Events', 'value': 'As notified by administration'},
      ]
    },
    {
      'icon': Icons.phone,
      'title': 'Contact Information',
      'desc': 'Update emergency & admin contacts',
      'color': Colors.teal,
      'fields': [
        {'label': 'Admin Office', 'value': '+880-2-1234-5678'},
        {'label': 'Emergency Hotline', 'value': '+880-2-9999-9999'},
        {'label': 'Email', 'value': 'admin@baust.edu.bd'},
      ]
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        title: Text('Campus Settings',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                  colors: [Color(0xFF1565C0), Color(0xFF1976D2)]),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  const Icon(Icons.settings, color: Colors.white, size: 28),
                  const SizedBox(width: 10),
                  Text('Manage Campus Settings',
                      style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white))
                ]),
                const SizedBox(height: 8),
                Text('Update campus facilities and information',
                    style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: Colors.white70,
                        fontWeight: FontWeight.w500)),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Settings cards
          ..._campusSettings.map((setting) => _buildSettingCard(setting)),
        ]),
      ),
    );
  }

  Widget _buildSettingCard(Map<String, dynamic> setting) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: InkWell(
        onTap: () => _showEditDialog(context, setting),
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: (setting['color'] as Color).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(setting['icon'], color: setting['color'], size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(setting['title'],
                        style: GoogleFonts.poppins(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87)),
                    const SizedBox(height: 4),
                    Text(setting['desc'],
                        style: GoogleFonts.poppins(
                            fontSize: 12, color: Colors.grey.shade600)),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios,
                  size: 16, color: Colors.grey.shade400),
            ],
          ),
        ),
      ),
    );
  }

  void _showEditDialog(BuildContext context, Map<String, dynamic> setting) {
    final controllers = (setting['fields'] as List<Map<String, String>>)
        .map((f) => TextEditingController(text: f['value']))
        .toList();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(setting['title'],
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ...List.generate(
                (setting['fields'] as List).length,
                (i) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: TextField(
                    controller: controllers[i],
                    decoration: InputDecoration(
                      labelText: (setting['fields'] as List)[i]['label'],
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // Save changes
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('✅ ${setting['title']} updated!'),
                  backgroundColor: Colors.green,
                  duration: const Duration(seconds: 2),
                ),
              );
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: setting['color'],
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Save Changes',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
