import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// 🌟 استخدام الكيان النقي
import '../../domain/entities/person_entity.dart';
import '../providers/people_provider.dart'; 

class PersonDetailsScreen extends StatelessWidget {
  // 🌟 تعديل المتغير ليكون من نوع الكيان النقي
  final PersonEntity initialPerson;

  const PersonDetailsScreen({super.key, required this.initialPerson});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'guests.details'.tr(),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.blue),
            onPressed: () {
              _showEditDialog(context, initialPerson);
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Consumer<PeopleProvider>(
        builder: (context, provider, child) {
          final person = provider.allPeople.firstWhere(
            (p) => p.id == initialPerson.id,
            orElse: () => initialPerson, 
          );

          return Padding(
            padding: const EdgeInsetsDirectional.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: CircleAvatar(
                    radius: 60,
                    backgroundColor: person.isSelected ? Colors.green.shade100 : Colors.blue.shade100,
                    child: Icon(
                      person.isSelected ? Icons.check : Icons.person,
                      size: 60,
                      color: person.isSelected ? Colors.green : Colors.blue,
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                
                _buildInfoRow('guests.id_number'.tr(), person.id.toString()),
                const Divider(),
                _buildInfoRow('common.name'.tr(), person.name),
                const Divider(),
                _buildInfoRow(
                  'guests.age'.tr(),
                  '${person.age} ${'common.year'.tr()}',
                ),
                const Divider(),
                _buildInfoRow(
                  'guests.status'.tr(), 
                  person.isSelected ? 'guests.completed'.tr() : 'guests.available'.tr(),
                  textColor: person.isSelected ? Colors.green : Colors.blue,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {Color? textColor}) {
    return Padding(
      padding: const EdgeInsetsDirectional.symmetric(vertical: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Text(
              label,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey),
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              value,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  // 🌟 الدالة الآن تستقبل الكيان وتعدل عليه بشكل آمن ومعماري سليم
  void _showEditDialog(BuildContext context, PersonEntity currentPerson) {
    final nameController = TextEditingController(text: currentPerson.name);
    final ageController = TextEditingController(text: currentPerson.age.toString());

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            'common.edit_data'.tr(),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'common.name'.tr(),
                  prefixIcon: const Icon(Icons.person),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: ageController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'guests.age'.tr(),
                  prefixIcon: const Icon(Icons.calendar_today),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(
                'common.cancel'.tr(),
                style: const TextStyle(color: Colors.grey),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white),
              onPressed: () {
                final newName = nameController.text.trim();
                final newAge = int.tryParse(ageController.text.trim());

                if (newName.isNotEmpty && newAge != null) {
                  context.read<PeopleProvider>().editPerson(
                    currentPerson.id,
                    newName,
                    newAge,
                  );
                  Navigator.pop(dialogContext); 
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('guests.confirm_message'.tr(namedArgs: {'action': 'validate', 'name': 'input'})),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: Text('common.save_changes'.tr()),
            ),
          ],
        );
      },
    );
  }
}