import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/entities/person_entity.dart';
import '../providers/people_provider.dart';
import '../widgets/person_info_row.dart';
import '../widgets/edit_person_dialog.dart';

class PersonDetailsScreen extends StatelessWidget {
  final PersonEntity initialPerson;

  const PersonDetailsScreen({super.key, required this.initialPerson});

  @override
  Widget build(BuildContext context) {

    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'guests.details'.tr(),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),

      ),
      body: Consumer<PeopleProvider>(
        builder: (context, provider, child) {

          final person = provider.allPeople.firstWhere(
            (p) => p.id == initialPerson.id,
            orElse: () => initialPerson,
          );


          final statusColor = person.isSelected ? Colors.green.shade600 : theme.colorScheme.primary;
          final statusBgColor = person.isSelected ? Colors.green.shade50 : theme.colorScheme.primary.withOpacity(0.05);
          final statusIcon = person.isSelected ? Icons.how_to_reg_rounded : Icons.person_outline_rounded;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [

                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: statusBgColor,
                    border: Border.all(color: statusColor.withOpacity(0.3), width: 2),
                  ),
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: statusBgColor,
                    child: Icon(
                      statusIcon,
                      size: 50,
                      color: statusColor,
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
                

                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: theme.cardTheme.color,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: theme.colorScheme.primary.withOpacity(0.05),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      PersonInfoRow(label: 'guests.id_number'.tr(), value: '#${person.id}', theme: theme),
                      const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Divider(height: 1)),
                      
                      PersonInfoRow(label: 'common.name'.tr(), value: person.name, theme: theme),
                      const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Divider(height: 1)),
                      
                      PersonInfoRow(label: 'guests.age'.tr(), value: '${person.age} ${'common.year'.tr()}', theme: theme),
                      const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Divider(height: 1)),
                      

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'guests.status'.tr(),
                            style: theme.textTheme.titleMedium?.copyWith(color: Colors.grey.shade500, fontWeight: FontWeight.bold),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                            decoration: BoxDecoration(
                              color: statusBgColor,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              person.isSelected ? 'guests.completed'.tr() : 'guests.pending'.tr(),
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: statusColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),


                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton.icon(
                    onPressed: () => _showEditDialog(context, person, theme),
                    icon: const Icon(Icons.edit_rounded, size: 20),
                    label: Text(
                      'common.edit_data'.tr(),
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }


  void _showEditDialog(BuildContext context, PersonEntity currentPerson, ThemeData theme) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return EditPersonDialog(
          currentPerson: currentPerson,
          theme: theme,
          onSave: (newName, newAge) {
            context.read<PeopleProvider>().editPerson(currentPerson.id, newName, newAge);
          },
        );
      },
    );
  }
}