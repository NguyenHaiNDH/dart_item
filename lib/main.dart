import 'package:flutter/material.dart';
import 'screens/order_screen.dart'; 

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Đơn Hàng Của Tôi',
      theme: ThemeData(
        primarySwatch: Colors.brown,
      ),
      home: OrderScreen(),
    );
  }
}