import 'package:flutter/material.dart';
import 'package:gpty_3/network/api_service.dart';
import 'package:gpty_3/models/product_model.dart';
import 'package:gpty_3/widgets/product_tile.dart';
import 'business_products_page.dart';
// import 'models/subcategory_model.dart';
// import 'models/product_category_model.dart';

// Note: Assuming Business and ProductFilter classes are defined elsewhere or at the top of this file.

// Model for businesses (Hypothetical, for the dropdown)
class Business {
  final String id;
  final String name;

  Business({required this.id, required this.name});
}

// Model to hold the state returned by the filter modal
class ProductFilter {
  final List<String> selectedBusinessIds;
  final List<String> selectedSubcategoryIds;
  final double minPrice;
  final double maxPrice;

  ProductFilter({
    required this.selectedBusinessIds,
    required this.selectedSubcategoryIds,
    required this.minPrice,
    required this.maxPrice,
  });
}


class CategoryDetailPage extends StatefulWidget {
  final String categoryId;
  final String categoryName;

  const CategoryDetailPage({
    super.key,
    required this.categoryId,
    required this.categoryName,
  });

  @override
  State<CategoryDetailPage> createState() => _CategoryDetailPageState();
}

class _CategoryDetailPageState extends State<CategoryDetailPage> {
  // State variables for filtering
  String searchText = "";
  final ApiService apiService = ApiService();
  Key _productFutureKey = UniqueKey();


  // Current active filters (These should be initialized from defaults)
  List<String> _activeBusinessIds = [];
  List<String> _activeSubcategoryIds = [];
  RangeValues _currentPriceRange = const RangeValues(10.0, 1000.0);
  final double _minPrice = 10.0;
  final double _maxPrice = 1000.0;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>(); // Key to open drawer

  @override
  void initState() {
    super.initState();
    // Initialize active filters here if needed, or rely on defaults above.
  }

  // Function to call when filter state changes (Search or Dropdown)
  void _onFilterChanged() {
    setState(() {
      _productFutureKey = UniqueKey(); // Trigger API call with new filters
    });
  }

  // --- NEW: Filter Content Widget (The actual UI for the Modal) ---
  Widget _buildFilterContent() {
    // --- Mocked Filter Data for UI ---
    final List<Map<String, String>> fAndBSubProductcategories = const [
      {'id': 'subProductCategoryID6ce85162-4001-4fcc-b026-baf075b3124c', 'name': 'Chicken Burgers'},
      {'id': 'subProductCategoryIDc65e5048-f0d9-4168-8f6c-36d853c3ecea', 'name': 'Boneless Chicken'},
      {'id': 'subProductCategoryIDd470ea8a-0678-4e16-98c7-5b1c3d3006ca', 'name': 'Fried Chicken'},
      {'id': 'subProductCategoryID7556cf34-efeb-4094-9fb6-42b51a578917', 'name': 'Wraps & Twisters'},
      {'id': 'subProductCategoryID4ec8fc08-d17e-4bb5-b10e-6810d691f82a', 'name': 'Hot Coffee'},
      {'id': 'subProductCategoryIDcbb765f4-54f6-4de5-86ed-c92b7e0f28e6', 'name': 'Cold Coffee'},
      {'id': 'subProductCategoryIDc1428a82-265c-415d-a9db-e4d46cd96913', 'name': 'Tea-Based Drinks'},
      {'id': 'subProductCategoryID2540afe3-4135-4b4c-b28c-3adb5cafd7a4', 'name': 'Other Beverages'},
    ];
    final List<Map<String, String>> businesses = const [
      {'id': 'business_67121cc5-b069-4735-8203-88e353fc9c4f', 'name': 'KFC'},
      {'id': 'business_5f7f2246-392e-4715-a838-fda8d3e989ac', 'name': 'Chicking'},
      {'id': 'business_15d3ee1d-29fd-4194-a9eb-7fd56523f76d', 'name': 'Coffee Shop'},
    ];
    final List<Map<String, String>> ProductCategory = const [
      {'id': 'category_00a44d5c-46a7-4d86-8858-0aee2176ff9f', 'name': 'Burgers & Sandwiches'},
      {'id': 'category_97fa8c09-e025-497e-846b-c3db2b84e938', 'name': 'Chicken Products'},
      {'id': 'category_b6fbd01b-04b4-490d-a8b6-047e9d19940d', 'name': 'Coffee Beverages'},
      {'id': 'category_4c1d6be3-f6a3-4bf3-aee9-6fd74b5b8967', 'name': 'Non-Coffee Beverages'},
    ];

    // Temporary local state for filter modifications
    Map<String, bool> tempBusinessSelection = Map.fromIterable(businesses, key: (b) => b['id'], value: (b) => _activeBusinessIds.contains(b['id']));
    Map<String, bool> tempSubcategorySelection = Map.fromIterable(fAndBSubProductcategories, key: (s) => s['id'], value: (s) => _activeSubcategoryIds.contains(s['id']));
    Map<String, bool> tempProductCategorySelection = Map.fromIterable(ProductCategory, key: (b) => b['id'], value: (b) => _activeBusinessIds.contains(b['id']));
    RangeValues tempPriceRange = _currentPriceRange;

    // We use a StateSetter to update the UI inside the modal, independently of the main page
    return StatefulBuilder(
      builder: (BuildContext context, StateSetter setStateModal) {
        return Container(
          // Ensure the drawer content is confined to the Scaffold
          width: MediaQuery.of(context).size.width * 0.8, // Drawer width
          color: Colors.grey.shade100, // Background color for the drawer content
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
                child: Text('Filter', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.indigo.shade600)),
              ),
              const Divider(height: 1),

              // --- FILTER SCROLLABLE BODY ---
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),

                      // --- 1. Business Filter ---
                      Text('Business/ Company', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey.shade700)),
                      const SizedBox(height: 8),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: businesses.length,
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 1, childAspectRatio: 4.5, crossAxisSpacing: 8), // One column for a clean drawer list
                        itemBuilder: (context, index) {
                          final business = businesses[index];
                          return CheckboxListTile(
                            title: Text(business['name']!, style: const TextStyle(fontSize: 14)),
                            value: tempBusinessSelection[business['id']],
                            onChanged: (bool? newValue) {
                              setStateModal(() {
                                tempBusinessSelection[business['id']!] = newValue ?? false;
                              });
                            },
                            controlAffinity: ListTileControlAffinity.leading,
                            contentPadding: EdgeInsets.zero,
                          );
                        },
                      ),
                      const Divider(height: 30),

                      // --- 2. Product Category Filter ---
                      Text('Product Category', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey.shade700)),
                      const SizedBox(height: 8),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: ProductCategory.length,
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 1, childAspectRatio: 4.5, crossAxisSpacing: 8), // One column for a clean drawer list
                        itemBuilder: (context, index) {
                          final sub = ProductCategory[index];
                          return CheckboxListTile(
                            title: Text(sub['name']!, style: const TextStyle(fontSize: 14)),
                            value: tempProductCategorySelection[sub['id']],
                            onChanged: (bool? newValue) {
                              setStateModal(() {
                                tempProductCategorySelection[sub['id']!] = newValue ?? false;
                              });
                            },
                            controlAffinity: ListTileControlAffinity.leading,
                            contentPadding: EdgeInsets.zero,
                          );
                        },
                      ),
                      const Divider(height: 30),

                      // --- 3. Subcategory Filter ---
                      Text('Sub Product Category', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey.shade700)),
                      const SizedBox(height: 8),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: fAndBSubProductcategories.length,
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 1, childAspectRatio: 4.5, crossAxisSpacing: 8), // One column for a clean drawer list
                        itemBuilder: (context, index) {
                          final sub = fAndBSubProductcategories[index];
                          return CheckboxListTile(
                            title: Text(sub['name']!, style: const TextStyle(fontSize: 14)),
                            value: tempSubcategorySelection[sub['id']],
                            onChanged: (bool? newValue) {
                              setStateModal(() {
                                tempSubcategorySelection[sub['id']!] = newValue ?? false;
                              });
                            },
                            controlAffinity: ListTileControlAffinity.leading,
                            contentPadding: EdgeInsets.zero,
                          );
                        },
                      ),
                      const Divider(height: 30),

                      // --- 3. Price Range Filter ---
                      Text('Price (RM)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey.shade700)),
                      const SizedBox(height: 8),
                      RangeSlider(
                        values: tempPriceRange,
                        min: _minPrice,
                        max: _maxPrice,
                        divisions: 100,
                        labels: RangeLabels(
                          'RM ${tempPriceRange.start.round()}',
                          'RM ${tempPriceRange.end.round()}',
                        ),
                        onChanged: (RangeValues newValues) {
                          setStateModal(() {
                            tempPriceRange = newValues;
                          });
                        },
                        activeColor: Colors.blue.shade600,
                        inactiveColor: Colors.blue.shade100,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('RM ${tempPriceRange.start.round()}', style: const TextStyle(fontSize: 12)),
                          Text('RM ${tempPriceRange.end.round()}', style: const TextStyle(fontSize: 12)),
                        ],
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),

              // --- APPLY FILTER BUTTON (Fixed to Bottom) ---
              Container(
                padding: const EdgeInsets.all(16.0),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [BoxShadow(color: Colors.grey.shade300, blurRadius: 5)],
                ),
                child: ElevatedButton(
                  onPressed: () {
                    // CRITICAL: Return the selected filters to the main page
                    final result = ProductFilter(
                      selectedBusinessIds: tempBusinessSelection.entries.where((e) => e.value).map((e) => e.key).toList(),
                      selectedSubcategoryIds: tempSubcategorySelection.entries.where((e) => e.value).map((e) => e.key).toList(),
                      minPrice: tempPriceRange.start,
                      maxPrice: tempPriceRange.end,
                    );
                    Navigator.pop(context, result);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo.shade700,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('FILTER', style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Function to fetch products based on current filters
  Future<List<Product>> _fetchFilteredProducts() {
    return apiService.filterProducts(
      categoryId: widget.categoryId,
      subCategoryIds: _activeSubcategoryIds,
      businessIds: _activeBusinessIds,
      searchName: searchText,
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey, // Attach key to Scaffold
      // --- APP BAR ---
      appBar: AppBar(
        title: RichText(
          text: TextSpan(
            style: const TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.normal),
            children: [
              TextSpan(
                text: 'CATEGORY',
                style: TextStyle(fontSize: 9.2, fontWeight: FontWeight.w900, color: Colors.grey.shade600, letterSpacing: 0.5),
              ),
              TextSpan(
                text: ' > ${widget.categoryName}',
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black),
              ),
            ],
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,

        // --- 1. BACK ARROW (LEFT SIDE) ---
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black54), // Back arrow icon
          onPressed: () => Navigator.of(context).pop(), // Standard navigation action
        ),

        actions: [
          // 2. LOGO AND USER ICON (Middle/Right)
          Image.asset('assets/images/logo.png', height: 40),
          IconButton(icon: const Icon(Icons.person, color: Colors.black54), onPressed: () {}),

          // 3. FILTER ICON / DRAWER TOGGLE (FAR RIGHT)
          IconButton(
            icon: const Icon(Icons.filter_list, color: Colors.indigo), // Filter icon
            onPressed: () => _scaffoldKey.currentState?.openEndDrawer(), // Open the drawer from the right
          ),
        ],
      ),

      // --- DRAWER (THE FILTER PANEL) ---
      endDrawer: Drawer( // Use endDrawer to make it slide from the right
        child: _buildFilterContent(),
      ),

      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- Search Bar Section ---
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Search Product...',
                        hintStyle: TextStyle(color: Colors.grey.shade500),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
                      ),
                      onChanged: (value) {
                        setState(() => searchText = value.toLowerCase()); // auto search
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 8.0),
                SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _onFilterChanged,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey.shade300,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                    ),
                    child: const Text('Search', style: TextStyle(color: Colors.black54)),
                  ),
                ),
              ],
            ),
          ),

          // --- Product Grid Section ---
          Expanded(
            child: FutureBuilder<List<Product>>(
              key: _productFutureKey,
              future: ApiService().fetchProductsByCategoryId(widget.categoryId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text("Error: ${snapshot.error}"));
                }

                final products = (snapshot.data ?? [])
                    .where((p) => p.title.toLowerCase().contains(searchText))  // Search product
                    .toList();

                return GridView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 7.0, vertical: 10.0),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10.0,
                    mainAxisSpacing: 10.0,
                    childAspectRatio: 0.8,
                  ),
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final product = products[index];
                    return InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => BusinessProductsPage(
                              productId: product.productID,
                            ),
                          ),
                        );
                      },
                      child: ProductTile(
                        title: product.title,
                        price: 'RM ${product.price.toStringAsFixed(2)}',
                        shop: product.shop,
                        imagePath: product.imageUrl,
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