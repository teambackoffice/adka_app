import 'package:flutter/material.dart';
import 'qc_detail_page.dart';

class QcPage extends StatefulWidget {
  const QcPage({super.key});

  @override
  State<QcPage> createState() => _QcPageState();
}

class _QcPageState extends State<QcPage> {
  String _selectedFilter = 'All';

  final List<Map<String, dynamic>> _qcItems = [
    {
      'id': 'QC-2024-001',
      'jobId': 'JOB-001',
      'vehicleName': 'Toyota Camry',
      'vehicleNumber': 'KL-07-AX-3456',
      'serviceType': 'Engine Oil Change & Filter',
      'mechanic': 'Murshid (Self)',
      'status': 'Pending',
      'date': 'Today, 11:30 AM',
      'checklistTotal': 8,
      'checklistCompleted': 4,
    },
    {
      'id': 'QC-2024-002',
      'jobId': 'JOB-004',
      'vehicleName': 'Honda Civic',
      'vehicleNumber': 'KL-01-CD-5678',
      'serviceType': 'Brake Pad & Rotor Replacement',
      'mechanic': 'Murshid (Self)',
      'status': 'Passed',
      'date': 'Yesterday',
      'checklistTotal': 8,
      'checklistCompleted': 8,
    },
    {
      'id': 'QC-2024-003',
      'jobId': 'JOB-005',
      'vehicleName': 'Ford EcoSport',
      'vehicleNumber': 'KL-07-EF-9012',
      'serviceType': 'Suspension Bushing Replacement',
      'mechanic': 'Murshid (Self)',
      'status': 'In Review',
      'date': 'Sep 14',
      'checklistTotal': 8,
      'checklistCompleted': 5,
    },
  ];

  List<Map<String, dynamic>> get _filteredItems {
    if (_selectedFilter == 'All') return _qcItems;
    return _qcItems
        .where(
          (item) =>
              item['status'].toString().toLowerCase() ==
              _selectedFilter.toLowerCase(),
        )
        .toList();
  }

  Color _getStatusColor(String status, ColorScheme scheme) {
    switch (status.toLowerCase()) {
      case 'passed':
        return const Color(0xFF10B981);
      case 'in review':
        return Colors.orange;
      case 'pending':
      default:
        return scheme.primary;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'passed':
        return Icons.check_circle_outline_rounded;
      case 'in review':
        return Icons.pending_actions_rounded;
      case 'pending':
      default:
        return Icons.hourglass_top_rounded;
    }
  }

  void _openDetailPage(Map<String, dynamic> item) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => QcDetailPage(qcItem: item)),
    );

    if (result != null && result is Map<String, dynamic>) {
      setState(() {
        item['status'] = result['status'];
        item['checklistCompleted'] = result['checklistCompleted'];
        item['checklistTotal'] = result['checklistTotal'];
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(
                  Icons.verified_rounded,
                  color: Colors.white,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text('Updated ${item['id']} to ${result['status']}'),
              ],
            ),
            backgroundColor: _getStatusColor(
              result['status'] as String,
              Theme.of(context).colorScheme,
            ),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final pendingCount = _qcItems.where((i) => i['status'] == 'Pending').length;
    final passedCount = _qcItems.where((i) => i['status'] == 'Passed').length;

    return Scaffold(
      backgroundColor: scheme.surface,
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
            // ── Header ───────────────────────────────────────────────────────
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
                            Icons.fact_check_rounded,
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
                                'Quality Control',
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: scheme.onSurface,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // ── Filter Chips Row ──────────────────────────────────────
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildFilterChip('All', _qcItems.length, scheme),
                          const SizedBox(width: 8),
                          _buildFilterChip('Pending', pendingCount, scheme),
                          const SizedBox(width: 8),

                          _buildFilterChip('Passed', passedCount, scheme),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),

            // ── Items List ───────────────────────────────────────────────────
            if (_filteredItems.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.fact_check_outlined,
                        size: 56,
                        color: scheme.onSurfaceVariant.withValues(alpha: 0.4),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'No QC records found for "$_selectedFilter"',
                        style: TextStyle(
                          color: scheme.onSurfaceVariant,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final item = _filteredItems[index];
                    final status = item['status'] as String;
                    final statusColor = _getStatusColor(status, scheme);

                    return Container(
                      margin: const EdgeInsets.only(bottom: 14),
                      decoration: BoxDecoration(
                        color: isDark
                            ? scheme.surfaceContainerHigh
                            : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: scheme.outline.withValues(alpha: 0.08),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(
                              alpha: isDark ? 0.25 : 0.04,
                            ),
                            blurRadius: 14,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(20),
                          onTap: () => _openDetailPage(item),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            item['id'] as String,
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                              color: scheme.primary,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            item['vehicleName'] as String,
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(
                                            item['vehicleNumber'] as String,
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: scheme.onSurfaceVariant,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 5,
                                      ),
                                      decoration: BoxDecoration(
                                        color: statusColor.withValues(
                                          alpha: 0.12,
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            _getStatusIcon(status),
                                            size: 14,
                                            color: statusColor,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            status,
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                              color: statusColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Divider(
                                  color: scheme.outline.withValues(alpha: 0.08),
                                  height: 1,
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.build_circle_outlined,
                                      size: 16,
                                      color: scheme.onSurfaceVariant,
                                    ),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        item['serviceType'] as String,
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: scheme.onSurfaceVariant,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }, childCount: _filteredItems.length),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, int count, ColorScheme scheme) {
    final isSelected = _selectedFilter.toLowerCase() == label.toLowerCase();

    return FilterChip(
      selected: isSelected,
      label: Text('$label ($count)'),
      labelStyle: TextStyle(
        fontSize: 12,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
        color: isSelected ? scheme.primary : scheme.onSurfaceVariant,
      ),
      backgroundColor: scheme.surfaceContainerHighest.withValues(alpha: 0.4),
      selectedColor: scheme.primary.withValues(alpha: 0.15),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected
              ? scheme.primary.withValues(alpha: 0.4)
              : scheme.outline.withValues(alpha: 0.1),
        ),
      ),
      showCheckmark: false,
      onSelected: (selected) {
        setState(() {
          _selectedFilter = label;
        });
      },
    );
  }
}
