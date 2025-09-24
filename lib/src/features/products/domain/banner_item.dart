class BannerItem {
  final String imageUrl;
  final String title;
  final String subtitle;
  final bool isActive;
  final int order;

  BannerItem({
    required this.imageUrl,
    required this.title,
    required this.subtitle,
    this.isActive = true,
    this.order = 0,
  });

  factory BannerItem.fromMap(Map<String, dynamic> map) {
    return BannerItem(
      imageUrl: map['imageUrl'] as String? ?? '',
      title: map['title'] as String? ?? '',
      subtitle: map['description'] as String? ?? '', // Matching 'description' from Firestore
      isActive: map['isActive'] as bool? ?? true,
      order: (map['order'] as num? ?? 0).toInt(),
    );
  }
}
