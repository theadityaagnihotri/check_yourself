import 'package:check_yourself/model/checklist.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ChecklistOptionsForm extends StatefulWidget {
  final String title;
  final int numOptions;
  final Function(ChecklistItem) onSave;

  const ChecklistOptionsForm({
    Key? key,
    required this.title,
    required this.numOptions,
    required this.onSave,
  }) : super(key: key);

  @override
  _ChecklistOptionsFormState createState() => _ChecklistOptionsFormState();
}

class _ChecklistOptionsFormState extends State<ChecklistOptionsForm> {
  final List<TextEditingController> _optionControllers = [];

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < widget.numOptions; i++) {
      _optionControllers.add(TextEditingController());
    }
  }

  @override
  void dispose() {
    for (var controller in _optionControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.title,
        style: GoogleFonts.pangolin(),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (int i = 0; i < widget.numOptions; i++)
              TextFormField(
                controller: _optionControllers[i],
                decoration: InputDecoration(labelText: 'Option ${i + 1}'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Enter option';
                  }
                  return null;
                },
              ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            bool isValid = true;
            for (var controller in _optionControllers) {
              if (controller.text.trim().isEmpty) {
                isValid = false;
                break;
              }
            }
            if (!isValid) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'All options must be filled',
                    style: GoogleFonts.pangolin(color: Colors.white),
                  ),
                  backgroundColor: Colors.red,
                ),
              );
              return;
            }
            Future.delayed(Duration(seconds: 2), () {});
            final options = _optionControllers
                .map((controller) => controller.text.trim())
                .toList();
            final checklistItem =
                ChecklistItem(title: widget.title, options: options);
            widget.onSave(checklistItem);
            Navigator.of(context).pop();
          },
          child: Text('Save'),
        ),
      ],
    );
  }
}
