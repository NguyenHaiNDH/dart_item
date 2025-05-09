import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart' show rootBundle; 
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import '../models/order_model.dart';

class OrderService {
  static const String _ordersKey = 'orders';
  static const String _fileName = 'orders.json';

  static Future<List<Order>> loadOrders() async {
    final prefs = await SharedPreferences.getInstance();
    final String? orderString = prefs.getString(_ordersKey);
    
    if (orderString == null) {
      // Đọc từ file assets/order.json
      final String initialData = await rootBundle.loadString('assets/order.json');
      final List<dynamic> jsonData = jsonDecode(initialData);
      final orders = jsonData.map((json) => Order.fromJson(json)).toList();
      await saveOrders(orders);
      return orders;
    } else {
      final List<dynamic> jsonData = jsonDecode(orderString);
      return jsonData.map((json) => Order.fromJson(json)).toList();
    }
  }

  static Future<void> saveOrders(List<Order> orders) async {
    final prefs = await SharedPreferences.getInstance();
    final String jsonString = jsonEncode(orders.map((order) => order.toJson()).toList());
    await prefs.setString(_ordersKey, jsonString);
    await saveOrdersToFile(orders);
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

  static Future<void> saveOrdersToFile(List<Order> orders) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$_fileName');
      final String jsonString = jsonEncode(orders.map((order) => order.toJson()).toList());
      await file.writeAsString(jsonString);
      print('Orders saved to ${file.path}');
    } catch (e) {
      print('Error saving file: $e');
    }
  }

  static void addOrder(List<Order> orders, Order newOrder) {
    orders.add(newOrder);
  }

  static void deleteOrder(List<Order> orders, String item) {
    orders.removeWhere((order) => order.item == item);
  }

  static List<Order> filterOrders(List<Order> orders, String query) {
    return orders
        .where((order) => order.itemName.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }
}