import 'package:flutter/material.dart';
import '../../utils/constants/classifieds_color.dart';

class ClassifiedDetailScreen extends StatefulWidget {
  final Map<String, dynamic> classified;

  const ClassifiedDetailScreen({super.key, required this.classified});

  @override
  State<ClassifiedDetailScreen> createState() => _ClassifiedDetailScreenState();
}

class _ClassifiedDetailScreenState extends State<ClassifiedDetailScreen> {
  int _currentImageIndex = 0;
  
  @override
  Widget build(BuildContext context) {
    final images = widget.classified['images'] as List?;
    final hasImages = images != null && images.isNotEmpty;

    return Scaffold(
      backgroundColor: ClassifiedsColors.background,
      appBar: AppBar(
        title: Text(
          'Ad Details',
          style: TextStyle(
            color: ClassifiedsColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: ClassifiedsColors.cardBackground,
        elevation: 0,
        iconTheme: IconThemeData(color: ClassifiedsColors.textPrimary),
        actions: [
          IconButton(
            icon: Icon(Icons.share, color: ClassifiedsColors.textPrimary),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Share feature coming soon'),
                  backgroundColor: ClassifiedsColors.primary,
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Images carousel
            Stack(
              children: [
                if (hasImages)
                  SizedBox(
                    height: 350,
                    child: PageView.builder(
                      itemCount: images.length,
                      onPageChanged: (index) {
                        setState(() {
                          _currentImageIndex = index;
                        });
                      },
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () => _showImageFullScreen(context, images, index),
                          child: Hero(
                            tag: 'classified_${widget.classified['id'] ?? widget.classified['title']}_$index',
                            child: Image.network(
                              images[index],
                              fit: BoxFit.cover,
                              width: double.infinity,
                              errorBuilder: (_, __, ___) => Container(
                                color: ClassifiedsColors.surfaceLight,
                                child: Icon(
                                  Icons.broken_image,
                                  size: 80,
                                  color: ClassifiedsColors.textTertiary,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  )
                else
                  Container(
                    height: 350,
                    color: ClassifiedsColors.surfaceLight,
                    child: Center(
                      child: Icon(
                        Icons.image_outlined,
                        size: 80,
                        color: ClassifiedsColors.textTertiary,
                      ),
                    ),
                  ),

                // Image indicator
                if (hasImages && images.length > 1)
                  Positioned(
                    bottom: 16,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: ClassifiedsColors.textPrimary.withValues(alpha: 0.7),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: List.generate(
                            images.length,
                            (index) => Container(
                              margin: const EdgeInsets.symmetric(horizontal: 3),
                              width: _currentImageIndex == index ? 24 : 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: _currentImageIndex == index
                                    ? ClassifiedsColors.textWhite
                                    : ClassifiedsColors.textWhite.withValues(alpha: 0.5),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category
                  if (widget.classified['category'] != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: ClassifiedsColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        widget.classified['category'],
                        style: TextStyle(
                          color: ClassifiedsColors.primary,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),

                  const SizedBox(height: 12),

                  // Title - Larger and prominent
                  Text(
                    widget.classified['title'] ?? '',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: ClassifiedsColors.textPrimary,
                      height: 1.2,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Price - Green and compact
                  if (widget.classified['price'] != null)
                    Row(
                      children: [
                        Icon(
                          Icons.currency_rupee,
                          color: ClassifiedsColors.success,
                          size: 20,
                        ),
                        Text(
                          '${widget.classified['price']}',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: ClassifiedsColors.success,
                          ),
                        ),
                      ],
                    ),

                  const SizedBox(height: 20),

                  // Location
                  if (widget.classified['location'] != null)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: ClassifiedsColors.cardBackground,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: ClassifiedsColors.border,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: ClassifiedsColors.surfaceLight,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.location_on,
                              size: 18,
                              color: ClassifiedsColors.error,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Location',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: ClassifiedsColors.textSecondary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  widget.classified['location'],
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: ClassifiedsColors.textPrimary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 24),

                  // Description
                  Text(
                    'Description',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: ClassifiedsColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: ClassifiedsColors.cardBackground,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: ClassifiedsColors.border,
                        width: 1,
                      ),
                    ),
                    child: Text(
                      widget.classified['description'] ?? 'No description available',
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.5,
                        color: ClassifiedsColors.textPrimary,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Posted date
                  if (widget.classified['created_at'] != null)
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 14,
                          color: ClassifiedsColors.textSecondary,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Posted ${_getTimeAgo(DateTime.parse(widget.classified['created_at']))}',
                          style: TextStyle(
                            color: ClassifiedsColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),

                  const SizedBox(height: 80),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: ClassifiedsColors.cardBackground,
            boxShadow: [
              BoxShadow(
                color: ClassifiedsColors.textPrimary.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: Row(
            children: [
              // Call button
              if (widget.classified['phone'] != null)
                Expanded(
                  child: Container(
                    height: 54,
                    decoration: BoxDecoration(
                      color: ClassifiedsColors.cardBackground,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: ClassifiedsColors.success.withValues(alpha: 0.5),
                        width: 2,
                      ),
                    ),
                    child: ElevatedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Calling ${widget.classified['phone']}'),
                            backgroundColor: ClassifiedsColors.success,
                          ),
                        );
                      },
                      icon: Icon(Icons.phone, color: ClassifiedsColors.success),
                      label: Text(
                        'Call',
                        style: TextStyle(
                          color: ClassifiedsColors.success,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ),
              
              if (widget.classified['phone'] != null) const SizedBox(width: 12),

              // Chat button with gradient
              Expanded(
                child: Container(
                  height: 54,
                  decoration: BoxDecoration(
                    color: ClassifiedsColors.success,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: ClassifiedsColors.success.withValues(alpha: 0.25),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ElevatedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Chat feature coming soon'),
                          backgroundColor: ClassifiedsColors.success,
                        ),
                      );
                    },
                    icon: Icon(Icons.chat_bubble, color: Colors.white, size: 18),
                    label: Text(
                      'Chat',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 365) {
      final years = (difference.inDays / 365).floor();
      return '$years ${years == 1 ? 'year' : 'years'} ago';
    } else if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return '$months ${months == 1 ? 'month' : 'months'} ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} ${difference.inDays == 1 ? 'day' : 'days'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} ${difference.inHours == 1 ? 'hour' : 'hours'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} ${difference.inMinutes == 1 ? 'minute' : 'minutes'} ago';
    } else {
      return 'just now';
    }
  }

  void _showImageFullScreen(BuildContext context, List images, int initialIndex) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            iconTheme: const IconThemeData(color: Colors.white),
          ),
          body: PageView.builder(
            controller: PageController(initialPage: initialIndex),
            itemCount: images.length,
            itemBuilder: (context, index) {
              return InteractiveViewer(
                child: Center(
                  child: Hero(
                    tag: 'classified_${widget.classified['id'] ?? widget.classified['title']}_$index',
                    child: Image.network(
                      images[index],
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}