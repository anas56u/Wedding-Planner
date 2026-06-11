import 'package:flutter/widgets.dart';
import 'package:injectable/injectable.dart';
import 'package:provider_test/features/hospitality_staff/data/models/hospitality_staff_model.dart';
import 'package:provider_test/features/hospitality_staff/domain/usecases/get_hospitality_staff_usecase.dart';

@injectable
class HospitalityStaffProvider extends ChangeNotifier {
  final GetHospitalityStaffUseCase getHospitalityStaffUseCase;

  HospitalityStaffProvider({required this.getHospitalityStaffUseCase});

  List<HospitalityStaffModel> _staffList = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<HospitalityStaffModel> get staffList => _staffList;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void updateStaffMemberLocally(HospitalityStaffModel updatedStaff) {
    final index = _staffList.indexWhere(
      (staffMember) => staffMember.id == updatedStaff.id,
    );

    if (index != -1) {
      _staffList[index] = updatedStaff;
      notifyListeners();
    }
  }

  Future<void> fetchStaff() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final result = await getHospitalityStaffUseCase.execute();
      result.fold(
        (failure) => _errorMessage = failure.message,
        (staffList) {
          _staffList = staffList
              .map((entity) => HospitalityStaffModel(
                    id: entity.id,
                    firstName: entity.firstName,
                    lastName: entity.lastName,
                    age: entity.age,
                    gender: entity.gender,
                    email: entity.email,
                    phone: entity.phone,
                    imageUrl: entity.imageUrl,
                  ))
              .toList();
        },
      );
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

