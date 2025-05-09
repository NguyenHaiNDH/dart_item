import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';
import '../models/order_model.dart';

class OrderService {
  static const String _fileName = 'order.json'; 

  static Future<List<Order>> loadOrders() async {
    try {
      
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$_fileName');

      
      if (await file.exists()) {
        final String content = await file.readAsString();
        final List<dynamic> jsonData = jsonDecode(content);
        return jsonData.map((json) => Order.fromJson(json)).toList();
      } else {
        
        final String initialData = await rootBundle.loadString('assets/order.json');
        final List<dynamic> jsonData = jsonDecode(initialData);
        final orders = jsonData.map((json) => Order.fromJson(json)).toList();
        // Lưu vào file trong thư mục lưu trữ
        await saveOrders(orders);
        return orders;
      }
    } catch (e) {
      print('Error loading orders: $e');
      return [];
    }
  }

  static Future<void> saveOrders(List<Order> orders) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$_fileName');
      final String jsonString = jsonEncode(orders.map((order) => order.toJson()).toList());
      await file.writeAsString(jsonString);
      print('Orders saved to ${file.path}');
    } catch (e) {
      print('Error saving orders: $e');
    }
  }

  static Future<List<Order>> loadOrdersFromFile(String filePath) async {
    try {
      final file = File(filePath);
      final String content = await file.readAsString();
      final List<dynamic> jsonData = jsonDecode(content);
      return jsonData.map((json) => Order.fromJson(json)).toList();
    } catch (e) {
      print('Error reading file: $e');
      return [];
    }
  }

  static void addOrder(List<Order> orders, Order newOrder) {
    orders.add(newOrder);
  }

  static void deleteOrder(List<Order> orders, String item) {
    orders.removeWhere((order) => order.item == item);
  }

  static void updateOrder(List<Order> orders, String item, Order updatedOrder) {
    final index = orders.indexWhere((order) => order.item == item);
    if (index != -1) {
      orders[index] = updatedOrder;
    }
  }

  static List<Order> filterOrders(List<Order> orders, String query) {
    return orders
        .where((order) => order.itemName.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }
}