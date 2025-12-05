import 'package:flutter/material.dart';
import 'package:gpty_3/network/api_service.dart';
import 'package:gpty_3/models/product_model.dart';

class BusinessProductsPage extends StatefulWidget {
  final String productId;

  const BusinessProductsPage({
    super.key,
    required this.productId,
  });

  @override
  State<BusinessProductsPage> createState() => _BusinessProductsPageState();
}

class _BusinessProductsPageState extends State<BusinessProductsPage>
    with SingleTickerProviderStateMixin {
  final ApiService apiService = ApiService();
  late Future<Product?> _productFuture;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _productFuture = _fetchDetails(widget.productId);
    _tabController = TabController(length: 4, vsync: this);
  }

  Future<Product?> _fetchDetails(String id) async {
    try {
      final all = await apiService.fetchPopularProducts(categoryId: null);
      return all.firstWhere((p) => p.productID == id);
    } catch (e) {
      return null;
    }
  }

  Widget _labelBlock(String label) => Text(
    label,
    style: const TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w700,
    ),
  );

  Widget _youMayAlsoLike(List<Product> all) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "You Might Also Like",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 15),

        SizedBox(
          height: 220,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: all.length,
            separatorBuilder: (_, __) => const SizedBox(width: 14),
            itemBuilder: (context, index) {
              final p = all[index];
              return GestureDetector(
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BusinessProductsPage(productId: p.productID),
                    ),
                  );
                },
                child: SizedBox(
                  width: 160,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          p.imageUrl,
                          height: 120,
                          width: 160,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        p.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        "RM ${p.price.toStringAsFixed(2)}",
                        style: const TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold),
                      ),
                      Text(
                        p.shop,
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      )
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,

      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        color: Colors.white,
        child: ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green.shade700,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text(
            "Contact Seller",
            style: TextStyle(fontSize: 18, color: Colors.white),
          ),
        ),
      ),

      body: FutureBuilder<Product?>(
        future: _productFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final product = snapshot.data!;

          return FutureBuilder<List<Product>>(
            future: apiService.fetchPopularProducts(categoryId: null),
            builder: (context, smp) {
              final similar = smp.data ?? [];

              return DefaultTabController(
                length: 4,
                child: NestedScrollView(
                  headerSliverBuilder: (context, inner) => [
                    SliverAppBar(
                      expandedHeight: 300,
                      pinned: true,
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,

                      flexibleSpace: FlexibleSpaceBar(
                        background: Image.network(
                          product.imageUrl,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),

                    // PRODUCT TITLE + PRICE CARD
                    SliverToBoxAdapter(
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        color: Colors.white,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product.title,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 12),

                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.green.shade600,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                "RM ${product.price.toStringAsFixed(2)}",
                                style: const TextStyle(
                                  fontSize: 20,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),

                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ),

                    // TABS
                    SliverPersistentHeader(
                      pinned: true,
                      delegate: _TabBarDelegate(
                        TabBar(
                          controller: _tabController,
                          labelColor: Colors.indigo,
                          unselectedLabelColor: Colors.black54,
                          indicatorColor: Colors.indigo,
                          tabs: const [
                            Tab(text: "Description"),
                            Tab(text: "Offers"),
                            Tab(text: "Comments"),
                            Tab(text: "Shop Info"),
                          ],
                        ),
                      ),
                    ),
                  ],

                  body: TabBarView(
                    controller: _tabController,
                    children: [
                      // DESCRIPTION TAB
                      SingleChildScrollView(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _labelBlock("Description"),
                            const SizedBox(height: 8),
                            Text(
                              product.description,
                              style: const TextStyle(fontSize: 15, height: 1.4),
                            ),

                            const SizedBox(height: 20),
                            _labelBlock("Specifications"),
                            const SizedBox(height: 10),
                            _infoBox(product),

                            const SizedBox(height: 20),
                            _labelBlock("Properties"),
                            _propertiesBox(),

                            const SizedBox(height: 25),
                            _youMayAlsoLike(similar),
                            const SizedBox(height: 60),
                          ],
                        ),
                      ),

                      // OFFERS TAB
                      const Center(child: Text("No offers available.")),

                      // COMMENTS TAB
                      const Center(child: Text("No comments yet.")),

                      // SHOP INFO TAB
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Text(
                          product.shop,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _infoBox(Product p) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          _row("Category", p.categoryName),
          _row("Sub-Category", p.subCategoryName),
          _row("Business", p.shop),
        ],
      ),
    );
  }

  Widget _row(String left, String right) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          SizedBox(width: 120, child: Text(left)),
          Expanded(child: Text(right)),
        ],
      ),
    );
  }

  Widget _propertiesBox() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Text("Property descriptions"),
    );
  }
}

// ---------------------------- TAB BAR FIXED HEADER ----------------------------

class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;

  _TabBarDelegate(this.tabBar);

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Colors.white,
      child: tabBar,
    );
  }

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  bool shouldRebuild(_TabBarDelegate oldDelegate) {
    return false;
  }
}
