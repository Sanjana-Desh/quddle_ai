// lib/screen/classifieds/post_classified_screen.dart
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../services/classifieds_service.dart';
import '../../services/wallet_service.dart';
import '../../utils/constants/classifieds_color.dart';

class PostClassifiedScreen extends StatefulWidget {
  const PostClassifiedScreen({super.key});

  @override
  State<PostClassifiedScreen> createState() => _PostClassifiedScreenState();
}

class _PostClassifiedScreenState extends State<PostClassifiedScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _locationController = TextEditingController();
  final _phoneController = TextEditingController();
  
  String? _selectedCategory;
  List<File> _mediaFiles = []; // Images, videos, GIFs
  List<String> _mediaTypes = []; // Track type of each media
  bool _isLoading = false;
  double? _walletBalance;

  final List<Map<String, dynamic>> _categories = [
    {'label': 'Electronics', 'icon': Icons.devices, 'color': ClassifiedsColors.categoryElectronics},
    {'label': 'Fashion', 'icon': Icons.checkroom, 'color': ClassifiedsColors.categoryFashion},
    {'label': 'Home & Furniture', 'icon': Icons.chair, 'color': ClassifiedsColors.categoryHome},
    {'label': 'Beauty & Personal Care', 'icon': Icons.spa, 'color': ClassifiedsColors.categoryBeauty},
    {'label': 'Vehicles', 'icon': Icons.directions_car, 'color': ClassifiedsColors.categoryVehicles},
    {'label': 'Real Estate', 'icon': Icons.home, 'color': ClassifiedsColors.categoryRealEstate},
    {'label': 'Jobs', 'icon': Icons.work, 'color': ClassifiedsColors.categoryJobs},
    {'label': 'Services', 'icon': Icons.build, 'color': ClassifiedsColors.categoryServices},
    {'label': 'Pets & Animals', 'icon': Icons.pets, 'color': ClassifiedsColors.categoryPets},
    {'label': 'Sports & Outdoors', 'icon': Icons.sports, 'color': ClassifiedsColors.categorySports},
    {'label': 'Books & Education', 'icon': Icons.menu_book, 'color': ClassifiedsColors.accentBlue},
    {'label': 'Food & Grocery', 'icon': Icons.restaurant, 'color': ClassifiedsColors.accentOrange},
  ];

  @override
  void initState() {
    super.initState();
    _loadWalletBalance();
  }

  Future<void> _loadWalletBalance() async {
    final result = await WalletService.getWallet();
    if (result['success'] && mounted) {
      setState(() {
        _walletBalance = double.tryParse(result['wallet']['balance'].toString());
      });
    }
  }

  Future<void> _pickMedia() async {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: ClassifiedsColors.cardBackground,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: ClassifiedsColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            
            Text(
              'Add Media',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: ClassifiedsColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Choose images, videos, or GIFs',
              style: TextStyle(
                fontSize: 14,
                color: ClassifiedsColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            
            _buildMediaOption(
              icon: Icons.photo_library,
              label: 'Choose Photos',
              onTap: () {
                Navigator.pop(context);
                _pickImages();
              },
            ),
            const SizedBox(height: 12),
            _buildMediaOption(
              icon: Icons.videocam,
              label: 'Choose Videos',
              onTap: () {
                Navigator.pop(context);
                _pickVideos();
              },
            ),
            const SizedBox(height: 12),
            _buildMediaOption(
              icon: Icons.gif_box,
              label: 'Choose GIFs',
              onTap: () {
                Navigator.pop(context);
                _pickGifs();
              },
            ),
            const SizedBox(height: 12),
            _buildMediaOption(
              icon: Icons.camera_alt,
              label: 'Take Photo',
              onTap: () {
                Navigator.pop(context);
                _takePhoto();
              },
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildMediaOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: ClassifiedsColors.surfaceLight,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: ClassifiedsColors.border,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: ClassifiedsColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: ClassifiedsColors.primary, size: 24),
            ),
            const SizedBox(width: 16),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: ClassifiedsColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImages() async {
    final picker = ImagePicker();
    final pickedFiles = await picker.pickMultiImage();
    
    if (pickedFiles != null && pickedFiles.isNotEmpty) {
      final totalMedia = _mediaFiles.length + pickedFiles.length;
      if (totalMedia > 10) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Maximum 10 media files allowed'),
              backgroundColor: ClassifiedsColors.error,
            ),
          );
        }
        return;
      }
      
      setState(() {
        _mediaFiles.addAll(pickedFiles.map((xFile) => File(xFile.path)));
        _mediaTypes.addAll(List.filled(pickedFiles.length, 'image'));
      });
    }
  }

  Future<void> _pickVideos() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickVideo(source: ImageSource.gallery);
    
    if (pickedFile != null) {
      if (_mediaFiles.length >= 10) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Maximum 10 media files allowed'),
              backgroundColor: ClassifiedsColors.error,
            ),
          );
        }
        return;
      }
      
      setState(() {
        _mediaFiles.add(File(pickedFile.path));
        _mediaTypes.add('video');
      });
    }
  }

  Future<void> _pickGifs() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    
    if (pickedFile != null) {
      final path = pickedFile.path.toLowerCase();
      if (!path.endsWith('.gif')) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Please select a GIF file'),
              backgroundColor: ClassifiedsColors.error,
            ),
          );
        }
        return;
      }
      
      if (_mediaFiles.length >= 10) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Maximum 10 media files allowed'),
              backgroundColor: ClassifiedsColors.error,
            ),
          );
        }
        return;
      }
      
      setState(() {
        _mediaFiles.add(File(pickedFile.path));
        _mediaTypes.add('gif');
      });
    }
  }

  Future<void> _takePhoto() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);
    
    if (pickedFile != null) {
      if (_mediaFiles.length >= 10) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Maximum 10 media files allowed'),
              backgroundColor: ClassifiedsColors.error,
            ),
          );
        }
        return;
      }
      
      setState(() {
        _mediaFiles.add(File(pickedFile.path));
        _mediaTypes.add('image');
      });
    }
  }

  Future<void> _postAd() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please select a category'),
          backgroundColor: ClassifiedsColors.error,
        ),
      );
      return;
    }

    // In Loop currency: 1 Loop = ₹1
    const postingFeeLoops = 50;
    
    if (_walletBalance == null || _walletBalance! < postingFeeLoops) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Insufficient balance. You need $postingFeeLoops LooPs to post an ad.'),
          backgroundColor: ClassifiedsColors.error,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final result = await ClassifiedsService.postClassified(
      title: _titleController.text,
      description: _descriptionController.text,
      price: double.tryParse(_priceController.text),
      category: _selectedCategory,
      location: _locationController.text,
      phone: _phoneController.text,
      imageCount: _mediaFiles.length,
    );

    setState(() => _isLoading = false);

    if (result['success']) {
      if (_mediaFiles.isNotEmpty && result['uploadUrls'] != null) {
        await ClassifiedsService.uploadImages(
          classifiedId: result['classified']['id'],
          images: _mediaFiles,
          uploadUrls: List<Map<String, dynamic>>.from(result['uploadUrls']),
          mediaTypes: _mediaTypes,
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Ad posted successfully!'),
            backgroundColor: ClassifiedsColors.success,
          ),
        );
        Navigator.pop(context, true);
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Failed to post ad'),
            backgroundColor: ClassifiedsColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ClassifiedsColors.background,
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildFeeNotice(),
              const SizedBox(height: 24),
              _buildCategorySection(),
              const SizedBox(height: 24),
              _buildTextField(
                controller: _titleController,
                label: 'Title',
                hint: 'What are you selling?',
                icon: Icons.title,
                required: true,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _descriptionController,
                label: 'Description',
                hint: 'Describe your item',
                icon: Icons.description,
                required: true,
                maxLines: 4,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _priceController,
                label: 'Price (LooPs)',
                hint: 'Enter price in LooPs',
                icon: Icons.currency_rupee,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _phoneController,
                label: 'Phone Number',
                hint: 'Contact number',
                icon: Icons.phone,
                keyboardType: TextInputType.phone,
                required: true,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _locationController,
                label: 'Location',
                hint: 'Where is the item located?',
                icon: Icons.location_on,
              ),
              const SizedBox(height: 24),
              _buildMediaSection(),
              const SizedBox(height: 32),
              _buildSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: ClassifiedsColors.cardBackground,
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: ClassifiedsColors.textPrimary),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        'Post Your Ad',
        style: TextStyle(
          color: ClassifiedsColors.textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      actions: [
        if (_walletBalance != null)
          Center(
            child: Container(
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: ClassifiedsColors.loopBackground,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: ClassifiedsColors.loopCurrency,
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.account_balance_wallet,
                    size: 16,
                    color: ClassifiedsColors.loopCurrency,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${_walletBalance!.toStringAsFixed(0)} ℒ',
                    style: TextStyle(
                      color: ClassifiedsColors.textPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildFeeNotice() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            ClassifiedsColors.loopBackground,
            ClassifiedsColors.loopBackground.withOpacity(0.7),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: ClassifiedsColors.loopCurrency,
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: ClassifiedsColors.cardBackground,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.info_outline,
              color: ClassifiedsColors.loopCurrency,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Posting Fee: 50 LooPs',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: ClassifiedsColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '1 LooP = ₹1 (Will be deducted from wallet)',
                  style: TextStyle(
                    fontSize: 12,
                    color: ClassifiedsColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Category',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: ClassifiedsColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _categories.map((category) {
            final isSelected = _selectedCategory == category['label'];
            final color = category['color'] as Color;
            
            return InkWell(
              onTap: () {
                setState(() {
                  _selectedCategory = category['label'] as String;
                });
              },
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? color.withOpacity(0.2) : ClassifiedsColors.cardBackground,
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
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      category['label'] as String,
                      style: TextStyle(
                        color: isSelected ? color : ClassifiedsColors.textPrimary,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool required = false,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label + (required ? ' *' : ''),
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: ClassifiedsColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          style: TextStyle(color: ClassifiedsColors.textPrimary),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: ClassifiedsColors.textTertiary),
            prefixIcon: Icon(icon, color: ClassifiedsColors.primary),
            filled: true,
            fillColor: ClassifiedsColors.cardBackground,
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
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: ClassifiedsColors.error),
            ),
          ),
          validator: required
              ? (v) => v?.isEmpty ?? true ? 'This field is required' : null
              : null,
        ),
      ],
    );
  }

  Widget _buildMediaSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Media (Images, Videos, GIFs)',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: ClassifiedsColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Add up to 10 media files',
          style: TextStyle(
            fontSize: 12,
            color: ClassifiedsColors.textSecondary,
          ),
        ),
        const SizedBox(height: 12),
        
        if (_mediaFiles.isEmpty)
          InkWell(
            onTap: _pickMedia,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              height: 150,
              decoration: BoxDecoration(
                color: ClassifiedsColors.surfaceLight,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: ClassifiedsColors.border,
                  width: 2,
                  style: BorderStyle.solid,
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.add_photo_alternate,
                      size: 48,
                      color: ClassifiedsColors.primary,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tap to add media',
                      style: TextStyle(
                        color: ClassifiedsColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
        else
          Column(
            children: [
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: _mediaFiles.length,
                itemBuilder: (context, index) {
                  return Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          decoration: BoxDecoration(
                            color: ClassifiedsColors.surfaceLight,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: _mediaTypes[index] == 'video'
                              ? Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    Container(
                                      color: ClassifiedsColors.textPrimary.withOpacity(0.1),
                                      child: Icon(
                                        Icons.play_circle_outline,
                                        size: 40,
                                        color: ClassifiedsColors.primary,
                                      ),
                                    ),
                                  ],
                                )
                              : Image.file(
                                  _mediaFiles[index],
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  height: double.infinity,
                                ),
                        ),
                      ),
                      // Media type badge
                      Positioned(
                        top: 4,
                        left: 4,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: ClassifiedsColors.textPrimary.withOpacity(0.7),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            _mediaTypes[index].toUpperCase(),
                            style: TextStyle(
                              color: ClassifiedsColors.textWhite,
                              fontSize: 8,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      // Remove button
                      Positioned(
                        top: 4,
                        right: 4,
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _mediaFiles.removeAt(index);
                              _mediaTypes.removeAt(index);
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: ClassifiedsColors.error,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.close,
                              color: ClassifiedsColors.textWhite,
                              size: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 12),
              if (_mediaFiles.length < 10)
                TextButton.icon(
                  onPressed: _pickMedia,
                  icon: Icon(Icons.add_photo_alternate, color: ClassifiedsColors.primary),
                  label: Text(
                    'Add More Media',
                    style: TextStyle(color: ClassifiedsColors.primary),
                  ),
                ),
            ],
          ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: ClassifiedsColors.primaryGradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: ClassifiedsColors.primary.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _isLoading ? null : _postAd,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: _isLoading
            ? SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(ClassifiedsColors.textWhite),
                ),
              )
            : Text(
                'Post Ad (50 LooPs)',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: ClassifiedsColors.textWhite,
                ),
              ),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _locationController.dispose();
    _phoneController.dispose();
    super.dispose();
  }
}