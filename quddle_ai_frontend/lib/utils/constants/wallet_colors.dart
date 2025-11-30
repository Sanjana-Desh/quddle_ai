// lib/utils/constants/wallet_colors.dart
import 'package:flutter/material.dart';

class WalletColors {
  WalletColors._();

  // Matte Pastel Green Primary Palette (matching classifieds)
  static const Color primary = Color(0xFF7FB069); // Sage green
  static const Color primaryLight = Color(0xFFA8D5BA); // Soft mint
  static const Color primaryDark = Color(0xFF5F8D4E); // Deep sage
  
  // Background Colors - Matte whites and off-whites
  static const Color background = Color(0xFFFAFAFA); // Off-white
  static const Color cardBackground = Color(0xFFFFFFFF); // Pure white
  static const Color surfaceLight = Color(0xFFF5F7F5); // Light mint tint
  
  // Accent Colors - Complementary pastels
  static const Color accent = Color(0xFFE8B4B8); // Dusty rose
  static const Color accentOrange = Color(0xFFFFD6A5); // Peach
  static const Color accentBlue = Color(0xFFB4C7E7); // Powder blue
  static const Color accentYellow = Color(0xFFFFF4CC); // Cream
  
  // Text Colors - Muted for elegance
  static const Color textPrimary = Color(0xFF2D3E2F); // Dark forest
  static const Color textSecondary = Color(0xFF6B7A6E); // Medium grey-green
  static const Color textTertiary = Color(0xFF9FA99F); // Light grey-green
  static const Color textWhite = Color(0xFFFAFAFA);
  
  // Transaction Colors - Soft versions
  static const Color credit = Color(0xFF81C784); // Soft green (money in)
  static const Color debit = Color(0xFFE57373); // Soft red (money out)
  static const Color pending = Color.fromARGB(255, 242, 146, 35); // Soft orange
  
  // Status Colors
  static const Color success = Color(0xFF81C784); // Soft green
  static const Color error = Color(0xFFE57373); // Soft red
  static const Color warning = Color(0xFFFFB74D); // Soft orange
  static const Color info = Color(0xFF64B5F6); // Soft blue
  
  // Border & Divider - Subtle
  static const Color border = Color(0xFFE0E5E0); // Light grey-green
  static const Color divider = Color(0xFFECF0EC); // Very light grey-green
  
  // Shadow - Soft depth
  static Color shadow = const Color(0xFF2D3E2F).withValues(alpha: 0.08);
  static Color shadowLight = const Color(0xFF2D3E2F).withValues(alpha: 0.04);
  
  // LooP Currency Colors - Special highlight
  static const Color loopCurrency = Color(0xFF7FB069); // Sage green (matching primary)
  static const Color loopBackground = Color(0xFFE8F5E9); // Very light green tint
  static const Color loopGold = Color.fromARGB(255, 214, 134, 15); // Gold accent
  
  // Gradients - Subtle and elegant
  static const LinearGradient balanceGradient = LinearGradient(
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
  
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF7FB069), // Sage
      Color(0xFF5F8D4E), // Deep sage
    ],
  );
  
  // Transaction type gradients
  static const LinearGradient creditGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF81C784), // Soft green
      Color(0xFFA5D6A7), // Lighter green
    ],
  );
  
  static const LinearGradient debitGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFE57373), // Soft red
      Color(0xFFEF9A9A), // Lighter red
    ],
  );
  
  // Icon background colors
  static Color creditIconBackground = const Color(0xFF81C784).withValues(alpha: 0.15);
  static Color debitIconBackground = const Color(0xFFE57373).withValues(alpha: 0.15);
  static Color infoIconBackground = const Color(0xFF7FB069).withValues(alpha: 0.15);
  
  // Helper method for transaction colors
  static Color getTransactionColor(String type) {
    switch (type.toLowerCase()) {
      case 'credit':
        return credit;
      case 'debit':
        return debit;
      case 'pending':
        return pending;
      default:
        return textSecondary;
    }
  }
  
  static Color getTransactionBackground(String type) {
    switch (type.toLowerCase()) {
      case 'credit':
        return creditIconBackground;
      case 'debit':
        return debitIconBackground;
      case 'pending':
        return pending.withValues(alpha: 0.15);
      default:
        return surfaceLight;
    }
  }
}