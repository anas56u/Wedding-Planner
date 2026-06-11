import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:injectable/injectable.dart';
import 'package:provider_test/features/hospitality_staff/data/models/hospitality_staff_model.dart';

abstract class IHospitalityStaffRemoteDataSource {
  Future<List<HospitalityStaffModel>> getStaff();
}

@LazySingleton(as: IHospitalityStaffRemoteDataSource)
class HospitalityStaffRemoteDataSourceImpl
    implements IHospitalityStaffRemoteDataSource {
  final http.Client client;

  HospitalityStaffRemoteDataSourceImpl({required this.client});

  @override
  Future<List<HospitalityStaffModel>> getStaff() async {
    final url = Uri.parse('https://dummyjson.com/users');
    final response = await client.get(
      url,
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List<dynamic> staffList = data['users'];

      return staffList
          .map(
            (jsonItem) => HospitalityStaffModel.fromJson(
              jsonItem as Map<String, dynamic>,
            ),
          )
          .where((person) => person.gender == 'female')
          .toList();
    } else {
      throw Exception('Failed to load hospitality staff from API');
    }
  }
}
