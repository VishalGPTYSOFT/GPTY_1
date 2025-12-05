import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:gpty_3/models/product_model.dart';
import 'package:gpty_3/models/category_model.dart';
import 'package:gpty_3/models/subcategory_model.dart';
import 'package:gpty_3/models/business_model.dart';
import 'package:gpty_3/models/product_category_model.dart';
import 'package:gpty_3/models/category_item_model.dart';

class ApiService {
  static const String baseUrl = 'https://kl-brickfield-api-578481271013.asia-southeast1.run.app';

  // --- API Key Configuration ---
  static const String _apiKey = '123456789';
  static const String _apiKeyHeaderName = 'X-API-Key';

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    _apiKeyHeaderName: _apiKey,
  };
  // -----------------------------

  // Helper function to extract List from nested Map (Crucial Fix for Map-to-List errors)
  List<dynamic>? _extractListFromResponse(String responseBody, String listKey) {
    try {
      if (!responseBody.trim().startsWith('{') && !responseBody.trim().startsWith('[')) {
        // This handles the HTML error (FormatException)
        print('API Response Error: Server returned non-JSON data.');
        return null;
      }

      final Map<String, dynamic> jsonResponse = jsonDecode(responseBody);
      final dynamic responseObject = jsonResponse['responseObject'];

      if (responseObject is List) {
        return responseObject;
      }

      if (responseObject is Map) {
        return responseObject[listKey] as List<dynamic>?;
      }

      return null;
    } catch (e) {
      print('JSON Decoding Error: $e');
      return null;
    }
  }


  // Function to fetch products
  Future<List<Product>> fetchPopularProducts({String? categoryId}) async {
    String url = '$baseUrl/api/v1/BusinessProduct';

    if (categoryId != null && categoryId.isNotEmpty) {
      url += '?business_categoryID=$categoryId';
    }

    final response = await http.get(Uri.parse(url), headers: _headers);

    if (response.statusCode == 200) {
      if (!response.body.trim().startsWith('{') && !response.body.trim().startsWith('[')) {
        throw const FormatException('Server returned non-JSON data. Check backend logs.');
      }

      final Map<String, dynamic> jsonResponse = jsonDecode(response.body);

      final List<dynamic>? finalDataList = _extractListFromResponse(response.body, 'products');

      if (finalDataList != null) {
        final List<Product> products = finalDataList.map((json) => Product.fromJson(json)).toList();

        await Future.wait(products.map((p) async {
          if (p.productID.isNotEmpty) {

            final String imageUrl = await fetchImageUrl(p.imageID);

            final int index = products.indexOf(p);
            if (index != -1) {
              products[index] = Product(
                productID: p.productID,
                title: p.title,
                description: p.description,
                categoryID: p.categoryID,
                categoryName: p.categoryName,
                subCategoryName: p.subCategoryName,
                price: p.price,
                shop: p.shop,
                imageID: p.imageID,
                imageUrl: p.imageUrl,
              );
            }
          }
        }).toList());

        return products;
      } else {
        throw Exception('API response missing the data array. (Checked key: "responseObject")');
      }

    } else {
      if (response.statusCode == 401) {
        throw Exception('Authentication Failed: API Key is invalid or missing.');
      }
      throw Exception('Failed to load products. Status Code: ${response.statusCode}');
    }
  }

  Future<List<dynamic>> fetchBusinessProduct() async {
    final response = await http.get(Uri.parse("$baseUrl/api/v1/BusinessProduct"));

    if (response.statusCode == 200) {
      final parsed = jsonDecode(response.body);
      return parsed["responseObject"];
    } else {
      throw Exception("Failed to fetch BusinessProduct");
    }
  }


  // Fetch products by Business Category ID
  Future<List<Product>> fetchProductsByCategoryId(String categoryId) async {
    final url = "$baseUrl/api/v1/BusinessProduct";

    final response = await http.get(Uri.parse(url), headers: _headers);

    if (response.statusCode != 200) {
      throw Exception("Failed to load products: ${response.statusCode}");
    }

    final decoded = jsonDecode(response.body);
    final List<dynamic> items = decoded["responseObject"] ?? [];

    // Filter by business → category → categoryID
    final filtered = items.where((e) {
      final business = e["business"];
      final category = business?["category"];
      return category?["categoryID"] == categoryId;
    }).toList();

    // Convert to Product model
    return filtered.map((e) => Product.fromJson(e)).toList();
  }

  // GET BUSINESS BY SLUG
  // Get business list (for drawer / lists / UI)
  Future<List<Business>> fetchBusinesses() async {
    final res = await http.get(
      Uri.parse('$baseUrl/api/v1/business'),
      headers: _headers,
    );

    if (res.statusCode != 200) return [];

    final json = jsonDecode(res.body);

    final List<dynamic> list = json['responseObject']['businesses'] as List<dynamic>;
    return list.map((e) => Business.fromJson(e)).toList();
  }

// Get business details by slug
  Future<Business> getBusinessBySlug(String slug) async {
    final res = await http.get(
      Uri.parse('$baseUrl/api/v1/business/$slug'),
      headers: _headers,
    );

    final json = jsonDecode(res.body);
    return Business.fromJson(json['responseObject']);
  }

  // Get all business list (same as fetchBusinesses but named for clarity)
  Future<List<Business>> getAllBusinesses() async {
    final res = await http.get(
      Uri.parse('$baseUrl/api/v1/business'),
      headers: _headers,
    );

    final json = jsonDecode(res.body);
    final List<dynamic> list = json['responseObject']['businesses'] as List<dynamic>;
    return list.map((e) => Business.fromJson(e)).toList();
  }

  Future<Business?> fetchBusinessByName(String name) async {
    final businesses = await fetchBusinesses(); // your existing function
    try {
      return businesses.firstWhere(
            (b) => b.name.toLowerCase() == name.toLowerCase(),
      );
    } catch (e) {
      return null;
    }
  }

  Future<List<Product>> fetchProductsByBusinessCategory(String categoryId) async {
    final url = '$baseUrl/api/v1/BusinessProduct?business_categoryID=$categoryId';

    final response = await http.get(
      Uri.parse(url),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
      final List<dynamic> data = jsonResponse['responseObject'];

      List<Product> products = data.map((json) => Product.fromJson(json)).toList();

      // Fetch image URLs one by one
      for (int i = 0; i < products.length; i++) {
        if (products[i].imageID.isNotEmpty) {
          final url = await fetchImageUrl(products[i].imageID);
          products[i] = Product(
            productID: products[i].productID,
            title: products[i].title,
            description: products[i].description,
            categoryID: products[i].categoryID,
            categoryName: products[i].categoryName,
            subCategoryName: products[i].subCategoryName,
            price: products[i].price,
            shop: products[i].shop,
            imageID: products[i].imageID,
            imageUrl: url,
          );
        }
      }

      return products;
    } else {
      throw Exception('Failed to fetch category products');
    }
  }


  // Function to fetch categories (Used by horizontal list)
  Future<List<Category>> fetchCategories() async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/v1/business/categories'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      if (!response.body.trim().startsWith('{') && !response.body.trim().startsWith('[')) {
        throw const FormatException('Server returned non-JSON data for categories.');
      }

      final Map<String, dynamic> jsonResponse = jsonDecode(response.body);

      final List<dynamic>? finalDataList = _extractListFromResponse(response.body, 'categories');

      if (finalDataList != null) {
        final List<Category> categories = finalDataList.map((json) => Category.fromJson(json)).toList();

        await Future.wait(categories.map((c) async {
          if (c.imageID.isNotEmpty) {
            c.imageUrl = await fetchImageUrl(c.imageID);
          }
        }).toList());

        return categories;
      } else {
        throw Exception('API response missing the data array. (Expected keys: "responseObject" then "categories")');
      }

    } else {
      throw Exception('Failed to load categories. Status Code: ${response.statusCode}');
    }
  }

  Future<List<CategoryItem>> fetchBusinessCategoriesAPI() async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/v1/businesscategories/findall'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      if (!response.body.trim().startsWith('{')) return [];

      final Map<String, dynamic> json = jsonDecode(response.body);

      final List<dynamic>? list = json['responseObject'] as List<dynamic>?;

      if (list != null) {
        return list.map((e) {
          return CategoryItem(
            id: e['categoryID'] ?? '',
            name: e['name']?['nameEn'] ?? 'Unnamed Category',
            slug: e['slug'] ?? '',
          );
        }).toList();
      }
    }

    return [];
  }

  // Function to fetch SubProductCategories
  Future<List<Subcategory>> fetchSubProductCategories(String categoryId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/v1/SubProductCategory/findAll?categoryID=$categoryId'),
      headers: _headers,
    );
    if (response.statusCode == 200) {
      final List<dynamic>? finalDataList = _extractListFromResponse(response.body, 'responseObject');
      if (finalDataList != null) {
        return finalDataList.map((json) => Subcategory.fromJson(json)).toList();
      }
    }
    return [];
  }

  // Function to fetch Product Categories
  Future<List<ProductCategory>> fetchProductCategories() async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/v1/ProductCategory/findAll'),
      headers: _headers,
    );
    if (response.statusCode == 200) {
      final List<dynamic>? finalDataList = _extractListFromResponse(response.body, 'responseObject');
      if (finalDataList != null) {
        return finalDataList.map((json) => ProductCategory.fromJson(json)).toList();
      }
    }
    return [];
  }

  // Function to fetch data from filter
  Future<List<Product>> filterProducts({
    required String categoryId,
    List<String>? subCategoryIds,
    List<String>? businessIds,
    String? searchName,
    String sortBy = "price",
    String sortDirection = "asc",
    int page = 1,
    int limit = 20,
  }) async {
    final url = Uri.parse("$baseUrl/api/v1/BusinessProduct/filter");

    final body = {
      "categoryId": categoryId,
      "subCategoryId": null,                           // optional single value
      "subCategoryIds": subCategoryIds ?? [],         // backend supports array
      "businessId": (businessIds != null && businessIds.isNotEmpty)
          ? businessIds.first                         // backend expects single ID
          : null,
      "productId": null,
      "propertiesId": null,
      "searchName": searchName ?? "",
      "sortBy": sortBy,
      "sortDirection": sortDirection,
      "page": page,
      "limit": limit
    };

    final response = await http.post(
      url,
      headers: _headers,
      body: jsonEncode(body),
    );

    if (response.statusCode != 200) {
      throw Exception("Filter API failed → ${response.statusCode}");
    }

    final json = jsonDecode(response.body);
    final list = json["responseObject"] as List<dynamic>;

    return list.map((e) => Product.fromJson(e)).toList();
  }

  // Function to fetch image URL based on image ID (Fixes Host Lookup and HTML response)
  // Allowed image extensions
  static const _validImageExtensions = [".jpg", ".jpeg", ".png", ".webp"];

  Future<String> fetchImageUrl(String imageID) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/v1/image/$imageID'),
        headers: _headers,
      );

      if (response.statusCode != 200) {
        print("❌ image fetch failed ${response.statusCode}");
        return _fallbackImage("FAIL");
      }

      // Ensure JSON response
      if (!response.body.trim().startsWith("{")) {
        print("⚠ Non-JSON response received for $imageID");
        return _fallbackImage("BAD JSON");
      }

      final json = jsonDecode(response.body);

      // Check urls array
      final urls = (json["urls"] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList();

      // Select valid image URL
      for (final url in urls) {
        final lower = url.toLowerCase();
        if (_validImageExtensions.any((ext) => lower.contains(ext))) {
          return url; // first valid image
        }
      }

      // No valid URL found
      print("⚠ No valid image file found for $imageID");
      return _fallbackImage("NO IMG");

    } catch (e) {
      print("🚨 Network error while fetching image → $e");
      return _fallbackImage("NET");
    }
  }

  // fallback placeholder
  String _fallbackImage(String reason) {
    return "https://via.placeholder.com/400/CCCCCC?text=$reason";
  }
}