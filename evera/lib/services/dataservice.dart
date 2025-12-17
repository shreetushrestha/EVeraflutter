
import 'dart:convert';

import 'package:evera/models/evmodel.dart';
import 'package:flutter/services.dart';

class DataService {
  static List<EvModel>? _cachedItems;

  /// Loads data once from assets/data.json and caches it
  static Future<List<EvModel>> loadItems() async {
    if (_cachedItems != null) return _cachedItems!;

    final String response = await rootBundle.loadString('assets/data/data.json');
    final List jsonList = json.decode(response);

    _cachedItems = jsonList.map((e) => EvModel.fromJson(e)).toList();
    return _cachedItems!;
  }
}