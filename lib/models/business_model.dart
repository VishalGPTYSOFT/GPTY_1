class Business {
  final String businessID;
  final String companyID;
  final String name;
  final String slug;
  final String phone;
  final String imageURL;
  final String description;
  final String website;

  final BusinessCategory category;
  final BusinessSocial social;
  final BusinessAddress address;
  final BusinessOperatingHours operatingHours;

  Business({
    required this.businessID,
    required this.companyID,
    required this.name,
    required this.slug,
    required this.phone,
    required this.imageURL,
    required this.description,
    required this.website,
    required this.category,
    required this.social,
    required this.address,
    required this.operatingHours,
  });

  factory Business.fromJson(Map<String, dynamic> json) {
    return Business(
      businessID: json['businessID'] ?? '',
      companyID: json['companyID'] ?? '',
      name: json['name'] ?? '',
      slug: json['slug'] ?? '',
      phone: json['phone'] ?? '',
      imageURL: json['imageURL'] ?? '',
      description: json['description'] ?? '',
      website: json['website'] ?? '',
      category: BusinessCategory.fromJson(json['category'] ?? {}),
      social: BusinessSocial.fromJson(json['socialMedia'] ?? {}),
      address: BusinessAddress.fromJson(json['address'] ?? {}),
      operatingHours: BusinessOperatingHours.fromJson(json['business_operating_hours'] ?? {},),
    );
  }
}

// CATEGORY
class BusinessCategory {
  final String categoryID;
  final String name;

  BusinessCategory({
    required this.categoryID,
    required this.name,
  });

  factory BusinessCategory.fromJson(Map<String, dynamic> json) {
    return BusinessCategory(
      categoryID: json['categoryID'] ?? '',
      name: json['name']?['nameEn'] ?? '',
    );
  }
}

// SOCIAL
class BusinessSocial {
  final String? facebook;
  final String? instagram;
  final String? twitter;
  final String? linkedin;

  BusinessSocial({
    this.facebook,
    this.instagram,
    this.twitter,
    this.linkedin,
  });

  factory BusinessSocial.fromJson(Map<String, dynamic> json) {
    return BusinessSocial(
      facebook: json['facebook'],
      instagram: json['instagram'],
      twitter: json['twitter'],
      linkedin: json['linkedin'],
    );
  }
}

// ADDRESS
class BusinessAddress {
  final String street;
  final String city;
  final String state;
  final String zipCode;
  final String country;

  BusinessAddress({
    required this.street,
    required this.city,
    required this.state,
    required this.zipCode,
    required this.country,
  });

  factory BusinessAddress.fromJson(Map<String, dynamic> json) {
    return BusinessAddress(
      street: json['street'] ?? '',
      city: json['city'] ?? '',
      state: json['state'] ?? '',
      zipCode: json['zipCode'] ?? '',
      country: json['country'] ?? '',
    );
  }
}

// business operating hours
class BusinessOperatingHours {
  final BusinessDay monday;
  final BusinessDay tuesday;
  final BusinessDay wednesday;
  final BusinessDay thursday;
  final BusinessDay friday;
  final BusinessDay saturday;
  final BusinessDay sunday;

  BusinessOperatingHours({
    required this.monday,
    required this.tuesday,
    required this.wednesday,
    required this.thursday,
    required this.friday,
    required this.saturday,
    required this.sunday,
  });

  factory BusinessOperatingHours.fromJson(Map<String, dynamic> json) {
    return BusinessOperatingHours(
      monday: BusinessDay.fromJson(json['monday'] ?? {}),
      tuesday: BusinessDay.fromJson(json['tuesday'] ?? {}),
      wednesday: BusinessDay.fromJson(json['wednesday'] ?? {}),
      thursday: BusinessDay.fromJson(json['thursday'] ?? {}),
      friday: BusinessDay.fromJson(json['friday'] ?? {}),
      saturday: BusinessDay.fromJson(json['saturday'] ?? {}),
      sunday: BusinessDay.fromJson(json['sunday'] ?? {}),
    );
  }
}

class BusinessDay {
  final bool isOpen;
  final String openTime;
  final String closeTime;
  final bool is24Hours;

  BusinessDay({
    required this.isOpen,
    required this.openTime,
    required this.closeTime,
    required this.is24Hours,
  });

  factory BusinessDay.fromJson(Map<String, dynamic> json) {
    return BusinessDay(
      isOpen: json['is_open'] ?? false,
      openTime: json['open_time'] ?? '',
      closeTime: json['close_time'] ?? '',
      is24Hours: json['is_24_hours'] ?? false,
    );
  }
}
