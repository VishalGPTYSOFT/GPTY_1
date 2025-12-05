import 'package:flutter/material.dart';
import 'package:gpty_3/widgets/collection_card.dart';
import 'package:gpty_3/widgets/product_tile.dart';
import 'package:gpty_3/network/api_service.dart';
import 'package:gpty_3/models/product_model.dart';
import 'package:gpty_3/models/category_model.dart';
import 'package:gpty_3/widgets/category_drawer.dart';
import 'category_detail_page.dart';
import 'business_products_page.dart';
// import 'package:gpty_3/models/category_item_model.dart';
// import 'business_category_products_page.dart';


class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});

  final ApiService apiService = ApiService();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>(); // Key to open drawer

  // Helper widget for section titles (Code remains the same)
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 20.0, bottom: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
              color: Colors.black87,
            ),
          ),
          const Divider(color: Colors.black, thickness: 1, indent: 0, endIndent: 250),
        ],
      ),
    );
  }

  // Helper widget for the horizontal list of categories (API Driven, Navigates)
  Widget _buildCategoryList() {
    return FutureBuilder<List<Category>>(
      future: apiService.fetchCategories(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(height: 120, child: Center(child: CircularProgressIndicator(strokeWidth: 2)));
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.red)));
        }

        final categories = snapshot.data ?? [];
        if (categories.isEmpty) {
          return const Center(child: Text('No categories available.'));
        }

        return SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.only(left: 16.0),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final item = categories[index];

              // --- Logic to select image source ---
              final bool useLocalAsset = index < 2;
              String imageSource;

              if (index == 0) {
                imageSource = 'assets/images/F&B.jpg'; // Local asset 1
              } else if (index == 1) {
                imageSource = 'assets/images/beauty and wellness.jpg'; // Local asset 2
              } else {
                imageSource = item.imageUrl ?? 'https://via.placeholder.com/100'; // Network URL for others
              }
              // --- End Logic ---

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CategoryDetailPage(
                        categoryId: item.categoryID,
                        categoryName: item.name,
                      ),
                    ),
                  );
                },
                child: Padding(
                  // FIX: Reduced right padding to 8.0 for stable horizontal spacing
                  padding: const EdgeInsets.only(right: 8.0),
                  child: SizedBox(
                    width: 106, // Fixed content width
                    child: Column(
                      children: [
                        Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: useLocalAsset
                                ? Image.asset(
                              imageSource,
                              height: 80,
                              width: 100,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => Container(
                                height: 80,
                                width: 100,
                                color: Colors.red[300],
                                child: const Center(child: Text('Asset Missing')),
                              ),
                            )
                                : Image.network(
                              imageSource,
                              height: 80,
                              width: 100,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => Container(
                                height: 80,
                                width: 100,
                                color: Colors.grey[300],
                                child: const Center(child: Icon(Icons.category)),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item.name,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  // Helper widget for the product grid (API Driven - NO LONGER FILTERED LOCALLY)
  Widget _buildProductGrid() {
    return FutureBuilder<List<Product>>(
      future: apiService.fetchPopularProducts(categoryId: null),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: Padding(
            padding: EdgeInsets.all(20.0),
            child: CircularProgressIndicator(),
          ));
        }
        if (snapshot.hasError) {
          return Center(child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text('Error loading products: ${snapshot.error}', textAlign: TextAlign.center),
          ));
        }

        final products = snapshot.data ?? [];

        if (products.isEmpty) {
          return const Center(child: Padding(
            padding: EdgeInsets.all(20.0),
            child: Text('No popular products available.'),
          ));
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10.0,
              mainAxisSpacing: 10.0,
              childAspectRatio: 0.75,
            ),
            itemCount: products.length,
            itemBuilder: (context, index) {
              final p = products[index];

              return GestureDetector( // <-- Wrap the ProductTile in GestureDetector
                onTap: () {
                  // CRITICAL NAVIGATION CHANGE: Push the detail page with the productID
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BusinessProductsPage(
                        productId: p.productID // Pass the unique ID
                      ),
                    ),
                  );
                },
                child: ProductTile(
                  title: p.title,
                  price: 'RM ${p.price.toStringAsFixed(2)}',
                  shop: p.shop,
                  imagePath: p.imageUrl,
                ),
              );
            },
          ),
        );
      },
    );
  }

  // MODIFIED WIDGET: Builds the top three collection cards from Category API data
  Widget _buildTopCollectionCardsFromCategories() {
    return FutureBuilder<List<Category>>(
      future: apiService.fetchCategories(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: Padding(
            padding: EdgeInsets.symmetric(vertical: 80.0),
            child: CircularProgressIndicator(strokeWidth: 2),
          ));
        }

        final categories = snapshot.data?.take(3).toList() ?? [];

        const List<Color> colors = [Color(0xFFC7E5E3), Color(0xFFD9F4D2), Color(0xFFF7D9D9)];
        const List<String> defaultTitles = ['New Collection Launch', 'Coffee Beverages', 'Skincare'];

        final List<Widget> collectionCards = List.generate(3, (index) {
          final isLaunchCard = index == 0;

          String title;
          String imagePath;
          String subtitle;

          if (index < categories.length) {
            final card = categories[index];
            title = card.name;
            imagePath = card.imageUrl ?? 'https://via.placeholder.com/300/CCCCCC?text=Image+Not+Found';
            subtitle = isLaunchCard ? 'Discover our latest arrivals' : '';
          } else {
            title = defaultTitles[index];
            imagePath = 'https://via.placeholder.com/300/CCCCCC?text=Fallback+${index+1}';
            subtitle = index == 0 ? 'Discover our latest arrivals' : '';
          }

          return CollectionCard(
            title: title,
            subtitle: subtitle,
            imagePath: imagePath,
            backgroundColor: colors[index],
            showCarouselDots: isLaunchCard,
            actionWidget: isLaunchCard
                ? OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.black87),
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
              ),
              child: const Text('SHOP NOW', style: TextStyle(color: Colors.black87)),
            )
                : TextButton(
              onPressed: () {},
              child: const Text('Shop Collection »', style: TextStyle(color: Colors.black87)),
            ),
          );
        });

        return Column(children: collectionCards);
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      // endDrawer: const CategoryDrawer(), // Use endDrawer for right-side drawer

      // CRITICAL FIX: The menu button on the HomeScreen should open the LEFT drawer (or a custom endDrawer)
      // Since your CategoryDrawer is defined to be used with the endDrawer property,
      // we'll keep the Scaffold logic simple.
      endDrawer: const CategoryDrawer(),

      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Image.asset('assets/images/logo.png', height: 40),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(icon: const Icon(Icons.person, color: Colors.black54), onPressed: () {}),
          IconButton(
            icon: const Icon(Icons.menu, color: Colors.black54),
            // Open the End Drawer when the Menu icon is pressed
            onPressed: () => _scaffoldKey.currentState?.openEndDrawer(),
          ),
        ],
      ),

      body: ListView(
        children: <Widget>[
          // --- 1. Top Collection Cards (FETCHED VIA CATEGORY API DATA) ---
          _buildTopCollectionCardsFromCategories(),

          const SizedBox(height: 10),

          // --- 2. CATEGORY Section (API Data) ---
          _buildSectionHeader('CATEGORY'),
          _buildCategoryList(), // <-- Navigates

          const SizedBox(height: 10),

          // --- 3. POPULAR PRODUCTS Section (API Data) ---
          _buildSectionHeader('POPULAR PRODUCTS'),
          _buildProductGrid(), // <-- Fetches ALL products

          const SizedBox(height: 26),
        ],
      ),
    );
  }
}