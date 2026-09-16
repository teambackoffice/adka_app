import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class QcChecklistItem {
  final String id;
  final String title;
  final String description;
  bool isCompleted;

  QcChecklistItem({
    required this.id,
    required this.title,
    required this.description,
    this.isCompleted = false,
  });
}

class QcDetailPage extends StatefulWidget {
  final Map<String, dynamic> qcItem;

  const QcDetailPage({super.key, required this.qcItem});

  @override
  State<QcDetailPage> createState() => _QcDetailPageState();
}

class _QcDetailPageState extends State<QcDetailPage> {
  late final TextEditingController _remarksController;
  final ImagePicker _picker = ImagePicker();
  bool _isSubmitting = false;

  // Attached photos list with real File support
  final List<Map<String, dynamic>> _attachedPhotos = [];

  // Mandatory Inspection checklist
  late final List<QcChecklistItem> _checklist;

  @override
  void initState() {
    super.initState();
    _remarksController = TextEditingController(
      text: widget.qcItem['status'] == 'Passed'
          ? 'Inspection completed successfully. Vehicle tested and road-ready.'
          : '',
    );

    final isPassed = widget.qcItem['status'] == 'Passed';

    _checklist = [
      QcChecklistItem(
        id: 'chk-1',
        title: 'Engine Oil Level & Quality',
        description: 'Dipstick at MAX line, clear viscosity, no debris.',
        isCompleted: isPassed,
      ),
      QcChecklistItem(
        id: 'chk-2',
        title: 'Oil Filter & Drain Plug Tightness',
        description: 'New crush washer installed, torqued with zero seepage.',
        isCompleted: isPassed,
      ),
      QcChecklistItem(
        id: 'chk-3',
        title: 'Brake Pads & Fluid Level',
        description: 'Lining thickness > 5mm; fluid reservoir at MAX marker.',
        isCompleted: isPassed,
      ),
      QcChecklistItem(
        id: 'chk-4',
        title: 'Coolant Level & Radiator Hoses',
        description: 'Coolant mix optimal; hoses supple with no hairline cracks.',
        isCompleted: isPassed,
      ),
      QcChecklistItem(
        id: 'chk-5',
        title: 'Battery Terminals & Health',
        description: 'Clean corrosion-free posts; 12.6V+ resting voltage.',
        isCompleted: isPassed,
      ),
      QcChecklistItem(
        id: 'chk-6',
        title: 'Tire Pressure & Tread Depth',
        description: 'All 4 tires calibrated to 32 PSI; even wear pattern.',
        isCompleted: isPassed,
      ),
      QcChecklistItem(
        id: 'chk-7',
        title: 'Underbody & Suspension Boots',
        description: 'Ball joints, steering gaiters & stabilizer links secure.',
        isCompleted: isPassed,
      ),
      QcChecklistItem(
        id: 'chk-8',
        title: 'OBD-II Scan & Dashboard Lights',
        description: 'Zero active diagnostic error codes; indicators functional.',
        isCompleted: isPassed,
      ),
    ];
  }

  @override
  void dispose() {
    _remarksController.dispose();
    super.dispose();
  }

  int get _completedCount => _checklist.where((e) => e.isCompleted).length;
  bool get _allTicked => _completedCount == _checklist.length;

  void _toggleChecklistItem(int index) {
    setState(() {
      _checklist[index].isCompleted = !_checklist[index].isCompleted;
    });
  }

  void _tickAll() {
    setState(() {
      final target = !_allTicked;
      for (final item in _checklist) {
        item.isCompleted = target;
      }
    });
  }

  void _addSamplePhoto([String? customLabel]) {
    final now = TimeOfDay.now();
    final timeStr =
        '${now.hourOfPeriod}:${now.minute.toString().padLeft(2, '0')} ${now.period == DayPeriod.am ? 'AM' : 'PM'}';
    final count = _attachedPhotos.length + 1;
    final label = customLabel ?? (count % 2 == 1 ? 'Engine Bay Check #$count' : 'Oil Filter Torque #$count');

    setState(() {
      _attachedPhotos.add({
        'id': 'p_${DateTime.now().millisecondsSinceEpoch}',
        'file': null,
        'label': label,
        'icon': count % 2 == 1 ? Icons.car_repair_rounded : Icons.build_circle_rounded,
        'color': count % 2 == 1 ? 0xFF0284C7 : 0xFF10B981,
        'time': timeStr,
      });
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Text('Sample photo added ($label)'),
          ],
        ),
        backgroundColor: const Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1800,
        maxHeight: 1800,
      );

      if (pickedFile != null) {
        final now = TimeOfDay.now();
        final timeStr =
            '${now.hourOfPeriod}:${now.minute.toString().padLeft(2, '0')} ${now.period == DayPeriod.am ? 'AM' : 'PM'}';
        final isCamera = source == ImageSource.camera;

        setState(() {
          _attachedPhotos.add({
            'id': 'p_${DateTime.now().millisecondsSinceEpoch}',
            'file': File(pickedFile.path),
            'label': isCamera
                ? 'Camera Shot #${_attachedPhotos.length + 1}'
                : 'Gallery Pic #${_attachedPhotos.length + 1}',
            'time': timeStr,
          });
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
                  const SizedBox(width: 8),
                  Text(isCamera ? 'Photo captured!' : 'Photo added from gallery!'),
                ],
              ),
              backgroundColor: const Color(0xFF10B981),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        final isMissingPlugin = e.toString().contains('MissingPluginException');
        final isSimulator = e.toString().toLowerCase().contains('camera not available') ||
            e.toString().toLowerCase().contains('simulator');

        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Row(
              children: [
                Icon(
                  isMissingPlugin ? Icons.restart_alt_rounded : Icons.info_outline_rounded,
                  color: Colors.orange,
                  size: 26,
                ),
                const SizedBox(width: 10),
                Text(isMissingPlugin ? 'App Rebuild Needed' : 'Camera / Gallery Notice'),
              ],
            ),
            content: Text(
              isMissingPlugin
                  ? 'A new native package (image_picker) was added. Flutter requires stopping and re-running the app (cold build) for native camera & gallery plugins to work.\n\nWould you like to attach a sample inspection photo in the meantime?'
                  : (isSimulator
                      ? 'The iOS/Android Simulator does not have a physical camera.\n\nWould you like to attach a sample inspection photo or try Gallery?'
                      : 'Unable to access device media ($e).\n\nWould you like to attach a sample inspection photo for testing?'),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  _addSamplePhoto(source == ImageSource.camera ? 'Camera Sample' : 'Gallery Sample');
                },
                child: const Text('Use Sample Photo'),
              ),
            ],
          ),
        );
      }
    }
  }

  void _openAddPhotoSheet() {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          decoration: BoxDecoration(
            color: scheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 44,
                    height: 4,
                    decoration: BoxDecoration(
                      color: scheme.outlineVariant,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  'Attach Inspection Photo',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Take a live camera picture or choose from your photo gallery',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: _buildPhotoOption(
                        icon: Icons.camera_alt_rounded,
                        title: 'Camera',
                        subtitle: 'Capture live',
                        color: const Color(0xFF0284C7),
                        onTap: () {
                          Navigator.pop(ctx);
                          _pickImage(ImageSource.camera);
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildPhotoOption(
                        icon: Icons.photo_library_rounded,
                        title: 'Gallery',
                        subtitle: 'Upload photos',
                        color: const Color(0xFF8B5CF6),
                        onTap: () {
                          Navigator.pop(ctx);
                          _pickImage(ImageSource.gallery);
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(ctx);
                      _addSamplePhoto();
                    },
                    icon: const Icon(Icons.photo_filter_rounded, size: 18),
                    label: const Text('Add Demo / Sample Photo'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPhotoOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.25)),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: TextStyle(fontSize: 11, color: scheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }

  void _removePhoto(int index) {
    setState(() {
      _attachedPhotos.removeAt(index);
    });
  }

  void _viewFullPhoto(File file, String title) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(16),
        child: Stack(
          alignment: Alignment.topRight,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: InteractiveViewer(
                child: Image.file(
                  file,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            IconButton.filled(
              onPressed: () => Navigator.pop(ctx),
              icon: const Icon(Icons.close_rounded),
              style: IconButton.styleFrom(
                backgroundColor: Colors.black.withValues(alpha: 0.6),
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _submitInspection() async {
    // 1. Validate Checklist: ALL must be ticked!
    if (!_allTicked) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline_rounded, color: Colors.white, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Please tick all ${_checklist.length} inspection checkpoints before submitting ($_completedCount/${_checklist.length} checked).',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          duration: const Duration(seconds: 3),
        ),
      );
      return;
    }

    // 2. Validate Remarks
    final remarksText = _remarksController.text.trim();
    if (remarksText.isEmpty) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.edit_note_rounded, color: Colors.white, size: 20),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Please enter your inspection remarks before submitting.',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.orange.shade800,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          duration: const Duration(seconds: 3),
        ),
      );
      return;
    }

    // 3. Validate Photos: At least one picture attached
    if (_attachedPhotos.isEmpty) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.photo_camera_rounded, color: Colors.white, size: 20),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Please attach at least one inspection photo from Camera or Gallery.',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.orange.shade800,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          duration: const Duration(seconds: 3),
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    await Future.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;
    setState(() => _isSubmitting = false);

    // Show Success Bottom Sheet directly and complete
    _showSuccessAndFinish(remarksText);
  }

  void _showSuccessAndFinish(String remarksText) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          decoration: BoxDecoration(
            color: isDark ? scheme.surfaceContainerHigh : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 24,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withValues(alpha: 0.14),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle_rounded,
                    color: Color(0xFF10B981),
                    size: 54,
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  'QC Passed & Submitted!',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'All checkpoints verified, remarks logged, and ${_attachedPhotos.length} photos attached for ${widget.qcItem['vehicleName']}',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () {
                      Navigator.pop(ctx); // close bottom sheet
                      Navigator.pop(context, {
                        'id': widget.qcItem['id'],
                        'status': 'Passed',
                        'checklistCompleted': _checklist.length,
                        'checklistTotal': _checklist.length,
                        'remarks': remarksText,
                        'photosCount': _attachedPhotos.length,
                      }); // pop page back to list
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      'Done',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: AppBar(
        backgroundColor: scheme.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quality Inspection',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '${widget.qcItem['id']} • ${widget.qcItem['vehicleNumber']}',
              style: TextStyle(
                fontSize: 11,
                color: scheme.onSurfaceVariant,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── 1. Vehicle Info Banner ──────────────────────────────────────────
            _buildVehicleBanner(scheme, isDark),

            const SizedBox(height: 20),

            // ── 2. Inspection Checklist Header & Quick "Tick All" ───────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: _allTicked
                            ? const Color(0xFF10B981).withValues(alpha: 0.12)
                            : scheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        _allTicked
                            ? Icons.check_circle_rounded
                            : Icons.fact_check_rounded,
                        size: 18,
                        color: _allTicked
                            ? const Color(0xFF10B981)
                            : scheme.primary,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Inspection Checklist',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: _allTicked
                            ? const Color(0xFF10B981).withValues(alpha: 0.14)
                            : scheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '$_completedCount/${_checklist.length}',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: _allTicked
                              ? const Color(0xFF10B981)
                              : scheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
                FilledButton.tonalIcon(
                  onPressed: _tickAll,
                  icon: Icon(
                    _allTicked
                        ? Icons.check_box_outlined
                        : Icons.check_box_outline_blank,
                    size: 16,
                  ),
                  label: Text(
                    _allTicked ? 'Uncheck' : 'Tick All',
                    style: const TextStyle(fontSize: 12),
                  ),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    visualDensity: VisualDensity.compact,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // ── 3. Inspection Checklist Items ───────────────────────────────────
            ListView.separated(
              itemCount: _checklist.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              separatorBuilder: (context, index) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final item = _checklist[index];
                return _buildChecklistTile(item, index, scheme, isDark);
              },
            ),

            const SizedBox(height: 28),

            // ── 4. Remarks Section ──────────────────────────────────────────────
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: Colors.amber.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.rate_review_rounded,
                    size: 18,
                    color: Colors.amber,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  'Remarks',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildRemarksSection(scheme, isDark),

            const SizedBox(height: 28),

            // ── 5. Attach Pics Section ──────────────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0284C7).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.photo_camera_rounded,
                        size: 18,
                        color: Color(0xFF0284C7),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Attach Pics',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: scheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${_attachedPhotos.length}',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: scheme.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                FilledButton.tonalIcon(
                  onPressed: _openAddPhotoSheet,
                  icon: const Icon(Icons.add_a_photo_rounded, size: 16),
                  label: const Text('Add Pic', style: TextStyle(fontSize: 12)),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    visualDensity: VisualDensity.compact,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildPhotosGrid(scheme, isDark),
          ],
        ),
      ),

      // ── Single Direct Submit Button ───────────────────────────────────────
      bottomNavigationBar: Container(
        padding: EdgeInsets.fromLTRB(
          16,
          12,
          16,
          MediaQuery.of(context).padding.bottom + 12,
        ),
        decoration: BoxDecoration(
          color: isDark ? scheme.surfaceContainerHigh : Colors.white,
          border: Border(
            top: BorderSide(
              color: scheme.outlineVariant.withValues(alpha: 0.4),
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.06),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: FilledButton.icon(
          onPressed: _isSubmitting ? null : _submitInspection,
          icon: _isSubmitting
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Icon(Icons.check_circle_rounded, size: 20),
          label: Text(
            _isSubmitting ? 'Submitting...' : 'Submit QC',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          style: FilledButton.styleFrom(
            backgroundColor: _allTicked
                ? const Color(0xFF10B981)
                : const Color(0xFF0469B1),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            elevation: 2,
          ),
        ),
      ),
    );
  }

  // ── Helper Sub-Widgets ──────────────────────────────────────────────────────

  Widget _buildVehicleBanner(ColorScheme scheme, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? scheme.surfaceContainerHigh : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: scheme.outline.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: scheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  Icons.directions_car_rounded,
                  color: scheme.primary,
                  size: 26,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.qcItem['vehicleName'] as String,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: scheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            widget.qcItem['vehicleNumber'] as String,
                            style: const TextStyle(
                              fontSize: 11,
                              fontFamily: 'monospace',
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          widget.qcItem['jobId'] as String,
                          style: TextStyle(
                            fontSize: 11,
                            color: scheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
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
                  color: widget.qcItem['status'] == 'Passed'
                      ? Colors.green.withValues(alpha: 0.12)
                      : scheme.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  widget.qcItem['status'] as String,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: widget.qcItem['status'] == 'Passed'
                        ? Colors.green
                        : scheme.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Divider(color: scheme.outline.withValues(alpha: 0.08), height: 1),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                Icons.build_circle_outlined,
                size: 15,
                color: scheme.onSurfaceVariant,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  widget.qcItem['serviceType'] as String,
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
    );
  }

  Widget _buildChecklistTile(
    QcChecklistItem item,
    int index,
    ColorScheme scheme,
    bool isDark,
  ) {
    final isDone = item.isCompleted;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _toggleChecklistItem(index),
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isDone
                ? (isDark
                    ? const Color(0xFF064E3B).withValues(alpha: 0.25)
                    : const Color(0xFFECFDF5))
                : (isDark ? scheme.surfaceContainerHigh : Colors.white),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDone
                  ? const Color(0xFF10B981).withValues(alpha: 0.5)
                  : scheme.outline.withValues(alpha: 0.1),
              width: isDone ? 1.5 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Circular tick mark
              GestureDetector(
                onTap: () => _toggleChecklistItem(index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: isDone
                        ? const Color(0xFF10B981)
                        : Colors.transparent,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isDone
                          ? const Color(0xFF10B981)
                          : scheme.outline.withValues(alpha: 0.45),
                      width: 2,
                    ),
                  ),
                  child: isDone
                      ? const Icon(
                          Icons.check_rounded,
                          color: Colors.white,
                          size: 20,
                        )
                      : null,
                ),
              ),
              const SizedBox(width: 14),

              // Title and description
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: isDone
                            ? (isDark ? Colors.white : const Color(0xFF065F46))
                            : scheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      item.description,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDone
                            ? (isDark
                                ? Colors.white70
                                : const Color(0xFF047857))
                            : scheme.onSurfaceVariant,
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

  Widget _buildRemarksSection(ColorScheme scheme, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? scheme.surfaceContainerHigh : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: scheme.outline.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _remarksController,
        maxLines: 4,
        style: const TextStyle(fontSize: 13),
        decoration: InputDecoration(
          hintText: 'Enter your inspection remarks here...',
          hintStyle: TextStyle(
            fontSize: 13,
            color: scheme.onSurfaceVariant.withValues(alpha: 0.7),
          ),
          filled: true,
          fillColor: scheme.surfaceContainerHighest.withValues(alpha: 0.35),
          contentPadding: const EdgeInsets.all(14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(
              color: scheme.outline.withValues(alpha: 0.15),
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(
              color: scheme.outline.withValues(alpha: 0.15),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: scheme.primary, width: 1.5),
          ),
        ),
      ),
    );
  }

  Widget _buildPhotosGrid(ColorScheme scheme, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 130,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _attachedPhotos.length + 1,
            separatorBuilder: (context, index) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              if (index == _attachedPhotos.length) {
                // Add Photo Card
                return InkWell(
                  onTap: _openAddPhotoSheet,
                  borderRadius: BorderRadius.circular(18),
                  child: Container(
                    width: 110,
                    decoration: BoxDecoration(
                      color: scheme.primary.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: scheme.primary.withValues(alpha: 0.25),
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: scheme.primary.withValues(alpha: 0.12),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.add_a_photo_rounded,
                            color: scheme.primary,
                            size: 22,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Add Pic',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: scheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              final photo = _attachedPhotos[index];
              final File? photoFile = photo['file'] as File?;

              return Container(
                width: 130,
                decoration: BoxDecoration(
                  color: isDark ? scheme.surfaceContainerHigh : Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: scheme.outline.withValues(alpha: 0.1),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: Stack(
                    children: [
                      // Photo Preview
                      Positioned.fill(
                        child: photoFile != null
                            ? GestureDetector(
                                onTap: () => _viewFullPhoto(
                                  photoFile,
                                  photo['label'] as String,
                                ),
                                child: Image.file(
                                  photoFile,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Color((photo['color'] as int?) ?? 0xFF0284C7)
                                          .withValues(alpha: 0.15),
                                      Color((photo['color'] as int?) ?? 0xFF0284C7)
                                          .withValues(alpha: 0.35),
                                    ],
                                  ),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      (photo['icon'] as IconData?) ??
                                          Icons.image_rounded,
                                      size: 34,
                                      color: Color(
                                        (photo['color'] as int?) ?? 0xFF0284C7,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                      ),
                                      child: Text(
                                        photo['label'] as String,
                                        maxLines: 2,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: isDark
                                              ? Colors.white
                                              : Colors.black87,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                      ),

                      // Timestamp overlay badge
                      Positioned(
                        bottom: 6,
                        left: 6,
                        right: 6,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.65),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            photo['time'] as String,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 9,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),

                      // Delete button
                      Positioned(
                        top: 6,
                        right: 6,
                        child: GestureDetector(
                          onTap: () => _removePhoto(index),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.65),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close_rounded,
                              size: 14,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
