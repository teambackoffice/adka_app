import 'dart:convert';
import 'package:flutter/material.dart';
import '../../../modal/material_request_model.dart';

class CreateMaterialRequestPage extends StatefulWidget {
  final String jobTitle;
  final String vehicleName;

  const CreateMaterialRequestPage({
    super.key,
    required this.jobTitle,
    required this.vehicleName,
  });

  @override
  State<CreateMaterialRequestPage> createState() =>
      _CreateMaterialRequestPageState();
}

class _ItemEntry {
  final TextEditingController itemCodeController;
  final TextEditingController qtyController;
  final TextEditingController rateController;
  final TextEditingController warehouseController;

  _ItemEntry({
    required String itemCode,
    required int qty,
    required double rate,
    required String warehouse,
  }) : itemCodeController = TextEditingController(text: itemCode),
       qtyController = TextEditingController(text: qty.toString()),
       rateController = TextEditingController(
         text: rate == 0 ? '' : rate.toStringAsFixed(0),
       ),
       warehouseController = TextEditingController(text: warehouse);

  void dispose() {
    itemCodeController.dispose();
    qtyController.dispose();
    rateController.dispose();
    warehouseController.dispose();
  }
}

class _CreateMaterialRequestPageState extends State<CreateMaterialRequestPage> {
  final _formKey = GlobalKey<FormState>();

  String _selectedRequestType = 'Purchase';
  late final TextEditingController _companyController;
  late final TextEditingController _warehouseController;

  final List<String> _requestTypes = [
    'Purchase',
    'Material Transfer',
    'Material Issue',
    'Manufacture',
  ];

  final List<_ItemEntry> _items = [];

  final List<String> _commonItemSuggestions = [
    'ECG Machine',
    'Engine Oil 5W-40 Synthetic (1L)',
    'OEM Oil Filter',
    'Brake Pad Set (Front)',
    'Brake Pad Set (Rear)',
    'AC Refrigerant R134a',
    'Cabin Air Filter',
    '12V 65Ah Car Battery',
  ];

  @override
  void initState() {
    super.initState();
    _companyController = TextEditingController(
      text: 'Al Sahel Medical College Supplies LLC',
    );
    _warehouseController = TextEditingController(text: 'Stores - ASMCSL');

    // Add default item matching requirements
    _items.add(
      _ItemEntry(
        itemCode: 'ECG Machine',
        qty: 5,
        rate: 50000,
        warehouse: _warehouseController.text,
      ),
    );
  }

  @override
  void dispose() {
    _companyController.dispose();
    _warehouseController.dispose();
    for (final item in _items) {
      item.dispose();
    }
    super.dispose();
  }

  void _addItem() {
    setState(() {
      _items.add(
        _ItemEntry(
          itemCode: '',
          qty: 1,
          rate: 0,
          warehouse: _warehouseController.text,
        ),
      );
    });
  }

  void _removeItem(int index) {
    if (_items.length <= 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'At least one item is required in the material request.',
          ),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }
    setState(() {
      final removed = _items.removeAt(index);
      removed.dispose();
    });
  }

  double _calculateTotal() {
    double sum = 0;
    for (final item in _items) {
      final qty = int.tryParse(item.qtyController.text) ?? 0;
      final rate = double.tryParse(item.rateController.text) ?? 0.0;
      sum += (qty * rate);
    }
    return sum;
  }

  Map<String, dynamic> _buildPayload() {
    return {
      'material_request_type': _selectedRequestType,
      'company': _companyController.text.trim(),
      'set_warehouse': _warehouseController.text.trim(),
      'items': _items.map((entry) {
        final qty = int.tryParse(entry.qtyController.text) ?? 1;
        final rate = double.tryParse(entry.rateController.text) ?? 0.0;
        final warehouse = entry.warehouseController.text.trim().isNotEmpty
            ? entry.warehouseController.text.trim()
            : _warehouseController.text.trim();
        return {
          'item_code': entry.itemCodeController.text.trim(),
          'qty': qty,
          'rate': rate,
          'warehouse': warehouse,
        };
      }).toList(),
    };
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final requestItems = _items.map((entry) {
      final qty = int.tryParse(entry.qtyController.text) ?? 1;
      final rate = double.tryParse(entry.rateController.text) ?? 0.0;
      final warehouse = entry.warehouseController.text.trim().isNotEmpty
          ? entry.warehouseController.text.trim()
          : _warehouseController.text.trim();

      return MaterialRequestItem(
        itemCode: entry.itemCodeController.text.trim(),
        qty: qty,
        rate: rate,
        warehouse: warehouse,
      );
    }).toList();

    final newRequest = MaterialRequest(
      id: 'MR-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
      materialRequestType: _selectedRequestType,
      company: _companyController.text.trim(),
      setWarehouse: _warehouseController.text.trim(),
      items: requestItems,
      createdAt: DateTime.now(),
    );

    Navigator.pop(context, newRequest);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final total = _calculateTotal();

    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: AppBar(
        title: const Text(
          'Create Material Request',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
        ),
        elevation: 0,
        backgroundColor: scheme.surface,
        surfaceTintColor: Colors.transparent,
        actions: [],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
          children: [
            // Reference Work banner
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: scheme.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: scheme.primary.withValues(alpha: 0.20),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.directions_car_rounded,
                    color: scheme.primary,
                    size: 22,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.vehicleName,
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: scheme.primary,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          widget.jobTitle,
                          style: TextStyle(
                            color: scheme.onSurfaceVariant,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Request details header
            _sectionHeader(
              context,
              title: 'Request Details',
              icon: Icons.assignment_turned_in_rounded,
            ),
            const SizedBox(height: 12),

            // Material Request Type
            _fieldCard(
              scheme: scheme,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Material Request Type',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    initialValue: _selectedRequestType,
                    decoration: InputDecoration(
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    items: _requestTypes
                        .map(
                          (type) =>
                              DropdownMenuItem(value: type, child: Text(type)),
                        )
                        .toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setState(() => _selectedRequestType = val);
                      }
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Company
            _fieldCard(
              scheme: scheme,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Company',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _companyController,
                    decoration: InputDecoration(
                      hintText: 'Enter company name',
                      prefixIcon: const Icon(Icons.business_rounded, size: 20),
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'Company is required';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Set Warehouse
            _fieldCard(
              scheme: scheme,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Set Warehouse',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _warehouseController,
                    decoration: InputDecoration(
                      hintText: 'e.g. Stores - ASMCSL',
                      prefixIcon: const Icon(Icons.warehouse_rounded, size: 20),
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onChanged: (newWarehouse) {
                      // Update blank item warehouses
                      for (final item in _items) {
                        if (item.warehouseController.text.isEmpty) {
                          item.warehouseController.text = newWarehouse;
                        }
                      }
                    },
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'Warehouse is required';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Items Section Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _sectionHeader(
                  context,
                  title: 'Items (${_items.length})',
                  icon: Icons.inventory_2_rounded,
                ),
                TextButton.icon(
                  onPressed: _addItem,
                  icon: const Icon(Icons.add_rounded, size: 18),
                  label: const Text(
                    'Add Item',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Items list
            ...List.generate(_items.length, (index) {
              final item = _items[index];
              return _buildItemCard(context, item: item, index: index);
            }),

            const SizedBox(height: 8),

            // Summary & Create Request Section below items
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: scheme.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: scheme.outlineVariant.withValues(alpha: 0.45),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Estimated Total',
                            style: TextStyle(
                              fontSize: 12,
                              color: scheme.onSurfaceVariant,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '₹${total.toStringAsFixed(0)}',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: scheme.primary,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: scheme.primary.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${_items.length} ${_items.length == 1 ? "Item" : "Items"}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: scheme.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: _submit,
                    icon: const Icon(Icons.check_rounded, size: 20),
                    label: const Text(
                      'Create Request',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionHeader(
    BuildContext context, {
    required String title,
    required IconData icon,
  }) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Icon(icon, size: 18, color: scheme.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
        ),
      ],
    );
  }

  Widget _fieldCard({required ColorScheme scheme, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: scheme.outlineVariant.withValues(alpha: 0.45),
        ),
      ),
      child: child,
    );
  }

  Widget _buildItemCard(
    BuildContext context, {
    required _ItemEntry item,
    required int index,
  }) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: scheme.outlineVariant.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Item card header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: scheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Item #${index + 1}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: scheme.primary,
                  ),
                ),
              ),
              const Spacer(),
              if (_items.length > 1)
                IconButton(
                  visualDensity: VisualDensity.compact,
                  icon: Icon(
                    Icons.delete_outline_rounded,
                    color: scheme.error,
                    size: 20,
                  ),
                  tooltip: 'Remove item',
                  onPressed: () => _removeItem(index),
                ),
            ],
          ),
          const SizedBox(height: 12),

          // Item Code
          Text(
            'Item Code / Name',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: scheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 6),
          Autocomplete<String>(
            initialValue: TextEditingValue(text: item.itemCodeController.text),
            optionsBuilder: (textEditingValue) {
              if (textEditingValue.text.isEmpty) {
                return _commonItemSuggestions;
              }
              return _commonItemSuggestions.where(
                (option) => option.toLowerCase().contains(
                  textEditingValue.text.toLowerCase(),
                ),
              );
            },
            onSelected: (selection) {
              item.itemCodeController.text = selection;
              setState(() {});
            },
            fieldViewBuilder:
                (context, textEditingController, focusNode, onFieldSubmitted) {
                  // keep sync
                  textEditingController.addListener(() {
                    item.itemCodeController.text = textEditingController.text;
                  });

                  return TextFormField(
                    controller: textEditingController,
                    focusNode: focusNode,
                    decoration: InputDecoration(
                      hintText: 'e.g. ECG Machine, Engine Oil, Brake Pads',
                      prefixIcon: const Icon(Icons.category_rounded, size: 20),
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'Item code is required';
                      }
                      return null;
                    },
                  );
                },
          ),

          const SizedBox(height: 12),

          // Qty and Rate row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Quantity
              Expanded(
                flex: 4,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Quantity',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: item.qtyController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: '1',
                        prefixIcon: const Icon(Icons.tag_rounded, size: 18),
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onChanged: (val) => setState(() {}),
                      validator: (val) {
                        final parsed = int.tryParse(val ?? '');
                        if (parsed == null || parsed <= 0) {
                          return 'Min 1';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),

              // Rate
              Expanded(
                flex: 5,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Rate / Unit',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: item.rateController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: InputDecoration(
                        hintText: '0.00',
                        prefixIcon: const Icon(
                          Icons.currency_rupee_rounded,
                          size: 18,
                        ),
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onChanged: (val) => setState(() {}),
                      validator: (val) {
                        final parsed = double.tryParse(val ?? '');
                        if (parsed == null || parsed < 0) {
                          return 'Invalid rate';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Warehouse for item
          Text(
            'Item Warehouse',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: scheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: item.warehouseController,
            decoration: InputDecoration(
              hintText: 'Warehouse',
              prefixIcon: const Icon(
                Icons.store_mall_directory_rounded,
                size: 18,
              ),
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 12,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            validator: (val) {
              if (val == null || val.trim().isEmpty) {
                return 'Warehouse is required';
              }
              return null;
            },
          ),

          const SizedBox(height: 10),

          // Line total
          Builder(
            builder: (context) {
              final qty = int.tryParse(item.qtyController.text) ?? 0;
              final rate = double.tryParse(item.rateController.text) ?? 0.0;
              final lineTotal = qty * rate;

              return Align(
                alignment: Alignment.centerRight,
                child: Text(
                  'Item Total: ₹${lineTotal.toStringAsFixed(0)}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: scheme.primary,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
