import 'package:flutter/material.dart';
import 'package:gpty_3/network/api_service.dart';
import 'package:gpty_3/models/product_model.dart';
import 'package:gpty_3/widgets/product_tile.dart';
import 'package:gpty_3/models/subcategory_model.dart';

// Model for businesses (Hypothetical, for the dropdown)
class Business {
  final String id;
  final String name;

  Business({required this.id, required this.name});
}


class SubCategoryDetailPage extends StatefulWidget {
  final String categoryId;
  final String categoryName;

  const SubCategoryDetailPage({
    super.key,
    required this.categoryId,
    required this.categoryName,
  });

  @override
  State<SubCategoryDetailPage> createState() => _SubCategoryDetailPageState();
}

class _SubCategoryDetailPageState extends State<SubCategoryDetailPage> {
  // State variables for filtering
  String? _selectedBusinessId;
  String? _selectedSubcategoryId;

  // Data sources
  List<Business> _businesses = [];
  // FINAL LIST OF SUBCATEGORIES FOR THE FILTER CHIPS (Hardcoded for structure validation)
  late List<Subcategory> _subcategories = [
    Subcategory(subCategoryID: '', name: 'All Subcategories', productCategoryID: ''),
    // F&B Related Subcategories derived from your API response examples:
    Subcategory(subCategoryID: 'subProductCategoryID6ce85162-4001-4fcc-b026-baf075b3124c', name: 'Chicken Burgers', productCategoryID: 'N/A'),
    Subcategory(subCategoryID: 'subProductCategoryID7556cf34-efeb-4094-9fb6-42b51a578917', name: 'Wraps & Twisters', productCategoryID: 'N/A'),
    Subcategory(subCategoryID: 'subProductCategoryIDc65e5048-f0d9-4168-8f6c-36d853c3ecea', name: 'Boneless Chicken', productCategoryID: 'N/A'),
    Subcategory(subCategoryID: 'subProductCategoryIDd470ea8a-0678-4e16-98c7-5b1c3d3006ca', name: 'Fried Chicken', productCategoryID: 'N/A'),
    Subcategory(subCategoryID: 'subProductCategoryID4ec8fc08-d17e-4bb5-b10e-6810d691f82a', name: 'Hot Coffee', productCategoryID: 'N/A'),
    Subcategory(subCategoryID: 'subProductCategoryIDcbb765f4-54f6-4de5-86ed-c92b7e0f28e6', name: 'Cold Coffee', productCategoryID: 'N/A'),
    Subcategory(subCategoryID: 'subProductCategoryIDc1428a82-265c-415d-9a6d-e4d46cd96913', name: 'Tea-Based Drinks', productCategoryID: 'N/A'),
    Subcategory(subCategoryID: 'subProductCategoryID2540afe3-4135-4b4c-b28c-3adb5cafd7a4', name: 'Other Beverages', productCategoryID: 'N/A'),
    // Note: The Hair/Body products ('Body Washes & Soaps', etc.) should only appear if the category is 'Beauty & Wellness'.
    // We assume this list is filtered by the API call in _loadInitialData in a production environment.
  ];

  final ApiService apiService = ApiService();
  Key _productFutureKey = UniqueKey(); // Key to force product grid reload

  @override
  void initState() {
    super.initState();
    // Simulate fetching business list once on load (In a real app, this would be an API call)
    _businesses = [
      Business(id: '', name: 'All Businesses'),
      Business(id: 'KFC_ID', name: 'KFC'),
      Business(id: 'COFFEE_ID', name: 'Coffee shop'),
    ];
    _selectedBusinessId = _businesses.first.id;
    _selectedSubcategoryId = _subcategories.first.subCategoryID; // Select "All Subcategories" initially
  }

  // Function to handle changes in the Business dropdown or Subcategory chip
  void _onFilterChanged(String? newSubcategoryId) {
    setState(() {
      if (newSubcategoryId != null) {
        _selectedSubcategoryId = newSubcategoryId;
      }
      _productFutureKey = UniqueKey(); // Trigger API refresh
    });
  }

  // Function to fetch products based on current filters
  Future<List<Product>> _fetchFilteredProducts() {
    // NOTE: This call must be updated to pass the subcategory ID to the API
    // if the backend supports filtering by subCategoryID.
    return apiService.fetchPopularProducts(
      categoryId: widget.categoryId,
      // subcategoryId: _selectedSubcategoryId, // Uncomment if API supports this filter
    );
  }

  // Widget to build the filter chips (Subcategories)
  Widget _buildSubcategoryChips() {
    if (_subcategories.isEmpty || _subcategories.length == 1) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      height: 45, // Increased height for better fit
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        itemCount: _subcategories.length,
        itemBuilder: (context, index) {
          final sub = _subcategories[index];
          final isSelected = sub.subCategoryID == _selectedSubcategoryId;

          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: FilterChip(
              label: Text(sub.name),
              selected: isSelected,
              showCheckmark: false,
              onSelected: (bool selected) {
                if (selected) {
                  _onFilterChanged(sub.subCategoryID);
                }
              },
              selectedColor: Colors.brown.shade100,
              backgroundColor: Colors.grey.shade200,
              labelStyle: TextStyle(
                color: isSelected ? Colors.brown : Colors.black,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              side: BorderSide(
                color: isSelected ? Colors.brown : Colors.grey.shade400,
                width: 1.0,
              ),
            ),
          );
        },
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('CATEGORY > ${widget.categoryName}'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          Image.asset('assets/images/logo.png', height: 40),
          IconButton(icon: const Icon(Icons.person, color: Colors.black54), onPressed: () {}),
          IconButton(icon: const Icon(Icons.menu, color: Colors.black54), onPressed: () {}),
        ],
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- Business Dropdown ---
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Container(
              width: 180,
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedBusinessId,
                  icon: const Icon(Icons.keyboard_arrow_down),
                  isExpanded: true,
                  items: _businesses.map((Business business) {
                    return DropdownMenuItem<String>(
                      value: business.id,
                      child: Text(business.name),
                    );
                  }).toList(),
                  onChanged: (newId) {
                    setState(() {
                      _selectedBusinessId = newId;
                      _onFilterChanged(null);
                    });
                  },
                ),
              ),
            ),
          ),

          // --- Subcategory Chips ---
          _buildSubcategoryChips(), // <-- DISPLAYS THE SUBCATEGORY CHIPS
          const SizedBox(height: 8.0),

          // --- Product Grid Section ---
          Expanded(
            child: FutureBuilder<List<Product>>(
              key: _productFutureKey,
              future: _fetchFilteredProducts(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'Data Error. Please check API connection and status.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.red.shade700),
                    ),
                  ));
                }

                final products = snapshot.data ?? [];

                // NOTE: If you implemented local filtering, you would filter 'products' here.

                if (products.isEmpty) {
                  return const Center(child: Text('No products found for this filter.'));
                }

                return GridView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10.0,
                    mainAxisSpacing: 10.0,
                    childAspectRatio: 0.75,
                  ),
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final product = products[index];
                    return ProductTile(
                      title: product.title,
                      price: 'RM ${product.price.toStringAsFixed(2)}',
                      shop: product.shop,
                      imagePath: product.imageUrl,
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