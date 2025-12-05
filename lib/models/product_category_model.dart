class ProductCategory {
  final String categoryID;
  final String name;

  ProductCategory({required this.categoryID, required this.name});

  factory ProductCategory.fromJson(Map<String, dynamic> json) {
    final nameJson = json['name'] as Map<String, dynamic>? ?? {};
    final String englishName = nameJson['nameEn'] as String? ?? 'Unnamed Category';

    return ProductCategory(
      categoryID: json['categoryID'] as String? ?? 'N/A',
      name: englishName,
    );
  }
}