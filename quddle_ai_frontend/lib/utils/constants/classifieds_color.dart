// lib/utils/constants/classifieds_colors.dart
import 'package:flutter/material.dart';

class ClassifiedsColors {
  ClassifiedsColors._();

  // Matte Pastel Green Primary Palette
  static Color primary = const Color(0xFF7FB069); // Sage green
  static Color primaryLight = const Color(0xFFA8D5BA); // Soft mint
  static Color primaryDark = const Color(0xFF5F8D4E); // Deep sage
  
  // Background Colors - Matte whites and off-whites
  static Color background = const Color(0xFFFAFAFA); // Off-white
  static Color cardBackground = const Color(0xFFFFFFFF); // Pure white
  static Color surfaceLight = const Color(0xFFF5F7F5); // Light mint tint
  
  // Accent Colors - Complementary pastels
  static Color accent = const Color(0xFFE8B4B8); // Dusty rose
  static Color accentOrange = const Color(0xFFFFD6A5); // Peach
  static Color accentBlue = const Color(0xFFB4C7E7); // Powder blue
  static Color accentYellow = const Color(0xFFFFF4CC); // Cream
  
  // Text Colors - Muted for elegance
  static const Color textPrimary = Color(0xFF2D3E2F); // Dark forest
  static const Color textSecondary = Color(0xFF6B7A6E); // Medium grey-green
  static const Color textTertiary = Color(0xFF9FA99F); // Light grey-green
  static const Color textWhite = Color(0xFFFAFAFA);
  
  // Category Colors - Distinct pastels
  static const Color categoryElectronics = Color(0xFFB4C7E7); // Blue
  static const Color categoryFashion = Color(0xFFE8B4B8); // Rose
  static const Color categoryHome = Color(0xFFA8D5BA); // Mint
  static const Color categoryBeauty = Color(0xFFFFD6A5); // Peach
  static const Color categoryVehicles = Color(0xFFD4A5A5); // Mauve
  static const Color categoryRealEstate = Color(0xFFC5E1A5); // Light olive
  static const Color categoryJobs = Color(0xFFBBDEFB); // Sky blue
  static const Color categoryServices = Color(0xFFF0E68C); // Khaki
  static const Color categoryPets = Color(0xFFFFCCBC); // Coral
  static const Color categorySports = Color(0xFFB2DFDB); // Teal
  
  // Status Colors - Soft versions
  static const Color success = Color(0xFF81C784); // Soft green
  static const Color error = Color(0xFFE57373); // Soft red
  static const Color warning = Color(0xFFFFB74D); // Soft orange
  static const Color info = Color(0xFF64B5F6); // Soft blue
  
  // Border & Divider - Subtle
  static const Color border = Color(0xFFE0E5E0); // Light grey-green
  static const Color divider = Color(0xFFECF0EC); // Very light grey-green
  
  // Shadow - Soft depth (using withValues for Flutter 3.24+)
  static Color shadow =
      const Color(0xFF2D3E2F).withValues(alpha: 0.08);
  static Color shadowLight =
      const Color(0xFF2D3E2F).withValues(alpha: 0.04);
  
  // Currency/Loop Color - Special highlight
  static Color loopCurrency =
      const Color.fromARGB(255, 255, 149,0).withValues(alpha: 0.9); // Muted gold
  static Color loopIcon =
      const Color.fromARGB(255, 208, 119,31).withValues(alpha: 0.9);

  static const Color loopBackground = Color(0xFFFFF9E6); // Light gold tint
  
  // Gradients - Subtle and elegant
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF7FB069), // Sage
      Color(0xFFA8D5BA), // Mint
    ],
  );
  
  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFFFFFFFF),
      Color(0xFFF5F7F5),
    ],
  );
  
  // Category gradient for cards
  static LinearGradient getCategoryGradient(String category) {
    Color startColor;
    switch (category.toLowerCase()) {
      case 'electronics':
        startColor = categoryElectronics;
        break;
      case 'fashion':
        startColor = categoryFashion;
        break;
      case 'home':
        startColor = categoryHome;
        break;
      case 'beauty':
        startColor = categoryBeauty;
        break;
      case 'vehicles':
        startColor = categoryVehicles;
        break;
      case 'real estate':
        startColor = categoryRealEstate;
        break;
      case 'jobs':
        startColor = categoryJobs;
        break;
      case 'services':
        startColor = categoryServices;
        break;
      case 'pets':
        startColor = categoryPets;
        break;
      case 'sports':
        startColor = categorySports;
        break;
      default:
        startColor = primary;
    }
    
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        startColor,
        startColor.withValues(alpha: 0.7),
      ],
    );
  }
}
