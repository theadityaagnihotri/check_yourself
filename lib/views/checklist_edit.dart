import 'package:check_yourself/model/checklist.dart';
import 'package:check_yourself/services/checklist_storge.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ChecklistDetailsEditForm extends StatefulWidget {
  final ChecklistItem checklist;

  const ChecklistDetailsEditForm({Key? key, required this.checklist})
      : super(key: key);

  @override
  _ChecklistDetailsEditFormState createState() =>
      _ChecklistDetailsEditFormState();
}

class _ChecklistDetailsEditFormState extends State<ChecklistDetailsEditForm> {
  late TextEditingController _titleController;
  late List<TextEditingController> _optionControllers;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.checklist.title);
    _optionControllers = widget.checklist.options
        .map((option) => TextEditingController(text: option))
        .toList();
  }

  @override
  void dispose() {
    _titleController.dispose();
    for (var controller in _optionControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _addOption() {
    setState(() {
      _optionControllers.add(TextEditingController());
    });
  }

  void _removeOption(int index) {
    setState(() {
      _optionControllers.removeAt(index);
      widget.checklist.checked.removeAt(index);
    });
  }

  void _saveChecklist() {
    final title = _titleController.text.trim();
    final options =
        _optionControllers.map((controller) => controller.text.trim()).toList();

    while (widget.checklist.checked.length < options.length) {
      widget.checklist.checked.add(false);
    }
    final updatedChecklist = ChecklistItem(
      title: title,
      options: options,
      checked: widget.checklist.checked,
    );

    saveEditedChecklist(updatedChecklist);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Checklist Edited Successfully.',
          style: GoogleFonts.pangolin(),
        ),
      ),
    );
    Navigator.of(context).pop();
  }

  void saveEditedChecklist(ChecklistItem editedChecklist) async {
    await ChecklistStorage.saveEditedChecklist(editedChecklist);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Checklist'),
        actions: [
          IconButton(
            onPressed: _saveChecklist,
            icon: Icon(Icons.save),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: _titleController,
              decoration: InputDecoration(labelText: 'Title'),
              enabled: false,
            ),
            SizedBox(height: 20),
            Text('Options', style: TextStyle(fontSize: 18)),
            SizedBox(height: 10),
            Column(
              children: [
                for (int i = 0; i < _optionControllers.length; i++)
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _optionControllers[i],
                          decoration:
                              InputDecoration(labelText: 'Option ${i + 1}'),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Option ${i + 1} cannot be empty';
                            }
                            return null;
                          },
                        ),
                      ),
                      IconButton(
                        onPressed: () => _removeOption(i),
                        icon: Icon(Icons.remove),
                      ),
                    ],
                  ),
              ],
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: _addOption,
              child: Text('Add Option'),
            ),
          ],
        ),
      ),
    );
  }
}
