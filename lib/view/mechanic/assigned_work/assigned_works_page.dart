import 'package:flutter/material.dart';
import '../../../modal/job_model.dart';
import '../../../modal/material_request_model.dart';
import 'work_detail_page.dart';

class AssignedWorksPage extends StatefulWidget {
  const AssignedWorksPage({super.key});

  @override
  State<AssignedWorksPage> createState() => _AssignedWorksPageState();
}

class _AssignedWorksPageState extends State<AssignedWorksPage> {
  late List<Job> _jobs;

  @override
  void initState() {
    super.initState();
    _jobs = [
      Job(
        id: 'JOB-001',
        vehicleName: 'Toyota Camry',
        vehicleNumber: 'KL-07-AX-3456',
        serviceType: 'Engine Oil Change & Filter',
        description:
            'Full synthetic oil change with OEM filter replacement. Check brake pads.',
        customerName: 'Rahul Menon',
        customerPhone: '+91 98470 12345',
        status: 'In Progress',
        dueDate: 'Today',
        materialRequests: [
          MaterialRequest(
            id: 'MR-001',
            materialRequestType: 'Purchase',
            company: 'Al Sahel Medical College Supplies LLC',
            setWarehouse: 'Stores - ASMCSL',
            items: [
              MaterialRequestItem(
                itemCode: 'ECG Machine',
                qty: 5,
                rate: 50000,
                warehouse: 'Stores - ASMCSL',
              ),
            ],
          ),
        ],
      ),
      Job(
        id: 'JOB-002',
        vehicleName: 'Hyundai Creta',
        vehicleNumber: 'KL-08-BN-1122',
        serviceType: 'AC Service & Recharge',
        description:
            'Compressor noise reported. Check gas levels and condenser.',
        customerName: 'Anitha Nair',
        customerPhone: '+91 98471 23456',
        status: 'Pending',
        dueDate: 'Sep 16',
      ),
      Job(
        id: 'JOB-003',
        vehicleName: 'Maruti Suzuki Swift',
        vehicleNumber: 'KL-10-CD-7890',
        serviceType: 'Brake Pad Replacement',
        description:
            'Front and rear brake pad replacement. Inspect discs for wear.',
        customerName: 'Faiz Ahmed',
        customerPhone: '+91 98472 34567',
        status: 'Pending',
        dueDate: 'Sep 16',
      ),
      Job(
        id: 'JOB-004',
        vehicleName: 'Honda City',
        vehicleNumber: 'KL-11-EF-4321',
        serviceType: 'General Service',
        description:
            '10K km periodic service. All fluids, filters, and inspection.',
        customerName: 'Priya Sharma',
        customerPhone: '+91 98473 45678',
        status: 'In Progress',
        dueDate: 'Today',
      ),
      Job(
        id: 'JOB-005',
        vehicleName: 'Kia Seltos',
        vehicleNumber: 'KL-09-GH-6543',
        serviceType: 'Tyre Rotation & Alignment',
        description: 'Wheel alignment and balancing. Rotate all four tyres.',
        customerName: 'Vijay Kumar',
        customerPhone: '+91 98474 56789',
        status: 'Pending',
        dueDate: 'Sep 17',
      ),
      Job(
        id: 'JOB-006',
        vehicleName: 'Tata Nexon',
        vehicleNumber: 'KL-12-JK-9876',
        serviceType: 'Battery Replacement',
        description: 'Replace OEM battery. Test alternator output.',
        customerName: 'Deepa Raj',
        customerPhone: '+91 98475 67890',
        status: 'Completed',
        dueDate: 'Sep 14',
      ),
    ];
  }

  int get _pendingCount =>
      _jobs.where((j) => j.status.toLowerCase() == 'pending').length;

  int get _inProgressCount =>
      _jobs.where((j) => j.status.toLowerCase() == 'in progress').length;

  int get _completedCount =>
      _jobs.where((j) => j.status.toLowerCase() == 'completed').length;

  Future<void> _openDetail(int index) async {
    final updatedJob = await Navigator.push<Job>(
      context,
      MaterialPageRoute(
        builder: (context) => WorkDetailPage(job: _jobs[index]),
      ),
    );

    if (updatedJob != null && mounted) {
      setState(() {
        _jobs[index] = updatedJob;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: scheme.surface,
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
            // ── Header ───────────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: scheme.primary.withValues(alpha: 0.10),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(
                            Icons.build_rounded,
                            color: scheme.primary,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Assigned Works',
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: scheme.onSurface,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Tap any job to view details or create requests',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: scheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // ── Summary cards ────────────────────────────────────
                    Row(
                      children: [
                        _SummaryChip(
                          icon: Icons.pending_actions_rounded,
                          label: 'Pending',
                          count: '$_pendingCount',
                          color: const Color(0xFFF59E0B),
                        ),
                        const SizedBox(width: 10),
                        _SummaryChip(
                          icon: Icons.autorenew_rounded,
                          label: 'In Progress',
                          count: '$_inProgressCount',
                          color: scheme.primary,
                        ),
                        const SizedBox(width: 10),
                        _SummaryChip(
                          icon: Icons.check_circle_outline_rounded,
                          label: 'Done',
                          count: '$_completedCount',
                          color: const Color(0xFF10B981),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),

            // ── Job list ─────────────────────────────────────────────────
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
              sliver: SliverList.separated(
                itemCount: _jobs.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final job = _jobs[index];
                  return _JobCard(job: job, onTap: () => _openDetail(index));
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Summary chip ──────────────────────────────────────────────────────────────

class _SummaryChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String count;
  final Color color;

  const _SummaryChip({
    required this.icon,
    required this.label,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.18)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 6),
            Text(
              count,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: color.withValues(alpha: 0.80),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Job card ──────────────────────────────────────────────────────────────────

class _JobCard extends StatelessWidget {
  final Job job;
  final VoidCallback onTap;

  const _JobCard({required this.job, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final statusColor = _statusColor(job.status);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: scheme.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: scheme.outlineVariant.withValues(alpha: 0.50),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top row: vehicle + status
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: scheme.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.directions_car_rounded,
                      color: scheme.primary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          job.vehicleName,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          job.vehicleNumber,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _StatusBadge(status: job.status, color: statusColor),
                ],
              ),

              const SizedBox(height: 14),

              // Service description
              Text(
                job.serviceType,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: scheme.onSurface,
                ),
              ),
              if (job.description.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  job.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],

              const SizedBox(height: 12),

              // Bottom row: customer info & material requests count tag
              Row(
                children: [
                  Icon(
                    Icons.person_outline_rounded,
                    size: 14,
                    color: scheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      job.customerName,
                      style: TextStyle(
                        fontSize: 12,
                        color: scheme.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (job.materialRequests.isNotEmpty) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: scheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.inventory_2_rounded,
                            size: 12,
                            color: scheme.primary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${job.materialRequests.length} MR',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: scheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  Icon(
                    Icons.schedule_rounded,
                    size: 14,
                    color: scheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    job.dueDate,
                    style: TextStyle(
                      fontSize: 12,
                      color: scheme.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.chevron_right_rounded,
                    size: 18,
                    color: scheme.onSurfaceVariant,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return const Color(0xFFF59E0B);
      case 'in progress':
        return const Color(0xFF0469B1);
      case 'completed':
        return const Color(0xFF10B981);
      default:
        return Colors.grey;
    }
  }
}

// ─── Status badge ──────────────────────────────────────────────────────────────

class _StatusBadge extends StatelessWidget {
  final String status;
  final Color color;

  const _StatusBadge({required this.status, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.30)),
      ),
      child: Text(
        status,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}
