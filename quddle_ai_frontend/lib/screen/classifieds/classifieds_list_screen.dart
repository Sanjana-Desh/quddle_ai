import 'package:flutter/material.dart';
import '../../services/classifieds_service.dart';
import 'post_classified_screen.dart';
import 'classified_detail_screen.dart';
import '../../utils/constants/classifieds_color.dart';

class ClassifiedsListScreen extends StatefulWidget {
  const ClassifiedsListScreen({super.key});

  @override
  State<ClassifiedsListScreen> createState() => _ClassifiedsListScreenState();
}

class _ClassifiedsListScreenState extends State<ClassifiedsListScreen> {
  List<dynamic> _classifieds = [];
  List<dynamic> _filteredClassifieds = [];
  bool _isLoading = true;
  String? _selectedCategory;
  final TextEditingController _searchController = TextEditingController();

  final List<Map<String, dynamic>> _categories = [
    {'label': 'All', 'value': null, 'icon': Icons.grid_view, 'color': ClassifiedsColors.primary},
    {'label': 'Electronics', 'value': 'Electronics', 'icon': Icons.devices, 'color': ClassifiedsColors.categoryElectronics},
    {'label': 'Fashion', 'value': 'Fashion', 'icon': Icons.checkroom, 'color': ClassifiedsColors.categoryFashion},
    {'label': 'Home & Furniture', 'value': 'Home & Furniture', 'icon': Icons.chair, 'color': ClassifiedsColors.categoryHome},
    {'label': 'Beauty & Personal Care', 'value': 'Beauty & Personal Care', 'icon': Icons.spa, 'color': ClassifiedsColors.categoryBeauty},
    {'label': 'Vehicles', 'value': 'Vehicles', 'icon': Icons.directions_car, 'color': ClassifiedsColors.categoryVehicles},
    {'label': 'Real Estate', 'value': 'Real Estate', 'icon': Icons.home, 'color': ClassifiedsColors.categoryRealEstate},
    {'label': 'Jobs', 'value': 'Jobs', 'icon': Icons.work, 'color': ClassifiedsColors.categoryJobs},
    {'label': 'Services', 'value': 'Services', 'icon': Icons.build, 'color': ClassifiedsColors.categoryServices},
    {'label': 'Pets & Animals', 'value': 'Pets & Animals', 'icon': Icons.pets, 'color': ClassifiedsColors.categoryPets},
    {'label': 'Sports & Outdoors', 'value': 'Sports & Outdoors', 'icon': Icons.sports, 'color': ClassifiedsColors.categorySports},
    {'label': 'Books & Education', 'value': 'Books & Education', 'icon': Icons.menu_book, 'color': ClassifiedsColors.accentBlue},
    {'label': 'Food & Grocery', 'value': 'Food & Grocery', 'icon': Icons.restaurant, 'color': ClassifiedsColors.accentOrange},
  ];

  @override
  void initState() {
    super.initState();
    _loadClassifieds();
    _searchController.addListener(_filterClassifieds);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadClassifieds() async {
    setState(() => _isLoading = true);

    final result = await ClassifiedsService.getClassifieds(
      category: _selectedCategory,
    );

    if (result['success'] && mounted) {
      setState(() {
        _classifieds = result['classifieds'] ?? [];
        _filterClassifieds();
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
    }
  }

  void _filterClassifieds() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredClassifieds = _classifieds;
      } else {
        _filteredClassifieds = _classifieds.where((classified) {
          final title = (classified['title'] ?? '').toString().toLowerCase();
          final description = (classified['description'] ?? '').toString().toLowerCase();
          final location = (classified['location'] ?? '').toString().toLowerCase();
          final category = (classified['category'] ?? '').toString().toLowerCase();
          
          return title.contains(query) || 
                 description.contains(query) || 
                 location.contains(query) ||
                 category.contains(query);
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ClassifiedsColors.background,
      appBar: AppBar(
        title: Text(
          'Classifieds',
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
            icon: Icon(Icons.account_balance_wallet, color: ClassifiedsColors.textPrimary),
            onPressed: () {
              Navigator.pushNamed(context, '/wallet');
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            color: ClassifiedsColors.cardBackground,
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              style: TextStyle(color: ClassifiedsColors.textPrimary),
              decoration: InputDecoration(
                hintText: 'Search classifieds...',
                hintStyle: TextStyle(color: ClassifiedsColors.textTertiary),
                prefixIcon: Icon(Icons.search, color: ClassifiedsColors.textSecondary),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear, color: ClassifiedsColors.textSecondary),
                        onPressed: () {
                          _searchController.clear();
                        },
                      )
                    : null,
                filled: true,
                fillColor: ClassifiedsColors.surfaceLight,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: ClassifiedsColors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: ClassifiedsColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: ClassifiedsColors.primary, width: 2),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),

          // Category filter chips
          Container(
            height: 50,
            color: ClassifiedsColors.cardBackground,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                final isSelected = _selectedCategory == category['value'];
                final color = category['color'] as Color? ?? ClassifiedsColors.primary;
                
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _selectedCategory = category['value'];
                      });
                      _loadClassifieds();
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? color.withValues(alpha: 0.2) : ClassifiedsColors.surfaceLight,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected ? color : ClassifiedsColors.border,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            category['icon'] as IconData,
                            color: isSelected ? color : ClassifiedsColors.textSecondary,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            category['label'] as String,
                            style: TextStyle(
                              color: isSelected ? color : ClassifiedsColors.textPrimary,
                              fontSize: 13,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
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

          // Results count
          if (!_isLoading && _filteredClassifieds.isNotEmpty)
            Container(
              width: double.infinity,
              color: ClassifiedsColors.cardBackground,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                '${_filteredClassifieds.length} ${_filteredClassifieds.length == 1 ? 'ad' : 'ads'} found',
                style: TextStyle(
                  fontSize: 13,
                  color: ClassifiedsColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

          // Classifieds list
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator(color: ClassifiedsColors.primary))
                : _filteredClassifieds.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _searchController.text.isNotEmpty 
                                  ? Icons.search_off 
                                  : Icons.inventory_2_outlined,
                              size: 80,
                              color: ClassifiedsColors.textTertiary,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _searchController.text.isNotEmpty
                                  ? 'No results found'
                                  : 'No classifieds found',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: ClassifiedsColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _searchController.text.isNotEmpty
                                  ? 'Try adjusting your search'
                                  : 'Be the first to post an ad!',
                              style: TextStyle(fontSize: 14, color: ClassifiedsColors.textTertiary),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadClassifieds,
                        color: ClassifiedsColors.primary,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(12),
                          itemCount: _filteredClassifieds.length,
                          itemBuilder: (context, index) {
                            final classified = _filteredClassifieds[index];
                            return _buildClassifiedCard(classified);
                          },
                        ),
                      ),
          ),
        ],
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          gradient: ClassifiedsColors.primaryGradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: ClassifiedsColors.primary.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: FloatingActionButton.extended(
          onPressed: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const PostClassifiedScreen()),
            );
            if (result == true) {
              _loadClassifieds();
            }
          },
          icon: Icon(Icons.add, color: ClassifiedsColors.textWhite),
          label: Text(
            'Post Ad',
            style: TextStyle(
              color: ClassifiedsColors.textWhite,
              fontWeight: FontWeight.w600,
            ),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
      ),
    );
  }

  Widget _buildClassifiedCard(Map<String, dynamic> classified) {
    final images = classified['images'] as List?;
    final imageUrl = images != null && images.isNotEmpty ? images[0] : null;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: ClassifiedsColors.cardBackground,
      elevation: 0,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ClassifiedDetailScreen(classified: classified),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: ClassifiedsColors.border,
              width: 1,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image with hero animation
                Hero(
                  tag: 'classified_${classified['id'] ?? classified['title']}',
                  child: Container(
                    width: 110,
                    height: 110,
                    decoration: BoxDecoration(
                      color: ClassifiedsColors.surfaceLight,
                      borderRadius: BorderRadius.circular(12),
                      image: imageUrl != null
                          ? DecorationImage(
                              image: NetworkImage(imageUrl),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: imageUrl == null
                        ? Icon(Icons.image, size: 40, color: ClassifiedsColors.textTertiary)
                        : null,
                  ),
                ),

                const SizedBox(width: 12),

                // Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        classified['title'] ?? '',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: ClassifiedsColors.textPrimary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      if (classified['price'] != null)
                        Text(
                          '₹${classified['price']}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: ClassifiedsColors.primary,
                          ),
                        ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          if (classified['category'] != null)
                            Flexible(
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: ClassifiedsColors.primary.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  classified['category'],
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: ClassifiedsColors.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      if (classified['location'] != null)
                        Row(
                          children: [
                            Icon(Icons.location_on, size: 14, color: ClassifiedsColors.textSecondary),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                classified['location'],
                                style: TextStyle(fontSize: 12, color: ClassifiedsColors.textSecondary),
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
      ),
    );
  }
}