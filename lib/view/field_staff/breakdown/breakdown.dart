import 'package:adka_app/view/field_staff/breakdown/create_breakdown.dart';
import 'package:flutter/material.dart';

// ---------- MODEL ----------
class BreakdownVehicle {
  final String vehicleNumber;
  final String driverName;
  final String location;
  final String issue;
  final DateTime reportedAt;

  BreakdownVehicle({
    required this.vehicleNumber,
    required this.driverName,
    required this.location,
    required this.issue,
    required this.reportedAt,
  });
}

// ---------- BREAKDOWN LIST PAGE ----------
class FieldStaffBreakdownPage extends StatefulWidget {
  const FieldStaffBreakdownPage({super.key});

  @override
  State<FieldStaffBreakdownPage> createState() =>
      _FieldStaffBreakdownPageState();
}

class _FieldStaffBreakdownPageState extends State<FieldStaffBreakdownPage> {
  final List<BreakdownVehicle> _breakdownVehicles = [];

  static const Color _accent = Color(0xFF0469B1); // brand blue accent
  static const Color _bg = Color(0xFFF6F7FB);

  Future<void> _goToAddPage() async {
    final result = await Navigator.push<BreakdownVehicle>(
      context,
      MaterialPageRoute(builder: (context) => const AddBreakdownVehiclePage()),
    );

    if (result != null) {
      setState(() {
        _breakdownVehicles.insert(0, result);
      });
    }
  }

  void _removeVehicle(int index) {
    final removed = _breakdownVehicles[index];
    setState(() => _breakdownVehicles.removeAt(index));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.black87,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        content: Text('${removed.vehicleNumber} removed'),
        action: SnackBarAction(
          label: 'UNDO',
          textColor: Colors.orangeAccent,
          onPressed: () {
            setState(() => _breakdownVehicles.insert(index, removed));
          },
        ),
      ),
    );
  }

  String _timeLabel(DateTime dt) {
    final now = DateTime.now();
    final isToday =
        now.year == dt.year && now.month == dt.month && now.day == dt.day;
    final time =
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    return isToday ? 'Today, $time' : '${dt.day}/${dt.month} • $time';
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
          'Vehicle Breakdowns',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 20,
            color: Colors.black87,
          ),
        ),
        actions: [
          if (_breakdownVehicles.isNotEmpty)
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
                    '${_breakdownVehicles.length} active',
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
        child: _breakdownVehicles.isEmpty
            ? _buildEmptyState()
            : RefreshIndicator(
                onRefresh: () async => setState(() {}),
                child: ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
                  itemCount: _breakdownVehicles.length,
                  itemBuilder: (context, index) {
                    final vehicle = _breakdownVehicles[index];
                    return _BreakdownCard(
                      vehicle: vehicle,
                      timeLabel: _timeLabel(vehicle.reportedAt),
                      accent: _accent,
                      onDismissed: () => _removeVehicle(index),
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
            'Add Breakdown',
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
                Icons.car_repair_rounded,
                size: 56,
                color: _accent,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'No breakdowns reported',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'All vehicles are running smoothly. Tap the button\nbelow to log a new breakdown.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: Colors.black45,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------- CARD WIDGET ----------
class _BreakdownCard extends StatelessWidget {
  final BreakdownVehicle vehicle;
  final String timeLabel;
  final Color accent;
  final VoidCallback onDismissed;

  const _BreakdownCard({
    required this.vehicle,
    required this.timeLabel,
    required this.accent,
    required this.onDismissed,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey('${vehicle.vehicleNumber}-${vehicle.reportedAt}'),
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
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: accent.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.local_shipping_rounded,
                      color: accent,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          vehicle.vehicleNumber,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          vehicle.driverName,
                          style: const TextStyle(
                            fontSize: 12.5,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      timeLabel,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.black54,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Divider(height: 1, color: Colors.grey[200]),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.location_on_outlined,
                    size: 15,
                    color: Colors.grey[500],
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      vehicle.location,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.black87,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
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
                  children: [
                    Icon(Icons.report_problem_rounded, size: 15, color: accent),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        vehicle.issue,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: accent.withOpacity(0.9),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
