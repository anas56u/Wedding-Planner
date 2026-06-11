// مسار الملف: lib/features/people_management/data/models/person_model.dart

import '../../domain/entities/person_entity.dart';

class PersonModel extends PersonEntity {
  PersonModel({
    required super.id,
    required super.name,
    required super.age,
    super.isSelected = false,
  });

  factory PersonModel.fromJson(Map<String, dynamic> json) {
    final String personName = json.containsKey('firstName')
        ? '${json['firstName']} ${json['lastName']}'
        : json['name'] ?? 'بدون اسم';

    return PersonModel(
      id: json['id'],
      name: personName,
      age: json['age'] ?? 0,
      isSelected: json['isSelected'] ?? false,
    );
  }

  factory PersonModel.fromEntity(PersonEntity entity) {
    return PersonModel(
      id: entity.id,
      name: entity.name,
      age: entity.age,
      isSelected: entity.isSelected,
    );
  }
}