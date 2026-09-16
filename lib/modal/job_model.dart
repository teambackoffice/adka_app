import 'material_request_model.dart';

class Job {
  final String id;
  final String vehicleName;
  final String vehicleNumber;
  final String serviceType;
  final String description;
  final String customerName;
  final String customerPhone;
  String status; // 'Pending', 'In Progress', 'Completed'
  final String dueDate;
  final String priority;
  final List<MaterialRequest> materialRequests;

  Job({
    required this.id,
    required this.vehicleName,
    required this.vehicleNumber,
    required this.serviceType,
    required this.description,
    required this.customerName,
    this.customerPhone = '+971 50 123 4567',
    required this.status,
    required this.dueDate,
    this.priority = 'Normal',
    List<MaterialRequest>? materialRequests,
  }) : materialRequests = materialRequests ?? [];

  Job copyWith({
    String? id,
    String? vehicleName,
    String? vehicleNumber,
    String? serviceType,
    String? description,
    String? customerName,
    String? customerPhone,
    String? status,
    String? dueDate,
    String? priority,
    List<MaterialRequest>? materialRequests,
  }) {
    return Job(
      id: id ?? this.id,
      vehicleName: vehicleName ?? this.vehicleName,
      vehicleNumber: vehicleNumber ?? this.vehicleNumber,
      serviceType: serviceType ?? this.serviceType,
      description: description ?? this.description,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      status: status ?? this.status,
      dueDate: dueDate ?? this.dueDate,
      priority: priority ?? this.priority,
      materialRequests: materialRequests ?? List.from(this.materialRequests),
    );
  }
}
