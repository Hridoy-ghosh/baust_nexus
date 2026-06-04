import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import '../config/app_colors.dart';

class ProgressTrackerScreen extends StatefulWidget {
  const ProgressTrackerScreen({super.key});

  @override
  State<ProgressTrackerScreen> createState() => _ProgressTrackerScreenState();
}

class _ProgressTrackerScreenState extends State<ProgressTrackerScreen> {
  List<Map<String, dynamic>> _semesters = [];
  double _overallCgpa = 0.0;
  int _totalCredits = 0;
  int _completedCredits = 0;
  
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

  void _addSemester() => setState(() => _semesters.add({'name': 'Semester ${_semesters.length + 1}', 'courses': [], 'cgpa': 0.0, 'credits': 0, 'completedCredits': 0, 'status': 'Ongoing'}));
  
  void _addCourse(int semIndex) => setState(() => _semesters[semIndex]['courses'].add({'name': '', 'credit': 0, 'grade': 'A+', 'point': 4.0, 'completed': false}));
  
  void _calculateSemester(int semIndex) {
    var sem = _semesters[semIndex];
    double points = 0; 
    int credits = 0;
    int completedCredits = 0;
    for (var c in sem['courses']) {
      if ((c['credit'] as int) > 0) { 
        points += (c['point'] as double) * (c['credit'] as int); 
        credits += (c['credit'] as int);
        if (c['completed']) completedCredits += (c['credit'] as int);
      }
    }
    setState(() { 
      sem['cgpa'] = credits > 0 ? points / credits : 0; 
      sem['credits'] = credits; 
      sem['completedCredits'] = completedCredits;
      sem['status'] = completedCredits == credits ? 'Completed' : completedCredits > 0 ? 'Ongoing' : 'Upcoming';
    });
  }
  
  void _calculateOverall() {
    double totalPoints = 0; 
    int totalCredits = 0;
    int completedCredits = 0;
    for (var sem in _semesters) {
      if ((sem['credits'] as int) > 0) {
        totalPoints += (sem['cgpa'] as double) * (sem['credits'] as int);
        totalCredits += (sem['credits'] as int);
        completedCredits += (sem['completedCredits'] as int);
      }
    }
    setState(() { 
      _overallCgpa = totalCredits > 0 ? totalPoints / totalCredits : 0; 
      _totalCredits = totalCredits; 
      _completedCredits = completedCredits;
    });
  }

  List<FlSpot> get _cgpaSpots {
    List<FlSpot> spots = [];
    for (int i = 0; i < _semesters.length; i++) {
      if (_semesters[i]['cgpa'] > 0) {
        spots.add(FlSpot(i.toDouble(), _semesters[i]['cgpa']));
      }
    }
    return spots;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        title: Text('Progress Tracker', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        backgroundColor: const Color(0xFF1A237E),
        foregroundColor: Colors.white,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: () => setState(() { _semesters = []; _overallCgpa = 0; _totalCredits = 0; _completedCredits = 0; })),
          IconButton(icon: const Icon(Icons.add), onPressed: _addSemester),
        ],
      ),
      body: Column(children: [
        if (_overallCgpa > 0)
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: _overallCgpa >= 3.0 ? [AppColors.success, Colors.green.shade400] : [AppColors.warning, Colors.orange.shade400],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
              _result('Overall CGPA', _overallCgpa.toStringAsFixed(2)),
              _result('Total Credits', _totalCredits.toString()),
              _result('Completed', '$_completedCredits/$_totalCredits'),
            ]),
          ),
        
        // CGPA Graph Chart - Fixed
        if (_cgpaSpots.isNotEmpty)
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.grey.shade200, blurRadius: 8)],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.trending_up, color: AppColors.primary, size: 20),
                    const SizedBox(width: 8),
                    Text('CGPA Trend', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16)),
                    const Spacer(),
                    Text('Semester wise CGPA', style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey)),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 220,
                  child: LineChart(
                    LineChartData(
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: true,
                        horizontalInterval: 0.5,
                        verticalInterval: 1,
                        getDrawingHorizontalLine: (value) {
                          return FlLine(
                            color: Colors.grey.shade200,
                            strokeWidth: 1,
                          );
                        },
                        getDrawingVerticalLine: (value) {
                          return FlLine(
                            color: Colors.grey.shade200,
                            strokeWidth: 1,
                          );
                        },
                      ),
                      titlesData: FlTitlesData(
                        show: true,
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 30,
                            interval: 1,
                            getTitlesWidget: (value, meta) {
                              int index = value.toInt();
                              if (index >= 0 && index < _semesters.length && _semesters[index]['cgpa'] > 0) {
                                return Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Text(
                                    _semesters[index]['name'],
                                    style: const TextStyle(fontSize: 10),
                                    textAlign: TextAlign.center,
                                  ),
                                );
                              }
                              return const Text('');
                            },
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 40,
                            interval: 0.5,
                            getTitlesWidget: (value, meta) {
                              return Text(
                                value.toStringAsFixed(1),
                                style: const TextStyle(fontSize: 11),
                              );
                            },
                          ),
                        ),
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                      ),
                      borderData: FlBorderData(
                        show: true,
                        border: Border.all(color: Colors.grey.shade300, width: 1),
                      ),
                      lineBarsData: [
                        LineChartBarData(
                          spots: _cgpaSpots,
                          isCurved: true,
                          color: AppColors.primary,
                          barWidth: 3,
                          isStrokeCapRound: true,
                          dotData: FlDotData(
                            show: true,
                            getDotPainter: (spot, percent, barData, index) {
                              return FlDotCirclePainter(
                                radius: 5,
                                color: AppColors.primary,
                                strokeWidth: 2,
                                strokeColor: Colors.white,
                              );
                            },
                          ),
                          belowBarData: BarAreaData(
                            show: true,
                            color: AppColors.primary.withOpacity(0.1),
                          ),
                        ),
                      ],
                      minY: 0,
                      maxY: 4.0,
                      lineTouchData: LineTouchData(
                        enabled: true,
                        touchTooltipData: LineTouchTooltipData(
                          getTooltipItems: (List<LineBarSpot> touchedSpots) {
                            return touchedSpots.map((spot) {
                              return LineTooltipItem(
                                'CGPA: ${spot.y.toStringAsFixed(2)}',
                                const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                              );
                            }).toList();
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        
        Expanded(
          child: _semesters.isEmpty
              ? Center(
                  child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Icon(Icons.track_changes, size: 80, color: Colors.grey.shade300),
                    const SizedBox(height: 16),
                    Text('Add semesters to track progress', style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey)),
                    const SizedBox(height: 8),
                    ElevatedButton(onPressed: _addSemester, child: Text('Add Semester', style: GoogleFonts.poppins())),
                  ]),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: _semesters.length,
                  itemBuilder: (context, semIndex) {
                    var sem = _semesters[semIndex];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Row(children: [
                            Text(sem['name'], style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: sem['status'] == 'Completed' ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(sem['status'], style: TextStyle(fontSize: 10, color: sem['status'] == 'Completed' ? Colors.green : Colors.orange, fontWeight: FontWeight.w500)),
                            ),
                            IconButton(icon: const Icon(Icons.add), onPressed: () => _addCourse(semIndex)),
                            IconButton(icon: const Icon(Icons.calculate), onPressed: () => _calculateSemester(semIndex)),
                          ]),
                          if (sem['cgpa'] > 0)
                            Container(
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                                _resultSmall('Semester CGPA', sem['cgpa'].toStringAsFixed(2)),
                                _resultSmall('Credits', '${sem['completedCredits']}/${sem['credits']}'),
                                _resultSmall('Grade', _getGrade(sem['cgpa'])),
                              ]),
                            ),
                          ...sem['courses'].map<Widget>((c) => _courseWidget(semIndex, sem['courses'].indexOf(c))).toList(),
                        ]),
                      ),
                    );
                  },
                ),
        ),
        Container(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _semesters.isNotEmpty ? _calculateOverall : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1A237E),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: Text('Calculate Overall Progress', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
            ),
          ),
        ),
      ]),
    );
  }

  Widget _courseWidget(int semIndex, int courseIndex) {
    var c = _semesters[semIndex]['courses'][courseIndex];
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(children: [
          Row(children: [
            Checkbox(value: c['completed'], onChanged: (v) => setState(() => c['completed'] = v)),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                decoration: const InputDecoration(
                  labelText: 'Course Name',
                  contentPadding: EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                  isDense: true,
                ),
                onChanged: (v) => c['name'] = v,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: AppColors.error, size: 18),
              onPressed: () => setState(() => _semesters[semIndex]['courses'].removeAt(courseIndex)),
            ),
          ]),
          const SizedBox(height: 6),
          Row(children: [
            Expanded(
              flex: 1,
              child: TextField(
                decoration: const InputDecoration(
                  labelText: 'Credit',
                  contentPadding: EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                  isDense: true,
                ),
                keyboardType: TextInputType.number,
                onChanged: (v) => c['credit'] = int.tryParse(v) ?? 0,
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              flex: 2,
              child: DropdownButtonFormField<String>(
                value: c['grade'].toString(),
                isExpanded: true,
                decoration: const InputDecoration(
                  labelText: 'Grade',
                  contentPadding: EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                  isDense: true,
                ),
                items: _grades.map<DropdownMenuItem<String>>((g) => 
                  DropdownMenuItem<String>(
                    value: g['grade'],
                    child: Text('${g['grade']} (${g['point']})', style: GoogleFonts.poppins(fontSize: 11)),
                  )
                ).toList(),
                onChanged: (v) => setState(() {
                  c['grade'] = v;
                  c['point'] = double.parse(_grades.firstWhere((g) => g['grade'] == v)['point']!);
                }),
              ),
            ),
          ]),
        ]),
      ),
    );
  }

  Widget _result(String label, String value) => Column(children: [
    Text(value, style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
    Text(label, style: GoogleFonts.poppins(fontSize: 12, color: Colors.white70)),
  ]);

  Widget _resultSmall(String label, String value) => Column(children: [
    Text(value, style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF1A237E))),
    Text(label, style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey)),
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