import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:provider_test/core/errors/failure.dart';
import 'package:provider_test/features/hospitality_staff/domain/entities/hospitality_staff_entity.dart';
import 'package:provider_test/features/hospitality_staff/domain/repositories/hospitality_staff_repository.dart';

@lazySingleton
class GetHospitalityStaffUseCase {
  final IHospitalityStaffRepository repository;

  GetHospitalityStaffUseCase(this.repository);

  Future<Either<Failure, List<HospitalityStaffEntity>>> execute() async {
    return await repository.getStaff();
  }
}
