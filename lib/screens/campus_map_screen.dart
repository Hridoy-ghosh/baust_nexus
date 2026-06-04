import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../config/app_colors.dart';

class CampusMapScreen extends StatelessWidget {
  const CampusMapScreen({super.key});

  final List<Map<String, dynamic>> _locations = const [
    {
      'name': 'Academic Building',
      'building': 'Main Building',
      'floor': '1st - 6th Floor',
      'departments': 'CSE, EEE, ME, CE, ENG, BBA, AIS, IPE',
      'icon': Icons.school,
      'color': 0xFF1A237E,
      'image': 'assets/images/academic_building.jpeg',
    },
    {
      'name': 'Science Building',
      'building': 'Admin Block',
      'floor': 'Ground Floor Admin Block',
      'departments': 'Physics, Chemistry, Math',
      'icon': Icons.science,
      'color': 0xFF1565C0,
    },
    {
      'name': 'Library',
      'building': 'Central Library',
      'floor': 'Ground Floor Admin Block',
      'departments': 'All Departments',
      'icon': Icons.local_library,
      'color': 0xFF2E7D32,
      'image': 'assets/images/library.jpg',
    },
    {
      'name': 'Cafeteria',
      'building': 'Miritika Cafeteria',
      'floor': 'Ground Floor',
      'departments': 'Food Court',
      'icon': Icons.restaurant,
      'color': 0xFFF57C00,
      'image': 'assets/images/cafeteria.jpeg',
    },
    {'name': 'Administration', 'building': 'Admin Block', 'floor': 'Ground Floor', 'departments': 'Registrar, Accounts, Exam', 'icon': Icons.business, 'color': 0xFF6A1B9A},
    {'name': 'Hostel (Boys)', 'building': 'Ahbas Uhdin Hall', 'floor': '1st - 5th Floor', 'departments': 'Residential', 'icon': Icons.house, 'color': 0xFFC62828},
    {'name': 'Hostel (Girls)', 'building': 'Tara Mon Bibi Hall', 'floor': '1st - 4th Floor', 'departments': 'Residential', 'icon': Icons.house, 'color': 0xFFD81B60},
    {'name': 'Mosque', 'building': 'Central Mosque', 'floor': 'Ground Floor Admin Block', 'departments': 'Prayer Hall', 'icon': Icons.mosque, 'color': 0xFF00838F},
    {'name': 'Playground', 'building': 'Zikrul Huk Hall', 'floor': 'Outdoor', 'departments': 'Cricket, Football, Basketball', 'icon': Icons.sports_soccer, 'color': 0xFF558B2F},
    {'name': 'Medical Center', 'building': 'Health Care Unit', 'floor': 'Ground Floor Admin Block', 'departments': 'Clinic', 'icon': Icons.local_hospital, 'color': 0xFFE91E63},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        title: Text('Campus Map', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        backgroundColor: const Color(0xFF1A237E),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Map Image Banner
          Container(
            height: 200,
            width: double.infinity,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/campus_map.png'),
                fit: BoxFit.cover,
              ),
            ),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black.withOpacity(0.5)],
                ),
              ),
              child: Align(
                alignment: Alignment.bottomLeft,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.map, color: Colors.white, size: 28),
                      const SizedBox(height: 4),
                      Text(
                        'BAUST Campus Map',
                        style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      Text(
                        'Saidpur Cantonment, Nilphamari',
                        style: GoogleFonts.poppins(fontSize: 12, color: Colors.white70),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Building List Title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Icon(Icons.business, color: const Color(0xFF1A237E)),
                const SizedBox(width: 8),
                Text(
                  'Campus Buildings & Facilities',
                  style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF1A237E)),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 12),
          
          // Building List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _locations.length,
              itemBuilder: (context, index) {
                final location = _locations[index];
                return _buildBuildingCard(context, location);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBuildingCard(BuildContext context, Map<String, dynamic> location) {
    return GestureDetector(
      onTap: () => _showBuildingDetailsDialog(context, location),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.grey.shade100, blurRadius: 8)],
          border: Border.all(color: Colors.grey.shade100),
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Color(location['color'] as int).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(location['icon'] as IconData, color: Color(location['color'] as int), size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    location['name'] as String,
                    style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${location['building']} • ${location['floor']}',
                    style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Color(location['color'] as int).withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  const Icon(Icons.navigation, size: 12),
                  const SizedBox(width: 4),
                  Text('Navigate', style: TextStyle(fontSize: 10, color: Color(location['color'] as int))),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showBuildingDetailsDialog(BuildContext context, Map<String, dynamic> location) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(location['name'] as String, style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (location['image'] != null) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    location['image'] as String,
                    height: 140,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => const SizedBox(),
                  ),
                ),
                const SizedBox(height: 12),
              ],
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Color(location['color'] as int).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(location['icon'] as IconData, color: Color(location['color'] as int), size: 24),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Building: ${location['building']}', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                          Text('Floor: ${location['floor']}', style: GoogleFonts.poppins(fontSize: 12)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 8),
              Text('Departments / Facilities:', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 12)),
              const SizedBox(height: 4),
              Text(location['departments'] as String, style: GoogleFonts.poppins(fontSize: 11)),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.location_on, size: 14, color: Colors.red),
                  const SizedBox(width: 4),
                  Expanded(child: Text('Location: ${location['building']}, BAUST Campus', style: GoogleFonts.poppins(fontSize: 11))),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close')),
          ElevatedButton.icon(
            onPressed: () => Navigator.pop(ctx),
            icon: const Icon(Icons.directions, size: 16),
            label: const Text('Get Directions'),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1A237E)),
          ),
        ],
      ),
    );
  }
}