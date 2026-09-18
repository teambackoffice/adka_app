import 'dart:io';
import 'package:adka_app/view/field_staff/breakdown/breakdown.dart'
    show Priority, PriorityX;
import 'package:adka_app/view/field_staff/maintenence/create_maintenence.dart';
import 'package:flutter/material.dart';

// ---------- STATUS ----------
enum MaintenanceStatus { pending, inProgress, completed }

extension MaintenanceStatusX on MaintenanceStatus {
  String get label {
    switch (this) {
      case MaintenanceStatus.pending:
        return 'Pending';
      case MaintenanceStatus.inProgress:
        return 'In Progress';
      case MaintenanceStatus.completed:
        return 'Completed';
    }
  }

  Color get color {
    switch (this) {
      case MaintenanceStatus.pending:
        return const Color(0xFF757575);
      case MaintenanceStatus.inProgress:
        return const Color(0xFFF57C00);
      case MaintenanceStatus.completed:
        return const Color(0xFF2E7D32);
    }
  }

  IconData get icon {
    switch (this) {
      case MaintenanceStatus.pending:
        return Icons.schedule_rounded;
      case MaintenanceStatus.inProgress:
        return Icons.autorenew_rounded;
      case MaintenanceStatus.completed:
        return Icons.check_circle_rounded;
    }
  }

  MaintenanceStatus get next =>
      MaintenanceStatus.values[(index + 1) % MaintenanceStatus.values.length];
}

// ---------- MODEL ----------
class MaintenanceTask {
  final String assetName; // selected vehicle/machine
  final String assetNumber;
  final String taskDescription;
  final Priority priority;
  final DateTime scheduledDate;
  final File? image;
  final DateTime createdAt;
  final MaintenanceStatus status;

  MaintenanceTask({
    required this.assetName,
    required this.assetNumber,
    required this.taskDescription,
    required this.scheduledDate,
    this.priority = Priority.medium,
    this.image,
    this.status = MaintenanceStatus.pending,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  MaintenanceTask copyWith({
    String? assetName,
    String? assetNumber,
    String? taskDescription,
    Priority? priority,
    DateTime? scheduledDate,
    File? image,
    MaintenanceStatus? status,
  }) {
    return MaintenanceTask(
      assetName: assetName ?? this.assetName,
      assetNumber: assetNumber ?? this.assetNumber,
      taskDescription: taskDescription ?? this.taskDescription,
      priority: priority ?? this.priority,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      image: image ?? this.image,
      status: status ?? this.status,
      createdAt: createdAt,
    );
  }
}

// ---------- MAINTENANCE LIST PAGE ----------
class FieldStaffMaintenencePage extends StatefulWidget {
  const FieldStaffMaintenencePage({super.key});

  @override
  State<FieldStaffMaintenencePage> createState() =>
      _FieldStaffMaintenencePageState();
}

class _FieldStaffMaintenencePageState extends State<FieldStaffMaintenencePage> {
  final List<MaintenanceTask> _tasks = [];

  static const Color _accent = Color(0xFF0469B1); // brand blue accent
  static const Color _bg = Color(0xFFF6F7FB);

  Future<void> _goToAddPage() async {
    final result = await Navigator.push<MaintenanceTask>(
      context,
      MaterialPageRoute(builder: (context) => const AddMaintenanceTaskPage()),
    );

    if (result != null) {
      setState(() {
        _tasks.insert(0, result);
        _tasks.sort((a, b) => a.scheduledDate.compareTo(b.scheduledDate));
      });
    }
  }

  // Temporary local toggle — replace with an API call when the backend is ready.
  void _cycleStatus(int index) {
    setState(() {
      final task = _tasks[index];
      _tasks[index] = task.copyWith(status: task.status.next);
    });
  }

  void _removeTask(int index) {
    final removed = _tasks[index];
    setState(() => _tasks.removeAt(index));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.black87,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        content: Text('${removed.assetName} removed'),
        action: SnackBarAction(
          label: 'UNDO',
          textColor: Colors.orangeAccent,
          onPressed: () {
            setState(() => _tasks.insert(index, removed));
          },
        ),
      ),
    );
  }

  String _dateLabel(DateTime dt) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(dt.year, dt.month, dt.day);
    final diff = target.difference(today).inDays;

    if (diff == 0) return 'Due today';
    if (diff == 1) return 'Due tomorrow';
    if (diff < 0) return 'Overdue • ${dt.day}/${dt.month}';
    return 'Due ${dt.day}/${dt.month}';
  }

  bool _isOverdue(DateTime dt) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return DateTime(dt.year, dt.month, dt.day).isBefore(today);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        title: const Text(
          'Maintenance',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 20,
            color: Colors.black87,
          ),
        ),
        actions: [
          if (_tasks.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: _accent.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${_tasks.length} scheduled',
                    style: const TextStyle(
                      color: _accent,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: _tasks.isEmpty
            ? _buildEmptyState()
            : RefreshIndicator(
                onRefresh: () async => setState(() {}),
                child: ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
                  itemCount: _tasks.length,
                  itemBuilder: (context, index) {
                    final task = _tasks[index];
                    return _MaintenanceCard(
                      task: task,
                      dateLabel: _dateLabel(task.scheduledDate),
                      isOverdue: _isOverdue(task.scheduledDate),
                      accent: _accent,
                      onDismissed: () => _removeTask(index),
                      onStatusTap: () => _cycleStatus(index),
                    );
                  },
                ),
              ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 100),
        child: FloatingActionButton.extended(
          onPressed: _goToAddPage,
          backgroundColor: _accent,
          foregroundColor: Colors.white,
          elevation: 4,
          icon: const Icon(Icons.add_rounded),
          label: const Text(
            'Add Maintenance',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    _accent.withOpacity(0.15),
                    _accent.withOpacity(0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.handyman_rounded,
                size: 56,
                color: _accent,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'No maintenance scheduled',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------- CARD WIDGET ----------
class _MaintenanceCard extends StatelessWidget {
  final MaintenanceTask task;
  final String dateLabel;
  final bool isOverdue;
  final Color accent;
  final VoidCallback onDismissed;
  final VoidCallback onStatusTap;

  const _MaintenanceCard({
    required this.task,
    required this.dateLabel,
    required this.isOverdue,
    required this.accent,
    required this.onDismissed,
    required this.onStatusTap,
  });

  @override
  Widget build(BuildContext context) {
    final priorityColor = task.priority.color;
    final statusColor = task.status.color;
    final isDone = task.status == MaintenanceStatus.completed;
    final showOverdue = isOverdue && !isDone;

    final dateColor = showOverdue ? const Color(0xFFE53935) : Colors.black54;
    final dateBg = showOverdue
        ? const Color(0xFFE53935).withOpacity(0.1)
        : Colors.grey[100];

    return Dismissible(
      key: ValueKey('${task.assetName}-${task.assetNumber}-${task.createdAt}'),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.only(right: 24),
        alignment: Alignment.centerRight,
        decoration: BoxDecoration(
          color: Colors.redAccent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_outline_rounded, color: Colors.white),
      ),
      onDismissed: (_) => onDismissed(),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: accent.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.build_circle_rounded,
                      color: accent,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Asset name + number
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                task.assetName,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black87,
                                  decoration: isDone
                                      ? TextDecoration.lineThrough
                                      : null,
                                  decorationColor: Colors.black38,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (task.assetNumber.isNotEmpty) ...[
                              const SizedBox(width: 6),
                              Flexible(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 7,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[100],
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                      color: Colors.grey.shade300,
                                    ),
                                  ),
                                  child: Text(
                                    task.assetNumber,
                                    style: TextStyle(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 0.3,
                                      color: Colors.grey[800],
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 6),

                        // Status + priority badges
                        Wrap(
                          spacing: 6,
                          runSpacing: 4,
                          children: [
                            // Tap to move the task along its status.
                            InkWell(
                              onTap: onStatusTap,
                              borderRadius: BorderRadius.circular(6),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: statusColor.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      task.status.icon,
                                      size: 12,
                                      color: statusColor,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      task.status.label,
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: statusColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: priorityColor.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                '${task.priority.label} priority',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: priorityColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: dateBg,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      dateLabel,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: dateColor,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Divider(height: 1, color: Colors.grey[200]),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: accent.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.handyman_rounded, size: 15, color: accent),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        task.taskDescription,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: accent.withOpacity(0.9),
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              if (task.image != null) ...[
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.file(
                    task.image!,
                    height: 130,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
