import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import 'package:provider_test/core/errors/Failure.dart';
import '../../domain/entities/person_entity.dart';
import '../../domain/usecases/edit_person_usecase.dart';
import '../../domain/usecases/get_people_usecase.dart';
import '../../domain/usecases/toggle_person_selection_usecase.dart';

enum SortType { nameAscending, ageAscending, ageDescending }

@injectable
class PeopleProvider extends ChangeNotifier {
  final GetPeopleUseCase getPeopleUseCase;
  final EditPersonUseCase editPersonUseCase;
  final TogglePersonSelectionUseCase togglePersonSelectionUseCase;

  PeopleProvider({
    required this.getPeopleUseCase,
    required this.editPersonUseCase,
    required this.togglePersonSelectionUseCase,
  });

  // 🌟 القائمة الآن نقية وتستخدم Entity
  List<PersonEntity> _allPeople = [];
  bool _isLoading = true;
  String? _errorMessage;
  SortType _currentSort = SortType.nameAscending;
  String _searchQuery = '';
  bool _isAvailableVisible = true;
  bool _isCompletedVisible = true;

  String get searchQuery => _searchQuery;
  List<PersonEntity> get allPeople => _allPeople;
  bool get isAvailableVisible => _isAvailableVisible;
  bool get isCompletedVisible => _isCompletedVisible;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  SortType get currentSort => _currentSort;

  // 🌟 دالة الجلب الموحدة (الـ Repository سيتصرف داخلياً)
  Future<void> loadData() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await getPeopleUseCase.execute();

    result.fold(
      (Failure failure) {
        _errorMessage = failure.message;
        _isLoading = false;
        notifyListeners();
      },
      (List<PersonEntity> people) {
        _allPeople = people;
        _applySorting();
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  Future<void> editPerson(int id, String newName, int newAge) async {
    final result = await editPersonUseCase.execute(id, newName, newAge);
    result.fold(
      (Failure failure) => _errorMessage = failure.message,
      (_) {
        final index = _allPeople.indexWhere((p) => p.id == id);
        if (index != -1) {
          _allPeople[index] = _allPeople[index].copyWith(name: newName, age: newAge);
          _applySorting();
          notifyListeners();
        }
      },
    );
  }

  Future<void> toggleSelection(int personId) async {
    final result = await togglePersonSelectionUseCase.execute(personId);
    result.fold(
      (Failure failure) => _errorMessage = failure.message,
      (_) {
        final index = _allPeople.indexWhere((p) => p.id == personId);
        if (index != -1) {
          final current = _allPeople[index];
          _allPeople[index] = current.copyWith(isSelected: !current.isSelected);
          notifyListeners();
        }
      },
    );
  }

  void updateSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void toggleAvailableVisibility(bool value) {
    _isAvailableVisible = value;
    notifyListeners();
  }

  void toggleCompletedVisibility(bool value) {
    _isCompletedVisible = value;
    notifyListeners();
  }

  void changeSort(SortType sortType) {
    _currentSort = sortType;
    _applySorting();
    notifyListeners();
  }

  List<PersonEntity> get availablePeople {
    return _allPeople.where((person) {
      final matchesSearch = person.name.toLowerCase().contains(_searchQuery.toLowerCase());
      return !person.isSelected && matchesSearch;
    }).toList();
  }

  List<PersonEntity> get selectedPeople {
    return _allPeople.where((person) {
      final matchesSearch = person.name.toLowerCase().contains(_searchQuery.toLowerCase());
      return person.isSelected && matchesSearch;
    }).toList();
  }

  void _applySorting() {
    switch (_currentSort) {
      case SortType.nameAscending:
        _allPeople.sort((a, b) => a.name.compareTo(b.name));
        break;
      case SortType.ageAscending:
        _allPeople.sort((a, b) => a.age.compareTo(b.age));
        break;
      case SortType.ageDescending:
        _allPeople.sort((a, b) => b.age.compareTo(a.age));
        break;
    }
  }
}