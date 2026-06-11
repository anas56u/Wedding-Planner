import 'package:dartz/dartz.dart';
import 'package:provider_test/core/errors/Failure.dart';
import 'package:provider_test/features/hospitality_staff/domain/entities/hospitality_staff_entity.dart';

abstract class IHospitalityStaffRepository {
  Future<Either<Failure, List<HospitalityStaffEntity>>> getStaff();
}
