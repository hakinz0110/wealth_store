import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'search_history_provider.g.dart';

@riverpod
class SearchHistory extends _$SearchHistory {
  static const _historyKey = 'search_history';
  static const _maxHistoryItems = 10;
  
  @override
  List<String> build() {
    _loadSearchHistory();
    return [];
  }
  
  Future<void> _loadSearchHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final history = prefs.getStringList(_historyKey) ?? [];
    state = history;
  }
  
  Future<void> _saveSearchHistory(List<String> history) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_historyKey, history);
    state = history;
  }
  
  Future<void> addSearch(String query) async {
    if (query.trim().isEmpty) return;
    
    // Remove if already exists to avoid duplicates
    final newHistory = [...state];
    newHistory.remove(query);
    
    // Add to the beginning of the list
    newHistory.insert(0, query);
    
    // Limit the number of items
    if (newHistory.length > _maxHistoryItems) {
      newHistory.removeLast();
    }
    
    await _saveSearchHistory(newHistory.cast<String>());
  }
  
  Future<void> removeSearch(String query) async {
    final newHistory = [...state];
    newHistory.remove(query);
    await _saveSearchHistory(newHistory.cast<String>());
  }
  
  Future<void> clearHistory() async {
    await _saveSearchHistory([]);
  }
} 