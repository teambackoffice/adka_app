// ---------- ADD MAINTENANCE TASK PAGE ----------
import 'dart:io';
import 'package:adka_app/view/field_staff/breakdown/breakdown.dart'
    show Priority, PriorityX;
import 'package:adka_app/view/field_staff/maintenence/maintenence.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class AddMaintenanceTaskPage extends StatefulWidget {
  const AddMaintenanceTaskPage({super.key});

  @override
  State<AddMaintenanceTaskPage> createState() => _AddMaintenanceTaskPageState();
}

class _AddMaintenanceTaskPageState extends State<AddMaintenanceTaskPage> {
  static const Color _primaryColor = Color(0xFF0469B1);

  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _assetNumberController = TextEditingController();

  // Replace with your actual asset list (from API / provider / etc.)
  final List<String> _assets = ['Vehicle', 'Machine'];

  String? _selectedAsset;
  Priority _priority = Priority.medium;
  DateTime _scheduledDate = DateTime.now();
  File? _attachedImage;
  bool _isSubmitting = false;

  bool get _isVehicle => _selectedAsset == 'Vehicle';

  @override
  void dispose() {
    _descriptionController.dispose();
    _assetNumberController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _scheduledDate,
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: Theme.of(
            context,
          ).colorScheme.copyWith(primary: _primaryColor),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() => _scheduledDate = picked);
    }
  }

  Future<void> _pickImage() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(
                Icons.camera_alt_rounded,
                color: _primaryColor,
              ),
              title: const Text('Take a photo'),
              onTap: () => Navigator.pop(sheetContext, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(
                Icons.photo_library_rounded,
                color: _primaryColor,
              ),
              title: const Text('Choose from gallery'),
              onTap: () => Navigator.pop(sheetContext, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );

    if (source == null) return;

    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(source: source, imageQuality: 80);
      if (picked != null) {
        setState(() => _attachedImage = File(picked.path));
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            source == ImageSource.camera
                ? 'Camera not available on this device/emulator.'
                : 'Could not open gallery: $e',
          ),
        ),
      );
    }
  }

  Future<void> _submit() async {
    if (_selectedAsset == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a vehicle/machine')),
      );
      return;
    }
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    final task = MaintenanceTask(
      assetName: _selectedAsset!,
      assetNumber: _assetNumberController.text.trim(),
      taskDescription: _descriptionController.text.trim(),
      priority: _priority,
      scheduledDate: _scheduledDate,
      image: _attachedImage,
    );

    await Future.delayed(const Duration(milliseconds: 200));
    if (!mounted) return;

    Navigator.pop(context, task);
  }

  Widget _sectionLabel(String text, {bool required = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
          children: [
            TextSpan(text: text),
            if (required)
              const TextSpan(
                text: ' *',
                style: TextStyle(color: Colors.redAccent),
              ),
          ],
        ),
      ),
    );
  }

  InputDecoration _boxDecoration({String? hint}) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.grey.shade400),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.grey.shade400),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: _primaryColor, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Schedule Maintenance',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0.5,
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Vehicle / Machine dropdown
              _sectionLabel('Vehicle/Machine', required: true),
              DropdownButtonFormField<String>(
                initialValue: _selectedAsset,
                decoration: _boxDecoration(hint: 'Select Asset'),
                icon: const Icon(Icons.arrow_drop_down),
                items: _assets
                    .map(
                      (asset) =>
                          DropdownMenuItem(value: asset, child: Text(asset)),
                    )
                    .toList(),
                onChanged: (value) => setState(() {
                  _selectedAsset = value;
                  _assetNumberController.clear();
                }),
                validator: (value) =>
                    value == null ? 'Select a vehicle/machine' : null,
              ),

              // Vehicle / Machine number — appears once an asset is selected
              if (_selectedAsset != null) ...[
                const SizedBox(height: 20),
                _sectionLabel(
                  _isVehicle ? 'Vehicle Number' : 'Machine Number',
                  required: true,
                ),
                TextFormField(
                  controller: _assetNumberController,
                  textCapitalization: TextCapitalization.characters,
                  textInputAction: TextInputAction.next,
                  decoration: _boxDecoration(
                    hint: _isVehicle ? 'e.g. KL 07 AB 1234' : 'e.g. MCH-014',
                  ),
                  validator: (value) => (value == null || value.trim().isEmpty)
                      ? 'Enter the ${_isVehicle ? 'vehicle' : 'machine'} number'
                      : null,
                ),
              ],
              const SizedBox(height: 20),

              // Scheduled date
              _sectionLabel('Scheduled Date', required: true),
              GestureDetector(
                onTap: _pickDate,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey.shade400),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.calendar_today_rounded,
                        size: 18,
                        color: _primaryColor,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        '${_scheduledDate.day}/${_scheduledDate.month}/${_scheduledDate.year}',
                        style: const TextStyle(
                          fontSize: 14.5,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Description
              _sectionLabel('Task Description', required: true),
              TextFormField(
                controller: _descriptionController,
                maxLines: 5,
                decoration: _boxDecoration(
                  hint: 'Describe the maintenance task...',
                ),
                validator: (value) => (value == null || value.trim().isEmpty)
                    ? 'Describe the task'
                    : null,
              ),
              const SizedBox(height: 20),

              // Attach photo
              Row(
                children: [
                  const Icon(Icons.camera_alt_outlined, size: 18),
                  const SizedBox(width: 6),
                  _sectionLabel('Attach Photo'),
                ],
              ),
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  width: double.infinity,
                  height: _attachedImage != null ? 160 : 60,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey.shade400),
                  ),
                  child: _attachedImage != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              Image.file(_attachedImage!, fit: BoxFit.cover),
                              Positioned(
                                top: 6,
                                right: 6,
                                child: GestureDetector(
                                  onTap: () =>
                                      setState(() => _attachedImage = null),
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: const BoxDecoration(
                                      color: Colors.black54,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.close,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      : Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.add_a_photo_outlined,
                                size: 18,
                                color: Colors.grey.shade600,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Tap to take a photo or choose one',
                                style: TextStyle(color: Colors.grey.shade600),
                              ),
                            ],
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 20),

              // Priority
              _sectionLabel('Priority'),
              Row(
                children: Priority.values.map((p) {
                  return Expanded(
                    child: RadioListTile<Priority>(
                      value: p,
                      groupValue: _priority,
                      onChanged: (value) => setState(() => _priority = value!),
                      title: Text(
                        p.label,
                        style: const TextStyle(fontSize: 14),
                      ),
                      contentPadding: EdgeInsets.zero,
                      dense: true,
                      activeColor: _primaryColor,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 28),

              // Submit
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 1,
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation(Colors.white),
                          ),
                        )
                      : const Text(
                          'SUBMIT',
                          style: TextStyle(
                            fontSize: 15.5,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}
