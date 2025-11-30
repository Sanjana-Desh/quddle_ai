import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/helpers/storage.dart';
import 'auth_service.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WalletService {
  static String get _baseUrl => AuthService.baseUrl;

  // Helper method to get token (works for both Web and Mobile)
  static Future<String?> _getToken() async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('token');
    } else {
      return await SecureStorage.readToken();
    }
  }

  // Get wallet balance
  static Future<Map<String, dynamic>> getWallet() async {
    print("🔗 Fetching wallet from: $_baseUrl/wallet");
    try {
      final token = await _getToken();
      
      if (token == null || token.isEmpty) {
        print("❌ No token found");
        return {'success': false, 'message': 'Authentication required'};
      }

      print("✅ Token found: ${token.substring(0, 20)}...");

      final url = Uri.parse('$_baseUrl/wallet');
      print("📡 GET $url");

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print("📥 Response status: ${response.statusCode}");
      print("📥 Response body: ${response.body}");

      if (response.statusCode == 404) {
        print("❌ 404: Wallet endpoint not found! Check backend routes.");
        return {
          'success': false,
          'message': 'Wallet endpoint not found. Backend may not be running correctly.'
        };
      }

      final data = jsonDecode(response.body);
      return data;
    } catch (e) {
      print("💥 Error in getWallet: $e");
      return {'success': false, 'message': 'Network error: ${e.toString()}'};
    }
  }

  // Get wallet transactions
  static Future<Map<String, dynamic>> getTransactions() async {
    print("🔗 Fetching transactions from: $_baseUrl/wallet/transactions");
    try {
      final token = await _getToken();

      if (token == null || token.isEmpty) {
        print("❌ No token found");
        return {'success': false, 'message': 'Authentication required'};
      }

      final url = Uri.parse('$_baseUrl/wallet/transactions');
      print("📡 GET $url");

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print("📥 Response status: ${response.statusCode}");

      if (response.statusCode == 404) {
        print("❌ 404: Transactions endpoint not found!");
        return {
          'success': false,
          'message': 'Transactions endpoint not found'
        };
      }

      final data = jsonDecode(response.body);
      return data;
    } catch (e) {
      print("💥 Error in getTransactions: $e");
      return {'success': false, 'message': 'Network error: ${e.toString()}'};
    }
  }

  // Add money to wallet - CHANGED: from dollars to rupees
  static Future<Map<String, dynamic>> addMoney(double rupees) async {
    print("🔗 Adding money to: $_baseUrl/wallet/add-money");
    try {
      final token = await _getToken();

      if (token == null || token.isEmpty) {
        print("❌ No token found");
        return {'success': false, 'message': 'Authentication required'};
      }

      final url = Uri.parse('$_baseUrl/wallet/add-money');
      print("📡 POST $url");
      print("💵 Amount: ₹$rupees");

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'rupees': rupees}),  // CHANGED: from 'dollars' to 'rupees'
      );

      print("📥 Response status: ${response.statusCode}");
      print("📥 Response body: ${response.body}");

      if (response.statusCode == 404) {
        print("❌ 404: Add money endpoint not found!");
        return {
          'success': false,
          'message': 'Add money endpoint not found. Check backend.'
        };
      }

      final data = jsonDecode(response.body);
      return data;
    } catch (e) {
      print("💥 Error in addMoney: $e");
      return {'success': false, 'message': 'Network error: ${e.toString()}'};
    }
  }

  // Get exchange rate
  static Future<Map<String, dynamic>> getExchangeRate() async {
    print("🔗 Fetching exchange rate from: $_baseUrl/wallet/exchange-rate");
    try {
      final url = Uri.parse('$_baseUrl/wallet/exchange-rate');
      print("📡 GET $url");

      final response = await http.get(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      print("📥 Response status: ${response.statusCode}");
      
      if (response.statusCode == 404) {
        print("❌ 404: Exchange rate endpoint not found!");
        return {
          'success': false,
          'message': 'Exchange rate endpoint not found',
          'rate': 1.0 // Fallback rate (1 INR = 1 LooP)
        };
      }

      final data = jsonDecode(response.body);
      return data;
    } catch (e) {
      print("💥 Error in getExchangeRate: $e");
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
        'rate': 1.0 // Fallback rate (1 INR = 1 LooP)
      };
    }
  }
}