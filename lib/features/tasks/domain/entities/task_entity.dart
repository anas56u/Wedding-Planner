class TaskEntity {
  final String id;
  final String title;
  final bool isCompleted;
  final List<int> assignedPeopleIds;
  final List<String> assignedPeopleNames;

  TaskEntity({
    required this.id,
    required this.title,
    this.isCompleted = false,
    this.assignedPeopleIds = const [],
    this.assignedPeopleNames = const [],
  });

  TaskEntity copyWith({
    String? id,
    String? title,
    bool? isCompleted,
    List<int>? assignedPeopleIds,
    List<String>? assignedPeopleNames,
  }) {
    return TaskEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
      assignedPeopleIds: assignedPeopleIds ?? this.assignedPeopleIds,
      assignedPeopleNames: assignedPeopleNames ?? this.assignedPeopleNames,
    );
  }
}