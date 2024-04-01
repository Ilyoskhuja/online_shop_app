import 'package:flutter/material.dart';
import 'widgets/product_list.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Online Shop App',
      home: Scaffold(
        appBar: AppBar(
          title: Text('Online Shop'),
        ),
        body: ProductList(),
       
      ),
    );
  }
}
