import 'package:flutter/material.dart';

import '../../domain/banner_item.dart'; // Corrected import path

class BannerCarousel extends StatefulWidget {
  final List<BannerItem> banners;

  const BannerCarousel({super.key, required this.banners});

  @override
  State<BannerCarousel> createState() => _BannerCarouselState();
}

class _BannerCarouselState extends State<BannerCarousel> {
  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 200,
          child: PageView.builder(
            itemCount: widget.banners.length,
            onPageChanged: (value) {
              setState(() {
                _currentPage = value;
              });
            },
            itemBuilder: (context, index) {
              final banner = widget.banners[index];
              return Card(
                clipBehavior: Clip.antiAlias,
                margin: const EdgeInsets.symmetric(horizontal: 8.0),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(
                      banner.imageUrl,
                      fit: BoxFit.cover,
                    ),
                    // Gradient overlay for text readability
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.black.withOpacity(0.6), Colors.transparent],
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 16,
                      left: 16,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            banner.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            banner.subtitle,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 10),
        // Dots indicator
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(widget.banners.length, (index) {
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 4.0),
              height: 8.0,
              width: _currentPage == index ? 24.0 : 8.0,
              decoration: BoxDecoration(
                color: _currentPage == index ? Theme.of(context).primaryColor : Colors.grey,
                borderRadius: BorderRadius.circular(12),
              ),
            );
          }),
        ),
      ],
    );
  }
}
