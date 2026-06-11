import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:provider_test/core/errors/Failure.dart';
import '../../domain/entities/hospitality_staff_entity.dart';
import '../../domain/repositories/hospitality_staff_repository.dart';
import '../datasources/hospitality_staff_remote_data_source.dart';

@LazySingleton(as: IHospitalityStaffRepository)
class HospitalityStaffRepositoryImpl implements IHospitalityStaffRepository {
  final IHospitalityStaffRemoteDataSource remoteDataSource;

  HospitalityStaffRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<HospitalityStaffEntity>>> getStaff() async {
    try {
      final remoteStaff = await remoteDataSource.getStaff();
      return Right(List<HospitalityStaffEntity>.from(remoteStaff));
    } on Exception catch (e) {
      return Left(ServerFailure('فشل في جلب البيانات: $e'));
    } catch (e) {
      return Left(ServerFailure('حدث خطأ غير متوقع: $e'));
    }
  }
}
