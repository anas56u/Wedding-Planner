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
import 'package:provider_test/core/di/register_module.dart' as _i285;
import 'package:provider_test/features/auth/data/datasources/auth_local_data_source.dart'
    as _i602;
import 'package:provider_test/features/auth/data/datasources/auth_remote_data_source.dart'
    as _i126;
import 'package:provider_test/features/auth/data/repositories/auth_repository_impl.dart'
    as _i564;
import 'package:provider_test/features/auth/domain/repositories/auth_repository.dart'
    as _i655;
import 'package:provider_test/features/auth/domain/usecases/check_cached_user_usecase.dart'
    as _i944;
import 'package:provider_test/features/auth/domain/usecases/login_usecase.dart'
    as _i1073;
import 'package:provider_test/features/auth/domain/usecases/logout_usecase.dart'
    as _i637;
import 'package:provider_test/features/auth/domain/usecases/send_email_verification_usecase.dart'
    as _i24;
import 'package:provider_test/features/auth/domain/usecases/sign_up_usecase.dart'
    as _i984;
import 'package:provider_test/features/auth/presentation/providers/auth_provider.dart'
    as _i554;
import 'package:provider_test/features/hospitality_staff/data/datasources/hospitality_staff_remote_data_source.dart'
    as _i672;
import 'package:provider_test/features/hospitality_staff/data/repositories/hospitality_staff_repository_impl.dart'
    as _i329;
import 'package:provider_test/features/hospitality_staff/domain/repositories/hospitality_staff_repository.dart'
    as _i1019;
import 'package:provider_test/features/hospitality_staff/domain/usecases/get_hospitality_staff_usecase.dart'
    as _i914;
import 'package:provider_test/features/hospitality_staff/presentation/providers/hospitality_staff_provider.dart'
    as _i1031;
import 'package:provider_test/features/people_management/data/datasources/people_local_data_source.dart'
    as _i224;
import 'package:provider_test/features/people_management/data/datasources/people_remote_data_source.dart'
    as _i1055;
import 'package:provider_test/features/people_management/data/repositories/people_repository_impl.dart'
    as _i782;
import 'package:provider_test/features/people_management/domain/repositories/people_repository.dart'
    as _i446;
import 'package:provider_test/features/people_management/domain/usecases/edit_person_usecase.dart'
    as _i467;
import 'package:provider_test/features/people_management/domain/usecases/get_people_usecase.dart'
    as _i881;
import 'package:provider_test/features/people_management/domain/usecases/toggle_person_selection_usecase.dart'
    as _i368;
import 'package:provider_test/features/people_management/presentation/providers/people_provider.dart'
    as _i795;
import 'package:provider_test/features/tasks/data/datasources/tasks_local_data_source.dart'
    as _i299;
import 'package:provider_test/features/tasks/data/repositories/tasks_repository_impl.dart'
    as _i596;
import 'package:provider_test/features/tasks/domain/repositories/tasks_repository.dart'
    as _i162;
import 'package:provider_test/features/tasks/domain/usecases/add_task_usecase.dart'
    as _i1039;
import 'package:provider_test/features/tasks/domain/usecases/delete_task_usecase.dart'
    as _i630;
import 'package:provider_test/features/tasks/domain/usecases/get_tasks_usecase.dart'
    as _i177;
import 'package:provider_test/features/tasks/domain/usecases/toggle_task_completion_usecase.dart'
    as _i1051;
import 'package:provider_test/features/tasks/presentation/providers/tasks_provider.dart'
    as _i1038;
import 'package:shared_preferences/shared_preferences.dart' as _i460;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  Future<_i174.GetIt> init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) async {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final registerModule = _$RegisterModule();
    gh.factory<_i1038.TasksProvider>(() => _i1038.TasksProvider());
    gh.lazySingleton<_i519.Client>(() => registerModule.client);
    gh.lazySingleton<_i59.FirebaseAuth>(() => registerModule.firebaseAuth);
    await gh.lazySingletonAsync<_i460.SharedPreferences>(
      () => registerModule.sharedPreferences,
      preResolve: true,
    );
    gh.lazySingleton<_i224.IPeopleLocalDataSource>(
      () => _i224.PeopleLocalDataSourceImpl(),
    );
    gh.lazySingleton<_i126.AuthRemoteDataSource>(
      () =>
          _i126.AuthRemoteDataSourceImpl(firebaseAuth: gh<_i59.FirebaseAuth>()),
    );
    gh.lazySingleton<_i299.ITasksLocalDataSource>(
      () => _i299.TasksLocalDataSourceImpl(),
    );
    gh.lazySingleton<_i602.AuthLocalDataSource>(
      () => _i602.AuthLocalDataSourceImpl(
        sharedPreferences: gh<_i460.SharedPreferences>(),
      ),
    );
    gh.lazySingleton<_i672.IHospitalityStaffRemoteDataSource>(
      () => _i672.HospitalityStaffRemoteDataSourceImpl(
        client: gh<_i519.Client>(),
      ),
    );
    gh.lazySingleton<_i1055.IPeopleRemoteDataSource>(
      () => _i1055.PeopleRemoteDataSourceImpl(client: gh<_i519.Client>()),
    );
    gh.lazySingleton<_i446.IPeopleRepository>(
      () => _i782.PeopleRepositoryImpl(
        localDataSource: gh<_i224.IPeopleLocalDataSource>(),
        remoteDataSource: gh<_i1055.IPeopleRemoteDataSource>(),
      ),
    );
    gh.lazySingleton<_i162.ITasksRepository>(
      () => _i596.TasksRepositoryImpl(
        localDataSource: gh<_i299.ITasksLocalDataSource>(),
      ),
    );
    gh.lazySingleton<_i1019.IHospitalityStaffRepository>(
      () => _i329.HospitalityStaffRepositoryImpl(
        remoteDataSource: gh<_i672.IHospitalityStaffRemoteDataSource>(),
      ),
    );
    gh.lazySingleton<_i655.AuthRepository>(
      () => _i564.AuthRepositoryImpl(
        remoteDataSource: gh<_i126.AuthRemoteDataSource>(),
        localDataSource: gh<_i602.AuthLocalDataSource>(),
      ),
    );
    gh.lazySingleton<_i467.EditPersonUseCase>(
      () => _i467.EditPersonUseCase(gh<_i446.IPeopleRepository>()),
    );
    gh.lazySingleton<_i881.GetPeopleUseCase>(
      () => _i881.GetPeopleUseCase(gh<_i446.IPeopleRepository>()),
    );
    gh.lazySingleton<_i368.TogglePersonSelectionUseCase>(
      () => _i368.TogglePersonSelectionUseCase(gh<_i446.IPeopleRepository>()),
    );
    gh.lazySingleton<_i944.CheckCachedUserUseCase>(
      () => _i944.CheckCachedUserUseCase(gh<_i655.AuthRepository>()),
    );
    gh.lazySingleton<_i1073.LoginUseCase>(
      () => _i1073.LoginUseCase(gh<_i655.AuthRepository>()),
    );
    gh.lazySingleton<_i637.LogoutUseCase>(
      () => _i637.LogoutUseCase(gh<_i655.AuthRepository>()),
    );
    gh.lazySingleton<_i24.SendEmailVerificationUseCase>(
      () => _i24.SendEmailVerificationUseCase(gh<_i655.AuthRepository>()),
    );
    gh.lazySingleton<_i984.SignUpUseCase>(
      () => _i984.SignUpUseCase(gh<_i655.AuthRepository>()),
    );
    gh.factory<_i795.PeopleProvider>(
      () => _i795.PeopleProvider(
        getPeopleUseCase: gh<_i881.GetPeopleUseCase>(),
        editPersonUseCase: gh<_i467.EditPersonUseCase>(),
        togglePersonSelectionUseCase: gh<_i368.TogglePersonSelectionUseCase>(),
      ),
    );
    gh.lazySingleton<_i914.GetHospitalityStaffUseCase>(
      () => _i914.GetHospitalityStaffUseCase(
        gh<_i1019.IHospitalityStaffRepository>(),
      ),
    );
    gh.lazySingleton<_i1039.AddTaskUseCase>(
      () => _i1039.AddTaskUseCase(gh<_i162.ITasksRepository>()),
    );
    gh.lazySingleton<_i630.DeleteTaskUseCase>(
      () => _i630.DeleteTaskUseCase(gh<_i162.ITasksRepository>()),
    );
    gh.lazySingleton<_i177.GetTasksUseCase>(
      () => _i177.GetTasksUseCase(gh<_i162.ITasksRepository>()),
    );
    gh.lazySingleton<_i1051.ToggleTaskCompletionUseCase>(
      () => _i1051.ToggleTaskCompletionUseCase(gh<_i162.ITasksRepository>()),
    );
    gh.factory<_i554.AuthProvider>(
      () => _i554.AuthProvider(
        gh<_i1073.LoginUseCase>(),
        gh<_i984.SignUpUseCase>(),
        gh<_i944.CheckCachedUserUseCase>(),
        gh<_i24.SendEmailVerificationUseCase>(),
        gh<_i637.LogoutUseCase>(),
      ),
    );
    gh.factory<_i1031.HospitalityStaffProvider>(
      () => _i1031.HospitalityStaffProvider(
        getHospitalityStaffUseCase: gh<_i914.GetHospitalityStaffUseCase>(),
      ),
    );
    return this;
  }
}

class _$RegisterModule extends _i285.RegisterModule {}
