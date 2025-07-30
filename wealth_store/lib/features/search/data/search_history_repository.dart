import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'search_history_repository.g.dart';

class SearchHistoryRepository {
  static const String _searchHistoryKey = 'search_history';
  static const String _popularSearchesKey = 'popular_searches';
  static const int _maxHistoryItems = 10;

  // Get recent search history
  Future<List<String>> getSearchHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson = prefs.getStringList(_searchHistoryKey);
      return historyJson ?? [];
    } catch (e) {
      return [];
    }
  }

  // Add search to history
  Future<void> addToHistory(String searchTerm) async {
    if (searchTerm.trim().isEmpty) return;
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final history = await getSearchHistory();
      
      // Remove if already exists
      history.remove(searchTerm);
      
      // Add to beginning
      history.insert(0, searchTerm);
      
      // Keep only max items
      if (history.length > _maxHistoryItems) {
        history.removeRange(_maxHistoryItems, history.length);
      }
      
      await prefs.setStringList(_searchHistoryKey, history);
    } catch (e) {
      // Handle error silently
    }
  }

  // Clear search history
  Future<void> clearHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_searchHistoryKey);
    } catch (e) {
      // Handle error silently
    }
  }

  // Get popular searches (mock data for now)
  Future<List<String>> getPopularSearches() async {
    return [
      'iPhone',
      'Samsung Galaxy',
      'MacBook',
      'AirPods',
      'iPad',
      'Gaming Laptop',
      'Wireless Headphones',
      'Smart Watch',
    ];
  }

  // Get search suggestions based on query
  Future<List<String>> getSearchSuggestions(String query) async {
    if (query.trim().isEmpty) return [];
    
    final history = await getSearchHistory();
    final popular = await getPopularSearches();
    
    final suggestions = <String>[];
    
    // Add matching history items
    for (final item in history) {
      if (item.toLowerCase().contains(query.toLowerCase())) {
        suggestions.add(item);
      }
    }
    
    // Add matching popular searches
    for (final item in popular) {
      if (item.toLowerCase().contains(query.toLowerCase()) && 
          !suggestions.contains(item)) {
        suggestions.add(item);
      }
    }
    
    return suggestions.take(5).toList();
  }
}

@riverpod
SearchHistoryRepository searchHistoryRepository(SearchHistoryRepositoryRef ref) {
  return SearchHistoryRepository();
}