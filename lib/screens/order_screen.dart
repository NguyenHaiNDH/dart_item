import 'package:flutter/material.dart';
import '../models/order_model.dart'; 
import '../services/order_service.dart'; 

class OrderScreen extends StatefulWidget {
  @override
  _OrderScreenState createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  List<Order> orders = [];
  List<Order> filteredOrders = [];
  final TextEditingController _itemController = TextEditingController();
  final TextEditingController _itemNameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _currencyController = TextEditingController(text: 'USD');
  final TextEditingController _quantityController = TextEditingController(text: '1');
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadOrders();
    _searchController.addListener(_filterOrders);
  }

  Future<void> _loadOrders() async {
    orders = await OrderService.loadOrders();
    filteredOrders = List.from(orders);
    setState(() {});
  }

  void _addOrder() {
    if (_itemController.text.isEmpty || _itemNameController.text.isEmpty || _priceController.text.isEmpty) {
      return;
    }

    final newOrder = Order(
      item: _itemController.text,
      itemName: _itemNameController.text,
      price: double.parse(_priceController.text),
      currency: _currencyController.text,
      quantity: int.parse(_quantityController.text),
    );

    OrderService.addOrder(orders, newOrder);
    OrderService.saveOrders(orders);
    setState(() {
      filteredOrders = List.from(orders);
      _clearInputs();
    });
  }

  void _deleteOrder(String item) {
    OrderService.deleteOrder(orders, item);
    OrderService.saveOrders(orders);
    setState(() {
      filteredOrders = List.from(orders);
    });
  }

  void _filterOrders() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      filteredOrders = OrderService.filterOrders(orders, query);
    });
  }

  void _clearInputs() {
    _itemController.clear();
    _itemNameController.clear();
    _priceController.clear();
    _currencyController.text = 'USD';
    _quantityController.text = '1';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Đơn Hàng Của Tôi', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.orange,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(child: TextField(controller: _itemController, decoration: InputDecoration(labelText: 'Mã sản phẩm'))),
                SizedBox(width: 10),
                Expanded(child: TextField(controller: _itemNameController, decoration: InputDecoration(labelText: 'Tên sản phẩm'))),
              ],
            ),
            Row(
              children: [
                Expanded(child: TextField(controller: _priceController, decoration: InputDecoration(labelText: 'Giá'), keyboardType: TextInputType.number)),
                SizedBox(width: 10),
                Expanded(child: TextField(controller: _currencyController, decoration: InputDecoration(labelText: 'Tiền tệ'))),
                SizedBox(width: 10),
                Expanded(child: TextField(controller: _quantityController, decoration: InputDecoration(labelText: 'Số lượng'), keyboardType: TextInputType.number)),
              ],
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: _addOrder,
              child: Text('Thêm vào giỏ hàng'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, foregroundColor: Colors.white),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Tìm kiếm theo tên sản phẩm',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: SingleChildScrollView(
                child: DataTable(
                  columns: [
                    DataColumn(label: Text('STT')),
                    DataColumn(label: Text('Mã')),
                    DataColumn(label: Text('Tên sản phẩm')),
                    DataColumn(label: Text('Giá')),
                    DataColumn(label: Text('Tiền tệ')),
                    DataColumn(label: Text('Hành động')),
                  ],
                  rows: filteredOrders
                      .asMap()
                      .entries
                      .map(
                        (entry) => DataRow(
                          cells: [
                            DataCell(Text((entry.key + 1).toString())),
                            DataCell(Text(entry.value.item)),
                            DataCell(Text(entry.value.itemName)),
                            DataCell(Text(entry.value.price.toString())),
                            DataCell(Text(entry.value.currency)),
                            DataCell(
                              IconButton(
                                icon: Icon(Icons.delete),
                                onPressed: () => _deleteOrder(entry.value.item),
                              ),
                            ),
                          ],
                        ),
                      )
                      .toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}