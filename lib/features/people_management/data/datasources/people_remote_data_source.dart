import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:injectable/injectable.dart';
import '../models/person_model.dart';

abstract class IPeopleRemoteDataSource {
  Future<List<PersonModel>> getPeopleFromApi();
}

@LazySingleton(as: IPeopleRemoteDataSource)
class PeopleRemoteDataSourceImpl implements IPeopleRemoteDataSource {
  final http.Client client;

  PeopleRemoteDataSourceImpl({required this.client});

  @override
  Future<List<PersonModel>> getPeopleFromApi() async {
    final url = Uri.parse('https://dummyjson.com/users');
    final response = await client.get(url);

    if (response.statusCode == 200) {
      return await compute(_parseApiPeople, response.body);
    } else {
      throw Exception('فشل في جلب البيانات من الخادم');
    }
  }
}

// 🌟 دالة التحويل المعزولة
List<PersonModel> _parseApiPeople(String jsonString) {
  final Map<String, dynamic> data = json.decode(jsonString);
  final List<dynamic> usersList = data['users'];
  return usersList.map((jsonItem) => PersonModel.fromJson(jsonItem)).toList();
}