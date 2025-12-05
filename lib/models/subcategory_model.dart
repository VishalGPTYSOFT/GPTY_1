// lib/subcategory_model.dart (Final Code)

class Subcategory {
  final String subCategoryID;
  final String name; // nameEn
  final String productCategoryID; // For tracking the parent category

  Subcategory({
    required this.subCategoryID,
    required this.name,
    required this.productCategoryID,
  });

  factory Subcategory.fromJson(Map<String, dynamic> json) {
    // Safely parse the nested name object
    final nameJson = json['name'] as Map<String, dynamic>? ?? {};
    final String englishName = nameJson['nameEn'] as String? ?? 'Unnamed Subcategory';

    return Subcategory(
      subCategoryID: json['subCategoryID'] as String? ?? 'N/A',
      name: englishName,
      // NOTE: Adjust 'productCategoryID' if the API returns the parent ID under a different key
      productCategoryID: json['productCategoryID'] as String? ?? 'N/A',
    );
  }
}