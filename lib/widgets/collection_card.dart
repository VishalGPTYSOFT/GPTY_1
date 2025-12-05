import 'package:flutter/material.dart';

class CollectionCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String imagePath; // This can be a local path or a network URL
  final Color backgroundColor;
  final Widget actionWidget;
  final bool showCarouselDots;

  const CollectionCard({
    super.key,
    required this.title,
    this.subtitle,
    required this.imagePath,
    required this.backgroundColor,
    required this.actionWidget,
    this.showCarouselDots = false,
  });

  // Helper widget to dynamically load an image (Asset or Network)
  Widget _DynamicImage({required String path}) {
    // Check if the path is a full URL (simple HTTP/HTTPS check)
    bool isNetworkImage = path.toLowerCase().startsWith('http');

    if (isNetworkImage) {
      // Return Network Image
      return Image.network(
        path,
        height: 180,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            height: 180,
            color: Colors.grey[200],
            child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
          );
        },
        errorBuilder: (context, error, stackTrace) => Container(
          height: 180,
          color: Colors.grey[300],
          child: const Center(child: Text('Network Error')),
        ),
      );
    } else {
      // Return Local Asset Image
      return Image.asset(
        path,
        height: 180,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Container(
          height: 180,
          color: Colors.grey[300],
          child: const Center(child: Text('Asset Error')),
        ),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Container(
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              // Image Section - NOW USING THE DYNAMIC HELPER
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                child: _DynamicImage(path: imagePath),
              ),
              // Text and Action Section
              Padding(
                padding: const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 16.0),
                child: Column(
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    if (subtitle != null && subtitle!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        subtitle!,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                    const SizedBox(height: 16),
                    actionWidget,
                    // Carousel Dots for the first card only
                    if (showCarouselDots)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildDot(Colors.green), // Active dot
                            const SizedBox(width: 8),
                            _buildDot(Colors.white, hasBorder: true), // Inactive dot
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDot(Color color, {bool hasBorder = false}) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: hasBorder
            ? Border.all(color: Colors.grey[400]!, width: 1.0)
            : null,
      ),
    );
  }
}