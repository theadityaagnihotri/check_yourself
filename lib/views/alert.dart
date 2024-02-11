import 'package:check_yourself/model/checklist.dart';
import 'package:check_yourself/views/check_list_options.dart';
import 'package:flutter/material.dart';

class ChecklistDetailsForm extends StatefulWidget {
  final Function(ChecklistItem) onSave;

  const ChecklistDetailsForm({Key? key, required this.onSave})
      : super(key: key);

  @override
  _ChecklistDetailsFormState createState() => _ChecklistDetailsFormState();
}

class _ChecklistDetailsFormState extends State<ChecklistDetailsForm> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _optionsController = TextEditingController();
  int _numOptions = 0;

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Enter Checklist Details'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(labelText: 'Title'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Enter title';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _optionsController,
                decoration: InputDecoration(labelText: 'Number of Options'),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  setState(() {
                    _numOptions = int.tryParse(value) ?? 0;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Enter Options';
                  }
                  return null;
                },
              ),
            ],
          ),
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
            if (!_formKey.currentState!.validate()) {
              return;
            }
            final title = _titleController.text.trim();
            if (title.isNotEmpty && _numOptions > 0) {
              Navigator.of(context).pop();
              _showOptionsForm(title);
            }
          },
          child: Text('Next'),
        ),
      ],
    );
  }

  void _showOptionsForm(String title) {
    showDialog(
      context: context,
      builder: (context) => ChecklistOptionsForm(
        title: title,
        numOptions: _numOptions,
        onSave: widget.onSave,
      ),
    );
  }
}
