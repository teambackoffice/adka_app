class MaterialRequestItem {
  String itemCode;
  int qty;
  double rate;
  String warehouse;

  MaterialRequestItem({
    required this.itemCode,
    required this.qty,
    required this.rate,
    required this.warehouse,
  });

  double get total => qty * rate;

  Map<String, dynamic> toJson() {
    return {
      'item_code': itemCode,
      'qty': qty,
      'rate': rate,
      'warehouse': warehouse,
    };
  }

  factory MaterialRequestItem.fromJson(Map<String, dynamic> json) {
    return MaterialRequestItem(
      itemCode: json['item_code'] ?? '',
      qty: (json['qty'] as num?)?.toInt() ?? 1,
      rate: (json['rate'] as num?)?.toDouble() ?? 0.0,
      warehouse: json['warehouse'] ?? '',
    );
  }

  MaterialRequestItem copyWith({
    String? itemCode,
    int? qty,
    double? rate,
    String? warehouse,
  }) {
    return MaterialRequestItem(
      itemCode: itemCode ?? this.itemCode,
      qty: qty ?? this.qty,
      rate: rate ?? this.rate,
      warehouse: warehouse ?? this.warehouse,
    );
  }
}

class MaterialRequest {
  final String id;
  String materialRequestType;
  String company;
  String setWarehouse;
  List<MaterialRequestItem> items;
  DateTime createdAt;

  MaterialRequest({
    required this.id,
    this.materialRequestType = 'Purchase',
    this.company = 'Al Sahel Medical College Supplies LLC',
    this.setWarehouse = 'Stores - ASMCSL',
    required this.items,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  double get grandTotal =>
      items.fold(0.0, (sum, item) => sum + (item.qty * item.rate));

  int get totalQuantity => items.fold(0, (sum, item) => sum + item.qty);

  Map<String, dynamic> toJson() {
    return {
      'material_request_type': materialRequestType,
      'company': company,
      'set_warehouse': setWarehouse,
      'items': items.map((e) => e.toJson()).toList(),
    };
  }
}
