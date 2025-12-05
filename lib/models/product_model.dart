class Product {
  final String productID;
  final String title;
  final String description;
  final String categoryID;
  final String categoryName;
  final String subCategoryName;

  final int price;
  final String shop;
  final String imageID;
  final String imageUrl;

  Product({
    required this.productID,
    required this.title,
    required this.description,
    required this.categoryID,
    required this.categoryName,
    required this.subCategoryName,
    required this.price,
    required this.shop,
    required this.imageID,
    required this.imageUrl,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    // SAFELY extract product name
    final productData = json['product'] as Map<String, dynamic>? ?? {};
    final nameJson = productData['name'] as Map<String, dynamic>? ?? {};
    final String englishName = nameJson['nameEn'] as String? ?? 'Unnamed Product';

    // SAFELY extract business info
    final businessData = json['business'] as Map<String, dynamic>? ?? {};
    final businessCategoryData = businessData['category'] as Map<String, dynamic>? ?? {};

    // SAFELY extract business category Name info
    final business = json['business'] as Map<String, dynamic>? ?? {};
    final category = business['category'] as Map<String, dynamic>? ?? {};
    final nameObj = category['name'] as Map<String, dynamic>? ?? {};
    final String cEnglishName = nameObj['nameEn'] as String? ?? 'Unnamed Category';

    // SAFELY extract business sub category Name info
    final product = json['product'] as Map<String, dynamic>? ?? {};
    final subCategories = product['subCategory'] as List<dynamic>? ?? [];
    final firstSub = subCategories.isNotEmpty
        ? subCategories.first as Map<String, dynamic>
        : {};
    final eNameObj = firstSub['name'] as Map<String, dynamic>? ?? {};
    final String subEnglishName = eNameObj['nameEn'] as String? ?? 'Unnamed Subcategory';

    // SAFELY extract business product description info
    final String descr = json['business_product_desc'] as String? ?? 'No description available';

    // SAFELY extract image info
    final imageData = json['image'] as Map<String, dynamic>? ?? {};
    final List<dynamic> urls = imageData['urls'] as List<dynamic>? ?? [];

    // FIX: Accept price as int or string
    int parsedPrice = 0;
    if (json['price'] is int) {
      parsedPrice = json['price'];
    } else if (json['price'] is String) {
      parsedPrice = int.tryParse(json['price']) ?? 0;
    }

    return Product(
      productID: json['businessProductID'] as String? ?? 'N/A',
      title: englishName,
      description: descr,
      categoryID: businessCategoryData['categoryID'] as String? ?? 'N/A',
      categoryName: cEnglishName,
      subCategoryName: subEnglishName,
      imageID: imageData['imageID'] as String? ?? '',
      price: parsedPrice,
      shop: businessData['name'] as String? ?? 'No Shop Info',
      imageUrl: urls.isNotEmpty ? urls.first : 'https://via.placeholder.com/200',
    );
  }
}