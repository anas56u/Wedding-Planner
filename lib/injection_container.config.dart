// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:firebase_auth/firebase_auth.dart' as _i59;
import 'package:get_it/get_it.dart' as _i174;
import 'package:http/http.dart' as _i519;
import 'package:injectable/injectable.dart' as _i526;
import 'package:shared_preferences/shared_preferences.dart' as _i460;

import 'core/di/register_module.dart' as _i854;
import 'features/auth/data/datasources/auth_local_data_source.dart' as _i791;
import 'features/auth/data/datasources/auth_remote_data_source.dart' as _i767;
import 'features/auth/data/repositories/auth_repository_impl.dart' as _i111;
import 'features/auth/domain/repositories/auth_repository.dart' as _i1015;
import 'features/auth/domain/usecases/check_cached_user_usecase.dart' as _i338;
import 'features/auth/domain/usecases/login_usecase.dart' as _i206;
import 'features/auth/domain/usecases/logout_usecase.dart' as _i824;
import 'features/auth/domain/usecases/send_email_verification_usecase.dart'
    as _i746;
import 'features/auth/domain/usecases/sign_up_usecase.dart' as _i261;
import 'features/auth/presentation/providers/auth_provider.dart' as _i220;
import 'features/hospitality_staff/data/datasources/hospitality_staff_remote_data_source.dart'
    as _i777;
import 'features/hospitality_staff/data/repositories/hospitality_staff_repository_impl.dart'
    as _i310;
import 'features/hospitality_staff/domain/repositories/hospitality_staff_repository.dart'
    as _i448;
import 'features/hospitality_staff/domain/usecases/get_hospitality_staff_usecase.dart'
    as _i140;
import 'features/hospitality_staff/presentation/providers/hospitality_staff_provider.dart'
    as _i959;
import 'features/people_management/data/datasources/people_local_data_source.dart'
    as _i114;
import 'features/people_management/data/datasources/people_remote_data_source.dart'
    as _i800;
import 'features/people_management/data/repositories/people_repository_impl.dart'
    as _i1029;
import 'features/people_management/domain/repositories/people_repository.dart'
    as _i350;
import 'features/people_management/domain/usecases/edit_person_usecase.dart'
    as _i193;
import 'features/people_management/domain/usecases/get_people_usecase.dart'
    as _i874;
import 'features/people_management/domain/usecases/toggle_person_selection_usecase.dart'
    as _i413;
import 'features/people_management/presentation/providers/people_provider.dart'
    as _i18;
import 'features/tasks/data/datasources/tasks_local_data_source.dart' as _i765;
import 'features/tasks/data/repositories/tasks_repository_impl.dart' as _i411;
import 'features/tasks/domain/repositories/tasks_repository.dart' as _i675;
import 'features/tasks/domain/usecases/add_task_usecase.dart' as _i923;
import 'features/tasks/domain/usecases/delete_task_usecase.dart' as _i821;
import 'features/tasks/domain/usecases/get_tasks_usecase.dart' as _i951;
import 'features/tasks/domain/usecases/toggle_task_completion_usecase.dart'
    as _i692;
import 'features/tasks/presentation/providers/tasks_provider.dart' as _i789;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  Future<_i174.GetIt> init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) async {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final registerModule = _$RegisterModule();
    gh.factory<_i789.TasksProvider>(() => _i789.TasksProvider());
    gh.lazySingleton<_i519.Client>(() => registerModule.client);
    gh.lazySingleton<_i59.FirebaseAuth>(() => registerModule.firebaseAuth);
    await gh.lazySingletonAsync<_i460.SharedPreferences>(
      () => registerModule.sharedPreferences,
      preResolve: true,
    );
    gh.lazySingleton<_i114.IPeopleLocalDataSource>(
      () => _i114.PeopleLocalDataSourceImpl(),
    );
    gh.lazySingleton<_i765.ITasksLocalDataSource>(
      () => _i765.TasksLocalDataSourceImpl(),
    );
    gh.lazySingleton<_i1015.AuthRepository>(
      () => _i111.AuthRepositoryImpl(
        remoteDataSource: gh<_i767.AuthRemoteDataSource>(),
        localDataSource: gh<_i791.AuthLocalDataSource>(),
      ),
    );
    gh.lazySingleton<_i338.CheckCachedUserUseCase>(
      () => _i338.CheckCachedUserUseCase(gh<_i1015.AuthRepository>()),
    );
    gh.lazySingleton<_i206.LoginUseCase>(
      () => _i206.LoginUseCase(gh<_i1015.AuthRepository>()),
    );
    gh.lazySingleton<_i824.LogoutUseCase>(
      () => _i824.LogoutUseCase(gh<_i1015.AuthRepository>()),
    );
    gh.lazySingleton<_i746.SendEmailVerificationUseCase>(
      () => _i746.SendEmailVerificationUseCase(gh<_i1015.AuthRepository>()),
    );
    gh.lazySingleton<_i261.SignUpUseCase>(
      () => _i261.SignUpUseCase(gh<_i1015.AuthRepository>()),
    );
    gh.lazySingleton<_i777.IHospitalityStaffRemoteDataSource>(
      () => _i777.HospitalityStaffRemoteDataSourceImpl(
        client: gh<_i519.Client>(),
      ),
    );
    gh.lazySingleton<_i800.IPeopleRemoteDataSource>(
      () => _i800.PeopleRemoteDataSourceImpl(client: gh<_i519.Client>()),
    );
    gh.lazySingleton<_i350.IPeopleRepository>(
      () => _i1029.PeopleRepositoryImpl(
        localDataSource: gh<_i114.IPeopleLocalDataSource>(),
        remoteDataSource: gh<_i800.IPeopleRemoteDataSource>(),
      ),
    );
    gh.lazySingleton<_i675.ITasksRepository>(
      () => _i411.TasksRepositoryImpl(
        localDataSource: gh<_i765.ITasksLocalDataSource>(),
      ),
    );
    gh.lazySingleton<_i448.IHospitalityStaffRepository>(
      () => _i310.HospitalityStaffRepositoryImpl(
        remoteDataSource: gh<_i777.IHospitalityStaffRemoteDataSource>(),
      ),
    );
    gh.factory<_i220.AuthProvider>(
      () => _i220.AuthProvider(
        gh<_i206.LoginUseCase>(),
        gh<_i261.SignUpUseCase>(),
        gh<_i338.CheckCachedUserUseCase>(),
        gh<_i746.SendEmailVerificationUseCase>(),
        gh<_i824.LogoutUseCase>(),
      ),
    );
    gh.lazySingleton<_i193.EditPersonUseCase>(
      () => _i193.EditPersonUseCase(gh<_i350.IPeopleRepository>()),
    );
    gh.lazySingleton<_i874.GetPeopleUseCase>(
      () => _i874.GetPeopleUseCase(gh<_i350.IPeopleRepository>()),
    );
    gh.lazySingleton<_i413.TogglePersonSelectionUseCase>(
      () => _i413.TogglePersonSelectionUseCase(gh<_i350.IPeopleRepository>()),
    );
    gh.factory<_i18.PeopleProvider>(
      () => _i18.PeopleProvider(
        getPeopleUseCase: gh<_i874.GetPeopleUseCase>(),
        editPersonUseCase: gh<_i193.EditPersonUseCase>(),
        togglePersonSelectionUseCase: gh<_i413.TogglePersonSelectionUseCase>(),
      ),
    );
    gh.lazySingleton<_i140.GetHospitalityStaffUseCase>(
      () => _i140.GetHospitalityStaffUseCase(
        gh<_i448.IHospitalityStaffRepository>(),
      ),
    );
    gh.lazySingleton<_i923.AddTaskUseCase>(
      () => _i923.AddTaskUseCase(gh<_i675.ITasksRepository>()),
    );
    gh.lazySingleton<_i821.DeleteTaskUseCase>(
      () => _i821.DeleteTaskUseCase(gh<_i675.ITasksRepository>()),
    );
    gh.lazySingleton<_i951.GetTasksUseCase>(
      () => _i951.GetTasksUseCase(gh<_i675.ITasksRepository>()),
    );
    gh.lazySingleton<_i692.ToggleTaskCompletionUseCase>(
      () => _i692.ToggleTaskCompletionUseCase(gh<_i675.ITasksRepository>()),
    );
    gh.factory<_i959.HospitalityStaffProvider>(
      () => _i959.HospitalityStaffProvider(
        getHospitalityStaffUseCase: gh<_i140.GetHospitalityStaffUseCase>(),
      ),
    );
    return this;
  }
}

class _$RegisterModule extends _i854.RegisterModule {}
