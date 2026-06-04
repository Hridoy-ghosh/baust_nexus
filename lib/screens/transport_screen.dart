import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../config/app_colors.dart';
import '../config/app_constants.dart';

class TransportScreen extends StatelessWidget {
  const TransportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
          title: Text('Transport Schedule',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600))),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
                gradient: const LinearGradient(
                    colors: [Color(0xFF6A1B9A), Color(0xFF9C27B0)]),
                borderRadius: BorderRadius.circular(18)),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                const Icon(Icons.directions_bus, color: Colors.white, size: 28),
                const SizedBox(width: 10),
                Text('BAUST Transport',
                    style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white))
              ]),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.asset(
                  'assets/images/bus.jpeg',
                  height: 130,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 12),
              Text('Contact: ${AppConstants.contact1}',
                  style:
                      GoogleFonts.poppins(fontSize: 13, color: Colors.white70)),
            ]),
          ),
          const SizedBox(height: 20),

          // Bus Routes
          Text('🚌 Available Routes',
              style: GoogleFonts.poppins(
                  fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),

          // Route 1: Nilphamari
          _buildRouteCard(
            'BAUST Nilphamari Route',
            'Departure: 7:00 AM',
            'Tolly 7:10 (40 Tk) → Kalibari 7:15 (40 Tk) → Saroyan 7:20 (40 Tk) → Kazir Hat 7:25 (40 Tk) → Telapir 7:30 (20 Tk)',
            '01303-895114',
            'BAUST-01',
          ),

          // Route 2: Rangpur
          _buildRouteCard(
            'BAUST Rangpur Route',
            'Departure: 6:30 AM | Return: 2:35 PM',
            'Shapla 6:30 (70 Tk) → Jahaj Company 6:35 (70 Tk) → Payra 6:37 (70 Tk) → KPC 6:50 (70 Tk) → Modern Mor 7:00 (70 Tk) → Seo Bazar 7:05 (70 Tk) → Hasna 7:10 (70 Tk) → Hajir Hat 7:15 (60 Tk) → Paglapir 7:25 (50 Tk) → Ikrachali 7:35 (35 Tk) → Taraganj 7:45 (25 Tk)',
            '01303-895114',
            'BAUST-02, BAUST-03',
          ),

          // Route 3: Dinajpur
          _buildRouteCard(
            'BAUST Dinajpur Route',
            'Departure: 6:20 AM',
            'Suihari 6:20 (70 Tk) → Mordern Mor 6:22 (70 Tk) → Lili Mor 6:26 (70 Tk) → Medical Mor 6:28 (70 Tk) → Maharaja Mor 6:30 (70 Tk) → Dinajpur Central 6:35 (70 Tk) → College Mor 6:40 (70 Tk) → Basherhat 6:50 (60 Tk) → Dash Mile 7:00 (45 Tk) → Bhushir Bondor 7:05 (40 Tk) → Ranir Bondor 7:10 (25 Tk)',
            '01303-895114',
            'BAUST-04',
          ),

          const SizedBox(height: 20),

          // Driver Contact
          Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('📞 Contact',
                        style: GoogleFonts.poppins(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text('Md. Omar Faruk: 01303-895114, 01717-310081',
                        style: GoogleFonts.poppins(fontSize: 13)),
                    Text('Driver: 01706-811221, 01924-697387',
                        style: GoogleFonts.poppins(fontSize: 13)),
                  ]),
            ),
          ),
          const SizedBox(height: 20),
        ]),
      ),
    );
  }

  Widget _buildRouteCard(
      String route, String time, String stops, String contact, String busNo) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ExpansionTile(
        leading: Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.route, color: AppColors.primary)),
        title: Text(route,
            style:
                GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600)),
        subtitle: Text(time,
            style: GoogleFonts.poppins(
                fontSize: 11, color: AppColors.textSecondary)),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Stops & Fare:',
                  style: GoogleFonts.poppins(
                      fontSize: 13, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              Text(stops,
                  style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                      height: 1.5)),
              const SizedBox(height: 8),
              Text('Bus No: $busNo',
                  style: GoogleFonts.poppins(
                      fontSize: 12, color: AppColors.primary)),
              const SizedBox(height: 4),
              Text('Contact: $contact',
                  style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey)),
            ]),
          ),
        ],
      ),
    );
  }
}
