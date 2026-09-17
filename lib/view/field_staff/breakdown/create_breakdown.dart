// ---------- ADD BREAKDOWN VEHICLE PAGE ----------
import 'package:adka_app/view/field_staff/breakdown/breakdown.dart';
import 'package:flutter/material.dart';

class AddBreakdownVehiclePage extends StatefulWidget {
  const AddBreakdownVehiclePage({super.key});

  @override
  State<AddBreakdownVehiclePage> createState() =>
      _AddBreakdownVehiclePageState();
}

class _AddBreakdownVehiclePageState extends State<AddBreakdownVehiclePage> {
  final _formKey = GlobalKey<FormState>();
  final _vehicleNumberController = TextEditingController();
  final _driverNameController = TextEditingController();
  final _locationController = TextEditingController();
  final _issueController = TextEditingController();

  bool _isSubmitting = false;

  @override
  void dispose() {
    _vehicleNumberController.dispose();
    _driverNameController.dispose();
    _locationController.dispose();
    _issueController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    final vehicle = BreakdownVehicle(
      vehicleNumber: _vehicleNumberController.text.trim(),
      driverName: _driverNameController.text.trim(),
      location: _locationController.text.trim(),
      issue: _issueController.text.trim(),
      reportedAt: DateTime.now(),
    );

    await Future.delayed(const Duration(milliseconds: 200)); // small UX pause
    if (!mounted) return;

    Navigator.pop(context, vehicle);
  }

  InputDecoration _decoration({
    required String label,
    required IconData icon,
    String? hint,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(icon, color: Color(0xFF0469B1)),
      filled: true,
      fillColor: Colors.grey.shade50,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF0469B1), width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 14),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text(
          'Report Breakdown',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        backgroundColor: Color(0xFF0469B1),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header banner
                Container(
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Color(0xFF0469B1),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Color(0xFF0469B1)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Color(0xFF0469B1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.local_shipping,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Fill in the vehicle and issue details to log a new breakdown.',
                          style: TextStyle(
                            fontSize: 13.5,
                            color: Colors.white,
                            height: 1.3,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Card with form fields
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _vehicleNumberController,
                        textCapitalization: TextCapitalization.characters,
                        decoration: _decoration(
                          label: 'Vehicle Number',
                          icon: Icons.directions_car_filled_outlined,
                          hint: '',
                        ),
                        validator: (value) =>
                            (value == null || value.trim().isEmpty)
                            ? 'Enter vehicle number'
                            : null,
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _driverNameController,
                        textCapitalization: TextCapitalization.words,
                        decoration: _decoration(
                          label: 'Driver Name',
                          icon: Icons.person_outline,
                        ),
                        validator: (value) =>
                            (value == null || value.trim().isEmpty)
                            ? 'Enter driver name'
                            : null,
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _locationController,
                        decoration: _decoration(
                          label: 'Location',
                          icon: Icons.location_on_outlined,
                          hint: '',
                        ),
                        validator: (value) =>
                            (value == null || value.trim().isEmpty)
                            ? 'Enter location'
                            : null,
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _issueController,
                        maxLines: 4,
                        decoration: _decoration(
                          label: 'Issue Description',
                          icon: Icons.build_outlined,
                          hint: 'Describe what went wrong',
                        ).copyWith(alignLabelWithHint: true),
                        validator: (value) =>
                            (value == null || value.trim().isEmpty)
                            ? 'Describe the issue'
                            : null,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Save button
                SizedBox(
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: _isSubmitting ? null : _submit,
                    icon: _isSubmitting
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation(Colors.white),
                            ),
                          )
                        : const Icon(Icons.save_outlined),
                    label: Text(
                      _isSubmitting ? 'Saving...' : 'Save Breakdown',
                      style: const TextStyle(
                        fontSize: 15.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF0469B1),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 1,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
