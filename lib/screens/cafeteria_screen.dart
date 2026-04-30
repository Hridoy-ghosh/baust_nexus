import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../config/app_colors.dart';
import '../config/app_constants.dart';

class CafeteriaScreen extends StatelessWidget {
  const CafeteriaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        title: Text('Miritika Cafeteria', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Header Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFFC62828), Color(0xFFE53935)]),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                const Text('🍽️', style: TextStyle(fontSize: 30)),
                const SizedBox(width: 10),
                Expanded(child: Text(AppConstants.cafeteriaInfo['name']!, style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white))),
              ]),
              const SizedBox(height: 10),
              _infoRow(Icons.access_time, '${AppConstants.cafeteriaInfo['openingTime']} - ${AppConstants.cafeteriaInfo['closingTime']}'),
              _infoRow(Icons.location_on, AppConstants.cafeteriaInfo['location']!),
              _infoRow(Icons.info_outline, 'Payment kore token nin! Token diye khabar nin!'),
            ]),
          ),
          
          const SizedBox(height: 20),
          
          // Daily Items
          Text('☕ Daily Available Items', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 0.85,
            ),
            itemCount: AppConstants.dailyItems.length,
            itemBuilder: (context, index) {
              final item = AppConstants.dailyItems[index];
              return Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(6),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(item['name']!, style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600), textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 2),
                      Text(item['price']!, style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary)),
                      const SizedBox(height: 4),
                      SizedBox(
                        height: 24,
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => _showToken(context, item['name']!, item['price']!),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.success,
                            padding: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                          ),
                          child: Text('Order', style: GoogleFonts.poppins(fontSize: 9, color: Colors.white)),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          
          const SizedBox(height: 20),
          
          // Weekly Menu Button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const WeeklyMenuScreen())),
              icon: const Icon(Icons.restaurant_menu),
              label: Text('📅 View Weekly Menu & Special Offers', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ),
          
          const SizedBox(height: 20),
        ]),
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 2),
    child: Row(children: [
      Icon(icon, color: Colors.white70, size: 16),
      const SizedBox(width: 8),
      Expanded(child: Text(text, style: GoogleFonts.poppins(fontSize: 12, color: Colors.white70))),
    ]),
  );

  void _showToken(BuildContext context, String item, String price) {
    final token = DateTime.now().millisecondsSinceEpoch.toString().substring(6);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(children: [Icon(Icons.check_circle, color: AppColors.success, size: 28), SizedBox(width: 10), Text('Order Confirmed!')]),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          Text('$item - $price', style: GoogleFonts.poppins(fontSize: 16)),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: AppColors.success.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
            child: Column(children: [
              Text('Your Token', style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textSecondary)),
              const SizedBox(height: 4),
              Text('🔖 TOKEN #$token', style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.success)),
              const SizedBox(height: 8),
              Text('Token diye khabar nin!', style: GoogleFonts.poppins(fontSize: 13)),
            ]),
          ),
        ]),
        actions: [
          SizedBox(width: double.infinity, child: ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text('OK'), style: ElevatedButton.styleFrom(backgroundColor: AppColors.success, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))))),
        ],
      ),
    );
  }
}

// Weekly Menu Screen
class WeeklyMenuScreen extends StatelessWidget {
  const WeeklyMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(title: Text('Weekly Menu & Offers', style: GoogleFonts.poppins(fontWeight: FontWeight.w600))),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: AppConstants.cafeteriaMenu.length,
        itemBuilder: (context, index) {
          final day = AppConstants.cafeteriaMenu[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            child: ExpansionTile(
              leading: Container(
                width: 45, height: 45,
                decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                child: Center(child: Text(day['day'].toString().substring(0, 3), style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primary))),
              ),
              title: Text(day['day'].toString(), style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600)),
              children: [
                Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(children: [
                    _mealTile('🌅 Breakfast', day['breakfast'].toString(), day['breakfastPrice'].toString(), AppColors.warning, context),
                    const Divider(),
                    _mealTile('☀️ Lunch', day['lunch'].toString(), day['lunchPrice'].toString(), AppColors.info, context),
                    const Divider(),
                    _mealTile('🍿 Snacks', day['snacks'].toString(), day['snacksPrice'].toString(), AppColors.error, context),
                    const Divider(),
                    _mealTile('⭐ Special Offer', day['special'].toString(), day['specialPrice'].toString(), AppColors.success, context),
                  ]),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _mealTile(String meal, String menu, String price, Color color, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(meal, style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.bold, color: color)),
          const SizedBox(height: 2),
          Text(menu, style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textSecondary)),
        ])),
        const SizedBox(width: 8),
        Column(children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
            child: Text(price, style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold, color: color)),
          ),
          const SizedBox(height: 6),
          SizedBox(
            height: 28,
            child: ElevatedButton(
              onPressed: () {
                final token = DateTime.now().millisecondsSinceEpoch.toString().substring(6);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('🔖 Token #$token - $price paid! Collect your food!'), backgroundColor: AppColors.success),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: color, padding: const EdgeInsets.symmetric(horizontal: 8), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6))),
              child: Text('Order', style: GoogleFonts.poppins(fontSize: 10, color: Colors.white)),
            ),
          ),
        ]),
      ]),
    );
  }
}