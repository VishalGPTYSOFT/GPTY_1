class Category {
  final String categoryID;
  final String name; // nameEn
  final String imageID;
  final String slug;

  // Property to hold the actual image URL fetched separately (mutable)
  String? imageUrl;

  Category({
    required this.categoryID,
    required this.name,
    required this.imageID,
    required this.slug,
    this.imageUrl,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    // Safely parse the nested name object
    final nameJson = json['name'] as Map<String, dynamic>? ?? {};
    final String englishName = nameJson['nameEn'] as String? ?? 'Unnamed Category';

    return Category(
      categoryID: json['categoryID'] as String? ?? 'N/A',
      name: englishName,

      // CRITICAL: Ensure imageID is parsed correctly from the API response
      // Based on the full API data, this ID is directly under the category object.
      imageID: json['imageID'] as String? ?? '',
      slug: json['slug'] as String? ?? 'N/A',
    );
  }
}