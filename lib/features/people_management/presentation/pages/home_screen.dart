import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/entities/person_entity.dart';
import 'package:provider_test/features/tasks/presentation/providers/tasks_provider.dart';
import '../pages/person_details_screen.dart';
import '../providers/people_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PeopleProvider>().loadData();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'guests.title'.tr(),
            style: const TextStyle(fontSize: 18),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh, color: Colors.blue),
              onPressed: () {
                context.read<PeopleProvider>().loadData();
              },
            ),
            Consumer<PeopleProvider>(
              builder: (context, provider, child) {
                return DropdownButton<SortType>(
                  value: provider.currentSort,
                  dropdownColor: Colors.white,
                  icon: const Icon(Icons.sort),
                  underline: const SizedBox(),
                  onChanged: (SortType? newValue) {
                    if (newValue != null) {
                      context.read<PeopleProvider>().changeSort(newValue);
                    }
                  },
                  items: [
                    DropdownMenuItem(
                      value: SortType.nameAscending,
                      child: Text('guests.pending'.tr()),
                    ),
                    DropdownMenuItem(
                      value: SortType.ageAscending,
                      child: Text('guests.attended'.tr()),
                    ),
                    DropdownMenuItem(
                      value: SortType.ageDescending,
                      child: Text('guests.attended'.tr()),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(width: 8),
          ],
          bottom: TabBar(
            indicatorColor: Colors.white,
            indicatorWeight: 3,
            // ✅ تم إضافة const هنا لأن الستايل ثابت
            labelStyle: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
            tabs: [
              // ✅ تم إضافة const للأيقونات فقط، وإزالتها من الـ Tab لأن النص متغير
              Tab(icon: const Icon(Icons.list), text: 'guests.pending'.tr()),
              Tab(
                icon: const Icon(Icons.done_all),
                text: 'guests.attended'.tr(),
              ),
            ],
          ),
        ),

        body: Consumer<PeopleProvider>(
          builder: (context, provider, child) {
            if (provider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (provider.errorMessage != null) {
              return Center(
                child: Text(
                  provider.errorMessage!,
                  style: const TextStyle(color: Colors.red, fontSize: 16),
                ),
              );
            }

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'guests.search_hint'.tr(),
                      prefixIcon: const Icon(Icons.search, color: Colors.blue),
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      contentPadding: const EdgeInsets.symmetric(vertical: 0),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onChanged: (String value) {
                      context.read<PeopleProvider>().updateSearchQuery(value);
                    },
                  ),
                ),

                Expanded(
                  child: TabBarView(
                    children: [
                      _buildPeopleList(
                        context: context,
                        people: provider.availablePeople,
                        isCompletedTab: false,
                        isVisible: provider.isAvailableVisible,
                      ),
                      _buildPeopleList(
                        context: context,
                        people: provider.selectedPeople,
                        isCompletedTab: true,
                        isVisible: provider.isCompletedVisible,
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Future<void> _confirmAction(
    BuildContext context,
    PersonEntity person,
    bool isCompletedTab,
  ) async {
    // ✅ تحويل نصوص الـ Dialog لتدعم الترجمة
    final String actionText = isCompletedTab
        ? 'guests.undo_attended'.tr()
        : 'guests.mark_attended'.tr();
    final bool? userConfirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'guests.confirm_action'.tr(),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Text(
            'guests.confirm_message'.tr(
              namedArgs: {'action': actionText, 'name': person.name},
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(
                'common.cancel'.tr(),
                style: const TextStyle(color: Colors.grey),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: isCompletedTab ? Colors.red : Colors.blue,
                foregroundColor: Colors.white,
              ),
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: Text('common.confirm'.tr()),
            ),
          ],
        );
      },
    );

    if (userConfirmed == true && context.mounted) {
      context.read<PeopleProvider>().toggleSelection(person.id);
    }
  }

  Widget _buildPeopleList({
    required BuildContext context,
    required List<PersonEntity> people,
    required bool isCompletedTab,
    required bool isVisible,
  }) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // ✅ استخدام namedArgs لتمرير العدد المتغير إلى الترجمة
              Text(
                isCompletedTab
                    ? 'guests.attended_count'.tr(
                        namedArgs: {'count': people.length.toString()},
                      )
                    : 'guests.pending_count'.tr(
                        namedArgs: {'count': people.length.toString()},
                      ),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                children: [
                  const Icon(Icons.visibility, color: Colors.grey, size: 20),
                  Switch(
                    value: isVisible,
                    activeColor: isCompletedTab ? Colors.green : Colors.blue,
                    onChanged: (bool value) {
                      if (isCompletedTab) {
                        context
                            .read<PeopleProvider>()
                            .toggleCompletedVisibility(value);
                      } else {
                        context
                            .read<PeopleProvider>()
                            .toggleAvailableVisibility(value);
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
        ),

        if (!isVisible)
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.visibility_off,
                    size: 80,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'guests.hidden_list'.tr(),
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          Expanded(
            child: people.isEmpty
                ? Center(
                    child: Text(
                      isCompletedTab
                          ? 'guests.no_attended'.tr()
                          : 'guests.no_pending'.tr(),
                      style: const TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: people.length,
                    itemBuilder: (context, index) {
                      final person = people[index];

                      return Dismissible(
                        key: ValueKey('person_${person.id}'),
                        direction: DismissDirection.startToEnd,
                        background: Container(
                          margin: const EdgeInsetsDirectional.symmetric(
                            vertical: 6,
                            horizontal: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.orange.shade400,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          alignment: AlignmentDirectional.centerEnd,
                          padding: const EdgeInsetsDirectional.only(end: 20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                'guests.reminder_task'.tr(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(width: 10),
                              const Icon(
                                Icons.alarm_add,
                                color: Colors.white,
                                size: 30,
                              ),
                            ],
                          ),
                        ),
                        confirmDismiss: (direction) async {
                          context.read<TasksProvider>().addTask(
                            'guests.call_confirmation'.tr(
                              namedArgs: {'name': person.name},
                            ),
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'guests.reminder_created'.tr(
                                  namedArgs: {'name': person.name},
                                ),
                              ),
                              backgroundColor: Colors.green,
                              duration: const Duration(seconds: 2),
                            ),
                          );
                          return false;
                        },
                        child: Card(
                          elevation: 2,
                          margin: const EdgeInsets.symmetric(
                            vertical: 6,
                            horizontal: 4,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => PersonDetailsScreen(
                                    initialPerson: person,
                                  ),
                                ),
                              );
                            },
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            leading: CircleAvatar(
                              backgroundColor: isCompletedTab
                                  ? Colors.green.shade100
                                  : Colors.blue.shade100,
                              child: Icon(
                                isCompletedTab ? Icons.check : Icons.person,
                                color: isCompletedTab
                                    ? Colors.green
                                    : Colors.blue,
                              ),
                            ),
                            title: Text(
                              person.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            subtitle: Text(
                              '${'guests.age'.tr()}: ${person.age}',
                            ),
                            trailing: isCompletedTab
                                ? OutlinedButton.icon(
                                    onPressed: () => _confirmAction(
                                      context,
                                      person,
                                      isCompletedTab,
                                    ),
                                    icon: const Icon(
                                      Icons.undo,
                                      size: 18,
                                      color: Colors.red,
                                    ),
                                    // ✅ استخدام كلمة "تراجع" أو "Undo" من الترجمة
                                    label: Text(
                                      'guests.undo_attended'.tr(),
                                      style: const TextStyle(color: Colors.red),
                                    ),
                                    style: OutlinedButton.styleFrom(
                                      side: const BorderSide(color: Colors.red),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                  )
                                : ElevatedButton.icon(
                                    onPressed: () => _confirmAction(
                                      context,
                                      person,
                                      isCompletedTab,
                                    ),
                                    icon: const Icon(Icons.check, size: 18),
                                    // ✅ استخدام كلمة "حاضر" أو "Check-in" من الترجمة
                                    label: Text('guests.mark_attended'.tr()),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blue,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                  ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
      ],
    );
  }
}
