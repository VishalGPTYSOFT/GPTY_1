import 'package:flutter/material.dart';
import 'package:gpty_3/network/api_service.dart';
import 'package:gpty_3/models/business_model.dart';

class BusinessPage extends StatefulWidget {
  final String slug; // ⬅️ Receive slug from previous screen

  const BusinessPage({super.key, required this.slug});

  @override
  State<BusinessPage> createState() => _BusinessPageState();
}

class _BusinessPageState extends State<BusinessPage> {
  late Future<Business?> _futureBusiness;
  final ApiService api = ApiService();

  @override
  void initState() {
    super.initState();
    _futureBusiness = api.getBusinessBySlug(widget.slug);
  }

  Widget _operatingHoursTable(BusinessOperatingHours hours) {
    final Map<String, BusinessDay> days = {
      "Mon": hours.monday,
      "Tue": hours.tuesday,
      "Wed": hours.wednesday,
      "Thu": hours.thursday,
      "Fri": hours.friday,
      "Sat": hours.saturday,
      "Sun": hours.sunday,
    };

    return Column(
      children: days.entries.map((entry) {
        final label = entry.key;
        final day = entry.value;

        String timeText;
        if (!day.isOpen) {
          timeText = "Closed";
        } else if (day.is24Hours) {
          timeText = "Open 24 Hours";
        } else {
          timeText = "${day.openTime} - ${day.closeTime}";
        }

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
              Text(
                timeText,
                style: TextStyle(
                  fontSize: 15,
                  color: day.isOpen ? Colors.black : Colors.red,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: FutureBuilder<Business?>(
        future: _futureBusiness,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text("Business not found"));
          }

          final business = snapshot.data!;

          return CustomScrollView(
            slivers: [
              // ─── Big Banner Image ─────────────────────────────
              SliverAppBar(
                pinned: true,
                expandedHeight: 250,
                backgroundColor: Colors.white,
                iconTheme: const IconThemeData(color: Colors.black),
                flexibleSpace: FlexibleSpaceBar(
                  background: Image.network(
                    business.imageURL,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                        Container(color: Colors.grey.shade300),
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: Column(
                  children: [
                    // ─── Business Details Card ─────────────────────────────
                    Container(
                      margin: const EdgeInsets.all(16),
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            business.name,
                            style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 6),

                          // Category
                          Text(
                            business.category.name,
                            style: const TextStyle(
                                color: Colors.green, fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 10),

                          // Description
                          Text(
                            business.description,
                            style: const TextStyle(
                                fontSize: 15, height: 1.5),
                          ),
                          const SizedBox(height: 16),

                          // Phone + Website
                          Row(
                            children: [
                              const Icon(Icons.phone, size: 20),
                              const SizedBox(width: 6),
                              Text(business.phone),
                              const SizedBox(width: 16),
                              const Icon(Icons.language, size: 20),
                              const SizedBox(width: 4),
                              InkWell(
                                onTap: () {},
                                child: Text(
                                  "Website",
                                  style: TextStyle(
                                      color: Colors.blue.shade800,
                                      fontWeight: FontWeight.w600),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 20),
                          // Social Media Icons Row
                          Row(
                            children: [
                              if (business.social.facebook != null)
                                socialBtn(Icons.facebook, business.social.facebook!),
                              if (business.social.instagram != null)
                                socialBtn(Icons.camera_alt, business.social.instagram!),
                              if (business.social.twitter != null)
                                socialBtn(Icons.alternate_email, business.social.twitter!),
                              if (business.social.linkedin != null)
                                socialBtn(Icons.work, business.social.linkedin!),
                            ],
                          ),

                          const SizedBox(height: 24),
                          // Operating Hours
                          Text(
                            "Operating Hours",
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 12),
                          _operatingHoursTable(business.operatingHours),
                        ],
                      ),
                    ),

                    // ─── Products Header ─────────────────────────────
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          Text("Our Products",
                              style: TextStyle(
                                  fontSize: 22, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),

                    const SizedBox(height: 10),

                    // TODO: Insert products list/grid here later
                    const Padding(
                      padding: EdgeInsets.all(18.0),
                      child: Text(
                        "Products section coming next...",
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // Helper button for social media
  Widget socialBtn(IconData icon, String url) {
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: InkWell(
        onTap: () {},
        child: CircleAvatar(
          radius: 18,
          backgroundColor: Colors.blue.shade50,
          child: Icon(icon, color: Colors.blue.shade800, size: 20),
        ),
      ),
    );
  }
}
