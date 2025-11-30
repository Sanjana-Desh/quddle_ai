import 'package:flutter/material.dart';
import '../../services/classifieds_service.dart';
import '../../utils/constants/colors.dart';
import 'post_classified_screen.dart';
import 'classified_detail_screen.dart';

class ClassifiedsListScreen extends StatefulWidget {
  const ClassifiedsListScreen({super.key});

  @override
  State<ClassifiedsListScreen> createState() => _ClassifiedsListScreenState();
}

class _ClassifiedsListScreenState extends State<ClassifiedsListScreen> {
  List<dynamic> _classifieds = [];
  bool _isLoading = true;
  String? _selectedCategory;

  final List<Map<String, dynamic>> _categories = [
    {'label': 'All', 'value': null, 'icon': Icons.grid_view},
    {'label': 'Furniture', 'value': 'Furniture', 'icon': Icons.weekend},
    {'label': 'Home Appliances', 'value': 'Home Appliances', 'icon': Icons.kitchen},
    {'label': 'Mobile Phones', 'value': 'Mobile Phones', 'icon': Icons.phone_android},
  ];

  @override
  void initState() {
    super.initState();
    _loadClassifieds();
  }

  Future<void> _loadClassifieds() async {
    setState(() => _isLoading = true);

    final result = await ClassifiedsService.getClassifieds(
      category: _selectedCategory,
    );

    if (result['success'] && mounted) {
      setState(() {
        _classifieds = result['classifieds'] ?? [];
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Classifieds', style: TextStyle(color: Colors.black)),
        backgroundColor: MyColors.navbar,
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_balance_wallet, color: Colors.black),
            onPressed: () {
              Navigator.pushNamed(context, '/wallet');
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Category filter
          Container(
            height: 80,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                final isSelected = _selectedCategory == category['value'];
                
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedCategory = category['value'];
                      });
                      _loadClassifieds();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? MyColors.primary : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected ? MyColors.primary : Colors.grey[300]!,
                          width: 1,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: MyColors.primary.withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                )
                              ]
                            : [],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            category['icon'] as IconData,
                            color: isSelected ? Colors.white : Colors.black,
                            size: 24,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            category['label'] as String,
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.black,
                              fontSize: 12,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          const Divider(height: 1),

         // Classifieds list
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: MyColors.primary))
                : _classifieds.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.inventory_2_outlined, size: 80, color: Colors.grey[400]),
                            const SizedBox(height: 16),
                            Text(
                              'No classifieds found',
                              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Be the first to post an ad!',
                              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadClassifieds,
                        color: MyColors.primary,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(8),
                          itemCount: _classifieds.length,
                          itemBuilder: (context, index) {
                            final classified = _classifieds[index];
                            return _buildClassifiedCard(classified);
                          },
                        ),
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const PostClassifiedScreen()),
          );
          if (result == true) {
            _loadClassifieds();
          }
        },
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Post Ad', style: TextStyle(color: Colors.white)),
        backgroundColor: MyColors.primary,
      ),
    );
  }

  Widget _buildClassifiedCard(Map<String, dynamic> classified) {
    final images = classified['images'] as List?;
    final imageUrl = images != null && images.isNotEmpty ? images[0] : null;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ClassifiedDetailScreen(classified: classified),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                  image: imageUrl != null
                      ? DecorationImage(
                          image: NetworkImage(imageUrl),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: imageUrl == null
                    ? const Icon(Icons.image, size: 40, color: Colors.grey)
                    : null,
              ),

              const SizedBox(width: 12),

              // Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      classified['title'] ?? '',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    if (classified['price'] != null)
                      Text(
                        'LooP ${classified['price']}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: MyColors.primary,
                        ),
                      ),
                    const SizedBox(height: 4),
                    if (classified['category'] != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: MyColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          classified['category'],
                          style: const TextStyle(
                            fontSize: 11,
                            color: MyColors.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    const SizedBox(height: 4),
                    if (classified['location'] != null)
                      Row(
                        children: [
                          const Icon(Icons.location_on, size: 14, color: Colors.grey),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              classified['location'],
                              style: const TextStyle(fontSize: 12, color: Colors.grey),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
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
}