import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../config/app_colors.dart';
import '../services/auth_service.dart';
import 'package:provider/provider.dart';

class TodoListScreen extends StatefulWidget {
  const TodoListScreen({super.key});

  @override
  State<TodoListScreen> createState() => _TodoListScreenState();
}

class _TodoListScreenState extends State<TodoListScreen> {
  List<TodoTask> _tasks = [];
  String _selectedFilter = 'All';

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  String _selectedPriority = 'Medium';

  @override
  void initState() {
    super.initState();
    _loadSampleTasks();
  }

  void _loadSampleTasks() {
    _tasks = [
      TodoTask(
        id: '1',
        title: 'Complete Flutter Project',
        description: 'Finish the BAUST Nexus app development',
        date: DateTime.now(),
        priority: 'High',
        isCompleted: false,
      ),
      TodoTask(
        id: '2',
        title: 'Submit Assignment',
        description: 'CSE 3101 Database Project',
        date: DateTime.now().add(const Duration(days: 2)),
        priority: 'High',
        isCompleted: false,
      ),
      TodoTask(
        id: '3',
        title: 'Prepare for CT',
        description: 'Algorithm Chapter 1-5',
        date: DateTime.now().add(const Duration(days: 3)),
        priority: 'Medium',
        isCompleted: false,
      ),
      TodoTask(
        id: '4',
        title: 'Group Meeting',
        description: 'Discuss final project',
        date: DateTime.now().add(const Duration(days: 1)),
        priority: 'Medium',
        isCompleted: false,
      ),
      TodoTask(
        id: '5',
        title: 'Buy Books',
        description: 'Purchase reference books',
        date: DateTime.now().add(const Duration(days: 5)),
        priority: 'Low',
        isCompleted: false,
      ),
    ];
  }

  void _addTask() {
    if (_titleController.text.isEmpty) return;

    setState(() {
      _tasks.add(TodoTask(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: _titleController.text,
        description: _descriptionController.text,
        date: _selectedDate,
        priority: _selectedPriority,
        isCompleted: false,
      ));
      _titleController.clear();
      _descriptionController.clear();
    });
    Navigator.pop(context);
    _showSnackbar('Task added successfully', Colors.green);
  }

  void _toggleTaskCompletion(String id) {
    setState(() {
      final index = _tasks.indexWhere((t) => t.id == id);
      if (index != -1) {
        _tasks[index].isCompleted = !_tasks[index].isCompleted;
      }
    });
  }

  void _deleteTask(String id) {
    setState(() {
      _tasks.removeWhere((t) => t.id == id);
    });
    _showSnackbar('Task deleted', Colors.orange);
  }

  void _showSnackbar(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(msg),
          backgroundColor: color,
          duration: const Duration(seconds: 2)),
    );
  }

  List<TodoTask> get _filteredTasks {
    switch (_selectedFilter) {
      case 'Pending':
        return _tasks.where((t) => !t.isCompleted).toList();
      case 'Completed':
        return _tasks.where((t) => t.isCompleted).toList();
      default:
        return _tasks;
    }
  }

  int get _pendingCount => _tasks.where((t) => !t.isCompleted).length;
  int get _completedCount => _tasks.where((t) => t.isCompleted).length;

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthService>(context).currentUser;
    final isAdminOrTeacher = user?.role == 'admin' || user?.role == 'teacher';

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        title: Text('To Do List',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        backgroundColor: const Color(0xFF1A237E),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddTaskDialog(),
            tooltip: 'Add Task',
          ),
        ],
      ),
      body: Column(
        children: [
          // Summary Cards
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: _buildSummaryCard(
                    'Total',
                    _tasks.length.toString(),
                    Icons.list_alt,
                    Colors.blue,
                    () => setState(() => _selectedFilter = 'All'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildSummaryCard(
                    'Pending',
                    _pendingCount.toString(),
                    Icons.pending,
                    Colors.orange,
                    () => setState(() => _selectedFilter = 'Pending'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildSummaryCard(
                    'Done',
                    _completedCount.toString(),
                    Icons.check_circle,
                    Colors.green,
                    () => setState(() => _selectedFilter = 'Completed'),
                  ),
                ),
              ],
            ),
          ),

          // Filter Chips
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _buildFilterChip('All', _selectedFilter == 'All',
                    () => setState(() => _selectedFilter = 'All')),
                const SizedBox(width: 8),
                _buildFilterChip('Pending', _selectedFilter == 'Pending',
                    () => setState(() => _selectedFilter = 'Pending')),
                const SizedBox(width: 8),
                _buildFilterChip('Completed', _selectedFilter == 'Completed',
                    () => setState(() => _selectedFilter = 'Completed')),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Tasks List
          Expanded(
            child: _filteredTasks.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.task_alt,
                            size: 64, color: Colors.grey.shade300),
                        const SizedBox(height: 16),
                        Text(
                          _selectedFilter == 'All'
                              ? 'No tasks yet'
                              : 'No ${_selectedFilter.toLowerCase()} tasks',
                          style: GoogleFonts.poppins(
                              fontSize: 16, color: Colors.grey),
                        ),
                        if (_selectedFilter == 'All') const SizedBox(height: 8),
                        if (_selectedFilter == 'All')
                          ElevatedButton(
                            onPressed: () => _showAddTaskDialog(),
                            child: const Text('Add Your First Task'),
                          ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _filteredTasks.length,
                    itemBuilder: (context, index) {
                      final task = _filteredTasks[index];
                      return _buildTaskCard(task, isAdminOrTeacher);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(String title, String value, IconData icon,
      Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.2)),
          boxShadow: [BoxShadow(color: Colors.grey.shade100, blurRadius: 4)],
        ),
        child: Row(
          children: [
            Icon(icon, size: 24, color: color),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value,
                    style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: color)),
                Text(title,
                    style:
                        GoogleFonts.poppins(fontSize: 10, color: Colors.grey)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected, VoidCallback onTap) {
    return FilterChip(
      label: Text(label, style: GoogleFonts.poppins(fontSize: 12)),
      selected: isSelected,
      onSelected: (_) => onTap(),
      backgroundColor: Colors.grey.shade100,
      selectedColor: AppColors.primary,
      labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black87),
    );
  }

  Widget _buildTaskCard(TodoTask task, bool canEdit) {
    Color priorityColor;
    switch (task.priority) {
      case 'High':
        priorityColor = Colors.red;
        break;
      case 'Medium':
        priorityColor = Colors.orange;
        break;
      default:
        priorityColor = Colors.green;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: task.isCompleted ? Colors.grey.shade50 : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: ListTile(
        leading: Checkbox(
          value: task.isCompleted,
          onChanged: (v) => _toggleTaskCompletion(task.id),
          activeColor: Colors.green,
        ),
        title: Text(
          task.title,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            decoration: task.isCompleted ? TextDecoration.lineThrough : null,
            color: task.isCompleted ? Colors.grey : Colors.black87,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (task.description.isNotEmpty)
              Text(task.description, style: GoogleFonts.poppins(fontSize: 12)),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.calendar_today, size: 12, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  DateFormat('dd MMM yyyy').format(task.date),
                  style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: priorityColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                task.priority,
                style: TextStyle(
                    fontSize: 10,
                    color: priorityColor,
                    fontWeight: FontWeight.w500),
              ),
            ),
            if (canEdit)
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red, size: 18),
                onPressed: () => _deleteTask(task.id),
              ),
          ],
        ),
      ),
    );
  }

  void _showAddTaskDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Add New Task',
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                    labelText: 'Title *', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _descriptionController,
                maxLines: 2,
                decoration: const InputDecoration(
                    labelText: 'Description', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              ListTile(
                title: const Text('Due Date'),
                subtitle: Text(DateFormat('dd MMM yyyy').format(_selectedDate)),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (date != null) {
                    setState(() => _selectedDate = date);
                  }
                },
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: _selectedPriority,
                items: ['High', 'Medium', 'Low']
                    .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                    .toList(),
                onChanged: (v) => setState(() => _selectedPriority = v!),
                decoration: const InputDecoration(
                    labelText: 'Priority', border: OutlineInputBorder()),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(onPressed: _addTask, child: const Text('Add Task')),
        ],
      ),
    );
  }
}

class TodoTask {
  final String id;
  String title;
  String description;
  DateTime date;
  String priority;
  bool isCompleted;

  TodoTask({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.priority,
    required this.isCompleted,
  });
}
