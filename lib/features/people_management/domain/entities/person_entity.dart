class PersonEntity {
  final int id;
  final String name;
  final int age;
  final bool isSelected;

  PersonEntity({
    required this.id,
    required this.name,
    required this.age,
    this.isSelected = false,
  });

  PersonEntity copyWith({
    int? id,
    String? name,
    int? age,
    bool? isSelected,
  }) {
    return PersonEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      age: age ?? this.age,
      isSelected: isSelected ?? this.isSelected,
    );
  }
}