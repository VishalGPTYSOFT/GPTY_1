import 'package:flutter/material.dart';
import 'package:gpty_3/network/api_service.dart';
import 'package:gpty_3/pages/business_category_products_page.dart';
import 'package:gpty_3/models/category_item_model.dart';
// import 'package:gpty_3/business_page.dart';
// import 'package:gpty_3/models/business_model.dart';

class CategoryDrawer extends StatefulWidget {
  const CategoryDrawer({super.key});

  @override
  State<CategoryDrawer> createState() => _CategoryDrawerState();
}

class _CategoryDrawerState extends State<CategoryDrawer> {
  String searchText = "";
  final ApiService apiService = ApiService(); // Use instance of ApiService

  // Method to fetch data using the API you specified in the prompt
  Future<List<CategoryItem>> _fetchAndParseBusinessCategories() async {
    final response = await apiService.fetchBusinessCategoriesAPI(); // Call the API service method

    // Assuming fetchBusinessCategoriesAPI returns List<CategoryItem>
    return response;
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.grey[100],
      child: Column(
        children: [
          // --- TOP HEADER DESIGN ---
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(left: 20, top: 55, bottom: 20),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF4C70FF), Color(0xFF6C8BFF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: const Text(
              "Business Category",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
            ),
          ),

          // --- SEARCH BAR ---
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            child: TextField(
              onChanged: (value) {
                setState(() => searchText = value.toLowerCase());
              },
              decoration: InputDecoration(
                hintText: "Search category...",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 5),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // --- CATEGORY LIST ---
          Expanded(
            child: FutureBuilder<List<CategoryItem>>(
              future: _fetchAndParseBusinessCategories(), // Use the instance method
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text("Error: ${snapshot.error}"));
                }

                final categories = snapshot.data ?? [];

                // --- Apply Search Filter ---
                final filtered = categories
                    .where((c) => c.name.toLowerCase().contains(searchText))
                    .toList();

                return ListView.separated(
                  padding: const EdgeInsets.all(15),
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final item = filtered[index];

                    return Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          Navigator.pop(context); // Close drawer

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => BusinessCategoryProductsPage(
                                categoryId: item.id,
                                categoryName: item.name,
                              ),
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 15),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade50,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(
                                  Icons.category,
                                  color: Color(0xFF4C70FF),
                                ),
                              ),
                              const SizedBox(width: 15),

                              // Category Name
                              Expanded(
                                child: Text(
                                  item.name,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),

                              const Icon(Icons.arrow_forward_ios, size: 14),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}