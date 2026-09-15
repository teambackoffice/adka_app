import 'package:flutter/material.dart';

class AssignedWorksPage extends StatelessWidget {
  const AssignedWorksPage({super.key});

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
                                'Your current service assignments',
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
                          count: '3',
                          color: const Color(0xFFF59E0B),
                        ),
                        const SizedBox(width: 10),
                        _SummaryChip(
                          icon: Icons.autorenew_rounded,
                          label: 'In Progress',
                          count: '2',
                          color: scheme.primary,
                        ),
                        const SizedBox(width: 10),
                        _SummaryChip(
                          icon: Icons.check_circle_outline_rounded,
                          label: 'Done',
                          count: '8',
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
                itemCount: _demoJobs.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final job = _demoJobs[index];
                  return _JobCard(job: job);
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
  final _Job job;

  const _JobCard({required this.job});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final statusColor = _statusColor(job.status);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: scheme.outlineVariant.withValues(alpha: 0.50)),
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

          const SizedBox(height: 14),

          // Bottom info row
          Row(
            children: [
              Icon(Icons.person_outline_rounded, size: 15, color: scheme.onSurfaceVariant),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  job.customerName,
                  style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant),
                ),
              ),
              Icon(Icons.schedule_rounded, size: 15, color: scheme.onSurfaceVariant),
              const SizedBox(width: 4),
              Text(
                job.dueDate,
                style: TextStyle(
                  fontSize: 12,
                  color: scheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
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

// ─── Demo data model & list ────────────────────────────────────────────────────

class _Job {
  final String vehicleName;
  final String vehicleNumber;
  final String serviceType;
  final String description;
  final String customerName;
  final String status;
  final String dueDate;

  const _Job({
    required this.vehicleName,
    required this.vehicleNumber,
    required this.serviceType,
    required this.description,
    required this.customerName,
    required this.status,
    required this.dueDate,
  });
}

const _demoJobs = <_Job>[
  _Job(
    vehicleName: 'Toyota Camry',
    vehicleNumber: 'KL-07-AX-3456',
    serviceType: 'Engine Oil Change & Filter',
    description: 'Full synthetic oil change with OEM filter replacement. Check brake pads.',
    customerName: 'Rahul Menon',
    status: 'In Progress',
    dueDate: 'Today',
  ),
  _Job(
    vehicleName: 'Hyundai Creta',
    vehicleNumber: 'KL-08-BN-1122',
    serviceType: 'AC Service & Recharge',
    description: 'Compressor noise reported. Check gas levels and condenser.',
    customerName: 'Anitha Nair',
    status: 'Pending',
    dueDate: 'Sep 16',
  ),
  _Job(
    vehicleName: 'Maruti Suzuki Swift',
    vehicleNumber: 'KL-10-CD-7890',
    serviceType: 'Brake Pad Replacement',
    description: 'Front and rear brake pad replacement. Inspect discs for wear.',
    customerName: 'Faiz Ahmed',
    status: 'Pending',
    dueDate: 'Sep 16',
  ),
  _Job(
    vehicleName: 'Honda City',
    vehicleNumber: 'KL-11-EF-4321',
    serviceType: 'General Service',
    description: '10K km periodic service. All fluids, filters, and inspection.',
    customerName: 'Priya Sharma',
    status: 'In Progress',
    dueDate: 'Today',
  ),
  _Job(
    vehicleName: 'Kia Seltos',
    vehicleNumber: 'KL-09-GH-6543',
    serviceType: 'Tyre Rotation & Alignment',
    description: 'Wheel alignment and balancing. Rotate all four tyres.',
    customerName: 'Vijay Kumar',
    status: 'Pending',
    dueDate: 'Sep 17',
  ),
  _Job(
    vehicleName: 'Tata Nexon',
    vehicleNumber: 'KL-12-JK-9876',
    serviceType: 'Battery Replacement',
    description: 'Replace OEM battery. Test alternator output.',
    customerName: 'Deepa Raj',
    status: 'Completed',
    dueDate: 'Sep 14',
  ),
];
