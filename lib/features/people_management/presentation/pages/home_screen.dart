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
                      _buildPeopleList(
                        context: context,
                        people: provider.availablePeople,
                        isCompletedTab: false,
                        isVisible: provider.isAvailableVisible,
                        theme: theme,
                      ),
                      _buildPeopleList(
                        context: context,
                        people: provider.selectedPeople,
                        isCompletedTab: true,
                        isVisible: provider.isCompletedVisible,
                        theme: theme,
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
    final String actionText = isCompletedTab ? 'guests.undo_attended'.tr() : 'guests.mark_attended'.tr();
    
    final bool? userConfirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: theme.cardTheme.color,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Text(
            'guests.confirm_action'.tr(),
            style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.primary),
          ),
          content: Text(
            'guests.confirm_message'.tr(namedArgs: {'action': actionText, 'name': person.name}),
            style: TextStyle(color: Colors.grey.shade700, fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text('common.cancel'.tr(), style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: isCompletedTab ? Colors.red.shade400 : Colors.green.shade600,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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

  // بناء قائمة الأشخاص
  Widget _buildPeopleList({
    required BuildContext context,
    required List<PersonEntity> people,
    required bool isCompletedTab,
    required bool isVisible,
    required ThemeData theme,
  }) {
    return Column(
      children: [
        // ترويسة القائمة (العدد وزر الإخفاء)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isCompletedTab
                    ? 'guests.attended_count'.tr(namedArgs: {'count': people.length.toString()})
                    : 'guests.pending_count'.tr(namedArgs: {'count': people.length.toString()}),
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.primary),
              ),
              Row(
                children: [
                  Icon(isVisible ? Icons.visibility_rounded : Icons.visibility_off_rounded, color: Colors.grey.shade500, size: 20),
                  Switch.adaptive( // استخدام Switch.adaptive لأفضل تجربة عبر المنصات
                    value: isVisible,
                    activeColor: theme.colorScheme.secondary,
                    onChanged: (bool value) {
                      if (isCompletedTab) {
                        context.read<PeopleProvider>().toggleCompletedVisibility(value);
                      } else {
                        context.read<PeopleProvider>().toggleAvailableVisibility(value);
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
        ),

        // حالة القائمة المخفية
        if (!isVisible)
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(color: Colors.grey.shade200, shape: BoxShape.circle),
                    child: Icon(Icons.visibility_off_rounded, size: 60, color: Colors.grey.shade500),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'guests.hidden_list'.tr(),
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
          )
        // حالة عرض البيانات
        else
          Expanded(
            child: people.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(isCompletedTab ? Icons.how_to_reg_rounded : Icons.people_outline_rounded, size: 60, color: Colors.grey.shade400),
                        const SizedBox(height: 12),
                        Text(
                          isCompletedTab ? 'guests.no_attended'.tr() : 'guests.no_pending'.tr(),
                          style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  )
                : ListView.separated( // استخدام separated بدلاً من builder
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: people.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final person = people[index];

                      return Dismissible(
                        key: ValueKey('person_${person.id}'),
                        direction: DismissDirection.startToEnd,
                        // تصميم خلفية السحب (Swipe to Add Task)
                        background: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [theme.colorScheme.secondary, theme.colorScheme.secondary.withOpacity(0.7)],
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          alignment: AlignmentDirectional.centerStart,
                          padding: const EdgeInsetsDirectional.only(start: 24),
                          child: Row(
                            children: [
                              const Icon(Icons.add_task_rounded, color: Colors.white, size: 28),
                              const SizedBox(width: 12),
                              Text(
                                'guests.reminder_task'.tr(),
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                            ],
                          ),
                        ),
                        confirmDismiss: (direction) async {
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
                          return false; // نرجع false لأننا لا نريد حذف العنصر من القائمة!
                        },
                        // بطاقة الضيف
                        child: Container(
                          decoration: BoxDecoration(
                            color: theme.cardTheme.color,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: theme.colorScheme.primary.withOpacity(0.04),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            clipBehavior: Clip.hardEdge,
                            borderRadius: BorderRadius.circular(16),
                            child: ListTile(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => PersonDetailsScreen(initialPerson: person)),
                                );
                              },
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              leading: CircleAvatar(
                                radius: 24,
                                backgroundColor: isCompletedTab ? Colors.green.shade50 : theme.colorScheme.primary.withOpacity(0.05),
                                child: Icon(
                                  isCompletedTab ? Icons.check_rounded : Icons.person_outline_rounded,
                                  color: isCompletedTab ? Colors.green.shade600 : theme.colorScheme.primary,
                                ),
                              ),
                              title: Text(
                                person.name,
                                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.primary),
                              ),
                              subtitle: Text(
                                '${'guests.age'.tr()}: ${person.age}',
                                style: TextStyle(color: Colors.grey.shade600),
                              ),
                              trailing: isCompletedTab
                                  ? OutlinedButton.icon(
                                      onPressed: () => _confirmAction(context, person, isCompletedTab, theme),
                                      icon: Icon(Icons.undo_rounded, size: 18, color: Colors.red.shade400),
                                      label: Text('guests.undo_attended'.tr(), style: TextStyle(color: Colors.red.shade400)),
                                      style: OutlinedButton.styleFrom(
                                        side: BorderSide(color: Colors.red.shade200),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                      ),
                                    )
                                  : ElevatedButton.icon(
                                      onPressed: () => _confirmAction(context, person, isCompletedTab, theme),
                                      icon: const Icon(Icons.how_to_reg_rounded, size: 18),
                                      label: Text('guests.mark_attended'.tr()),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.green.shade600, // الأخضر يدل على التأكيد بنجاح
                                        foregroundColor: Colors.white,
                                        elevation: 0,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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