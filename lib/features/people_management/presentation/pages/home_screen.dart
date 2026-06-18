import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/entities/person_entity.dart';
import 'package:provider_test/features/tasks/presentation/providers/tasks_provider.dart';
import '../pages/person_details_screen.dart';
import '../providers/people_provider.dart';
import '../widgets/people_list.dart';
import '../widgets/confirm_action_dialog.dart';

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
    final theme = Theme.of(context);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          title: Text(
            'guests.title'.tr(),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          actions: [
            // زر التحديث بتصميم أنيق
            IconButton(
              icon: Icon(Icons.refresh_rounded, color: theme.colorScheme.primary),
              onPressed: () {
                context.read<PeopleProvider>().loadData();
              },
            ),
            // قائمة الفرز (Sorting) - تم إصلاح خطأ النصوص هنا!
            Consumer<PeopleProvider>(
              builder: (context, provider, child) {
                return DropdownButtonHideUnderline(
                  child: DropdownButton<SortType>(
                    value: provider.currentSort,
                    dropdownColor: theme.cardTheme.color,
                    icon: Icon(Icons.sort_rounded, color: theme.colorScheme.primary),
                    borderRadius: BorderRadius.circular(16),
                    onChanged: (SortType? newValue) {
                      if (newValue != null) {
                        context.read<PeopleProvider>().changeSort(newValue);
                      }
                    },
                    items: [
                      DropdownMenuItem(
                        value: SortType.nameAscending,
                        child: Text('common.name'.tr(), style: TextStyle(color: theme.colorScheme.primary)),
                      ),
                      DropdownMenuItem(
                        value: SortType.ageAscending,
                        child: Text('العمر (تصاعدي)', style: TextStyle(color: theme.colorScheme.primary)), // يمكن إضافتها للترجمة لاحقاً
                      ),
                      DropdownMenuItem(
                        value: SortType.ageDescending,
                        child: Text('العمر (تنازلي)', style: TextStyle(color: theme.colorScheme.primary)),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(width: 8),
          ],
          // تصميم عصري للـ TabBar
          bottom: TabBar(
            indicatorColor: theme.colorScheme.secondary, // الخط السفلي باللون الذهبي
            indicatorWeight: 4,
            indicatorSize: TabBarIndicatorSize.tab,
            labelColor: theme.colorScheme.secondary,
            unselectedLabelColor: Colors.grey.shade500,
            labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            tabs: [
              Tab(icon: const Icon(Icons.pending_actions_rounded), text: 'guests.pending'.tr()),
              Tab(icon: const Icon(Icons.how_to_reg_rounded), text: 'guests.attended'.tr()),
            ],
          ),
        ),
        body: Consumer<PeopleProvider>(
          builder: (context, provider, child) {
            if (provider.isLoading) {
              return Center(
                child: CircularProgressIndicator(color: theme.colorScheme.secondary),
              );
            }

            if (provider.errorMessage != null) {
              return Center(
                child: Text(
                  provider.errorMessage!,
                  style: TextStyle(color: Colors.red.shade400, fontSize: 16),
                ),
              );
            }

            return Column(
              children: [
                // شريط البحث المطور (Modern Search Bar)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    style: TextStyle(color: theme.colorScheme.primary),
                    decoration: InputDecoration(
                      hintText: 'guests.search_hint'.tr(),
                      hintStyle: TextStyle(color: Colors.grey.shade400),
                      prefixIcon: Icon(Icons.search_rounded, color: theme.colorScheme.secondary),
                      filled: true,
                      fillColor: theme.cardTheme.color,
                      contentPadding: const EdgeInsets.symmetric(vertical: 0),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20), // حواف دائرية بالكامل
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide(color: theme.colorScheme.secondary, width: 1.5),
                      ),
                    ),
                    onChanged: (String value) {
                      context.read<PeopleProvider>().updateSearchQuery(value);
                    },
                  ),
                ),

                // عرض القوائم بناءً على الـ Tab المختار
                Expanded(
                  child: TabBarView(
                    children: [
                      PeopleList(
                        people: provider.availablePeople,
                        isCompletedTab: false,
                        isVisible: provider.isAvailableVisible,
                        theme: theme,
                        onToggleVisibility: (bool value) {
                          context.read<PeopleProvider>().toggleAvailableVisibility(value);
                        },
                        onToggleAttendance: (person) => _confirmAction(context, person, false, theme),
                        onAddTask: (person) {
                          context.read<TasksProvider>().addTask('guests.call_confirmation'.tr(namedArgs: {'name': person.name}));
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Row(
                                children: [
                                  const Icon(Icons.check_circle_outline, color: Colors.white),
                                  const SizedBox(width: 12),
                                  Expanded(child: Text('guests.reminder_created'.tr(namedArgs: {'name': person.name}))),
                                ],
                              ),
                              backgroundColor: Colors.green.shade600,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              duration: const Duration(seconds: 3),
                            ),
                          );
                        },
                      ),
                      PeopleList(
                        people: provider.selectedPeople,
                        isCompletedTab: true,
                        isVisible: provider.isCompletedVisible,
                        theme: theme,
                        onToggleVisibility: (bool value) {
                          context.read<PeopleProvider>().toggleCompletedVisibility(value);
                        },
                        onToggleAttendance: (person) => _confirmAction(context, person, true, theme),
                        onAddTask: (person) {
                          context.read<TasksProvider>().addTask('guests.call_confirmation'.tr(namedArgs: {'name': person.name}));
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Row(
                                children: [
                                  const Icon(Icons.check_circle_outline, color: Colors.white),
                                  const SizedBox(width: 12),
                                  Expanded(child: Text('guests.reminder_created'.tr(namedArgs: {'name': person.name}))),
                                ],
                              ),
                              backgroundColor: Colors.green.shade600,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              duration: const Duration(seconds: 3),
                            ),
                          );
                        },
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

  // دالة عرض الديالوج (Dialog) بتصميم حديث
  Future<void> _confirmAction(BuildContext context, PersonEntity person, bool isCompletedTab, ThemeData theme) async {
    final bool? userConfirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return ConfirmActionDialog(
          person: person,
          isCompletedTab: isCompletedTab,
          theme: theme,
        );
      },
    );

    if (userConfirmed == true && context.mounted) {
      context.read<PeopleProvider>().toggleSelection(person.id);
    }
  }
}