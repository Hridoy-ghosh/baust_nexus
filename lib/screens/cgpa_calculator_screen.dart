import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../config/app_colors.dart';

class CGPACalculatorScreen extends StatefulWidget {
  const CGPACalculatorScreen({super.key});
  
  @override
  State<CGPACalculatorScreen> createState() => _CGPACalculatorScreenState();
}

class _CGPACalculatorScreenState extends State<CGPACalculatorScreen> {
  List<Map<String, dynamic>> _courses = [];
  double _cgpa = 0.0;
  int _totalCredits = 0;
  
  final List<Map<String, String>> _grades = [
    {'grade': 'A+', 'point': '4.00'},
    {'grade': 'A', 'point': '3.75'},
    {'grade': 'A-', 'point': '3.50'},
    {'grade': 'B+', 'point': '3.25'},
    {'grade': 'B', 'point': '3.00'},
    {'grade': 'B-', 'point': '2.75'},
    {'grade': 'C+', 'point': '2.50'},
    {'grade': 'C', 'point': '2.25'},
    {'grade': 'D', 'point': '2.00'},
    {'grade': 'F', 'point': '0.00'},
  ];

  void _addCourse() => setState(() => _courses.add({'name': '', 'credit': 0, 'grade': 'A+', 'point': 4.0}));
  
  void _calculate() {
    double points = 0; 
    int credits = 0;
    for (var c in _courses) {
      if ((c['credit'] as int) > 0) { 
        points += (c['point'] as double) * (c['credit'] as int); 
        credits += (c['credit'] as int); 
      }
    }
    setState(() { 
      _cgpa = credits > 0 ? points / credits : 0; 
      _totalCredits = credits; 
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        title: Text('CGPA Calculator', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: () => setState(() { _courses = []; _cgpa = 0; _totalCredits = 0; })),
          IconButton(icon: const Icon(Icons.add), onPressed: _addCourse),
        ],
      ),
      body: Column(children: [
        if (_cgpa > 0)
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: _cgpa >= 3.0 ? [AppColors.success, Colors.green.shade400] : [AppColors.warning, Colors.orange.shade400],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
              _result('CGPA', _cgpa.toStringAsFixed(2)),
              _result('Credits', _totalCredits.toString()),
              _result('Grade', _getGrade(_cgpa)),
            ]),
          ),
        Expanded(
          child: _courses.isEmpty
              ? Center(
                  child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Icon(Icons.calculate, size: 80, color: Colors.grey.shade300),
                    const SizedBox(height: 16),
                    Text('Add courses to calculate CGPA', style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey)),
                    const SizedBox(height: 8),
                    ElevatedButton(onPressed: _addCourse, child: Text('Add Course', style: GoogleFonts.poppins())),
                  ]),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: _courses.length,
                  itemBuilder: (context, i) => Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(children: [
                        Row(children: [
                          Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(
                              child: Text('${i + 1}', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold)),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              decoration: const InputDecoration(
                                labelText: 'Course Name',
                                contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                isDense: true,
                              ),
                              onChanged: (v) => _courses[i]['name'] = v,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: AppColors.error, size: 20),
                            onPressed: () => setState(() => _courses.removeAt(i)),
                          ),
                        ]),
                        const SizedBox(height: 10),
                        Row(children: [
                          Expanded(
                            flex: 1,
                            child: TextField(
                              decoration: const InputDecoration(
                                labelText: 'Credit',
                                contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                isDense: true,
                              ),
                              keyboardType: TextInputType.number,
                              onChanged: (v) => _courses[i]['credit'] = int.tryParse(v) ?? 0,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            flex: 2,
                            child: DropdownButtonFormField<String>(
                              value: _courses[i]['grade'].toString(),
                              isExpanded: true,
                              decoration: const InputDecoration(
                                labelText: 'Grade',
                                contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                isDense: true,
                              ),
                              items: _grades.map<DropdownMenuItem<String>>((g) => 
                                DropdownMenuItem<String>(
                                  value: g['grade'],
                                  child: Text('${g['grade']} (${g['point']})', style: GoogleFonts.poppins(fontSize: 12)),
                                )
                              ).toList(),
                              onChanged: (v) => setState(() {
                                _courses[i]['grade'] = v;
                                _courses[i]['point'] = double.parse(_grades.firstWhere((g) => g['grade'] == v)['point']!);
                              }),
                            ),
                          ),
                        ]),
                      ]),
                    ),
                  ),
                ),
        ),
        Container(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _courses.isNotEmpty ? _calculate : null,
              child: Text('Calculate CGPA', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600)),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ),
        ),
      ]),
    );
  }

  Widget _result(String label, String value) => Column(children: [
    Text(value, style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
    Text(label, style: GoogleFonts.poppins(fontSize: 12, color: Colors.white70)),
  ]);

  String _getGrade(double cgpa) {
    if (cgpa >= 3.75) return 'A';
    if (cgpa >= 3.50) return 'A-';
    if (cgpa >= 3.25) return 'B+';
    if (cgpa >= 3.00) return 'B';
    if (cgpa >= 2.75) return 'B-';
    if (cgpa >= 2.50) return 'C+';
    if (cgpa >= 2.25) return 'C';
    if (cgpa >= 2.00) return 'D';
    return 'F';
  }
}