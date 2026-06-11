import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import '../models/person_model.dart';

abstract class IPeopleLocalDataSource {
  Future<List<PersonModel>> getPeople();
  Future<void> editPerson(int id, String newName, int newAge);
  Future<void> toggleSelection(int id);
}

@LazySingleton(as: IPeopleLocalDataSource)
class PeopleLocalDataSourceImpl implements IPeopleLocalDataSource {
  List<PersonModel> _cachedPeople = [];

  @override
  Future<List<PersonModel>> getPeople() async {
    if (_cachedPeople.isNotEmpty) {
      return _cachedPeople;
    }

    try {
      final String response = await rootBundle.loadString('assets/data.json');
      
      _cachedPeople = await compute(_parsePeople, response);
      
      return _cachedPeople;
    } catch (e) {
      throw Exception('فشل في قراءة ملف الأشخاص: $e');
    }
  }

  @override
  Future<void> editPerson(int id, String newName, int newAge) async {
    final index = _cachedPeople.indexWhere((p) => p.id == id);
    if (index != -1) {
      final current = _cachedPeople[index];
      _cachedPeople[index] = PersonModel.fromEntity(
        current.copyWith(name: newName, age: newAge),
      );
    } else {
      throw Exception('الشخص غير موجود');
    }
  }

  @override
  Future<void> toggleSelection(int id) async {
    final index = _cachedPeople.indexWhere((p) => p.id == id);
    if (index != -1) {
      final current = _cachedPeople[index];
      _cachedPeople[index] = PersonModel.fromEntity(
        current.copyWith(isSelected: !current.isSelected),
      );
    } else {
      throw Exception('الشخص غير موجود');
    }
  }
}

List<PersonModel> _parsePeople(String jsonString) {
  final List<dynamic> data = json.decode(jsonString);
  return data.map((jsonItem) => PersonModel.fromJson(jsonItem)).toList();
}