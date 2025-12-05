import 'package:flutter/material.dart';
import 'package:gpty_3/pages/landing_page.dart';
import 'package:gpty_3/pages/business_category_products_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const LandingPage(),
      
      routes: {
        "/category-products": (context) => const BusinessCategoryProductsPage(
          categoryId: "",
          categoryName: "",
        ),
      },
    );
  }
}