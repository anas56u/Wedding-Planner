import '../../domain/entities/task_entity.dart';

class TaskModel extends TaskEntity {
  TaskModel({
    required super.id,
    required super.title,
    super.isCompleted,
    super.assignedPeopleIds,
    super.assignedPeopleNames,
  });

  factory TaskModel.fromEntity(TaskEntity entity) {
    return TaskModel(
      id: entity.id,
      title: entity.title,
      isCompleted: entity.isCompleted,
      assignedPeopleIds: entity.assignedPeopleIds,
      assignedPeopleNames: entity.assignedPeopleNames,
    );
  }
}