import 'package:check_yourself/model/shared_checklist.dart';
import 'package:check_yourself/services/firestoreService.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FirestoreChecklistEditForm extends StatefulWidget {
  final FirestoreChecklistItem? checklist;

  const FirestoreChecklistEditForm({Key? key, this.checklist})
      : super(key: key);

  @override
  _FirestoreChecklistEditFormState createState() =>
      _FirestoreChecklistEditFormState();
}

class _FirestoreChecklistEditFormState
    extends State<FirestoreChecklistEditForm> {
  late TextEditingController _titleController;
  late List<TextEditingController> _optionControllers;
  late List<TextEditingController> _sharedWithControllers;
  late List<bool> _checkedValues;

  final _formKey = GlobalKey<FormState>(); // Declare a form key

  @override
  void initState() {
    super.initState();
    _titleController =
        TextEditingController(text: widget.checklist?.title ?? '');
    _optionControllers = (widget.checklist?.options ?? [])
        .map((option) => TextEditingController(text: option))
        .toList();
    _sharedWithControllers = (widget.checklist?.sharedWith ?? [])
        .map((email) => TextEditingController(text: email))
        .toList();
    _checkedValues = (widget.checklist?.checked ?? []).toList();
  }

  @override
  void dispose() {
    _titleController.dispose();
    for (var controller in _optionControllers) {
      controller.dispose();
    }
    for (var controller in _sharedWithControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _addOption() {
    setState(() {
      _optionControllers.add(TextEditingController());
      _checkedValues.add(false);
    });
  }

  void _removeOption(int index) {
    setState(() {
      _optionControllers.removeAt(index);
      _checkedValues.removeAt(index);
    });
  }

  void _addSharedWith() {
    setState(() {
      _sharedWithControllers.add(TextEditingController());
    });
  }

  void _removeSharedWith(int index) {
    setState(() {
      _sharedWithControllers.removeAt(index);
    });
  }

  // Validator function to check if a string is a valid email format
  String? _emailValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Field cannot be empty';
    }
    final emailRegex =
        RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$'); // Email validation regex
    if (!emailRegex.hasMatch(value)) {
      return 'Enter a valid email address';
    }
    return null;
  }

  void _saveChecklist() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final title = _titleController.text.trim();
    final options =
        _optionControllers.map((controller) => controller.text.trim()).toList();
    final sharedWith = _sharedWithControllers
        .map((controller) => controller.text.trim())
        .toList();

    if (widget.checklist != null) {
      final removedSharedWith =
          widget.checklist!.sharedWith.toSet().difference(sharedWith.toSet());
      for (String email in removedSharedWith) {
        await FirebaseService.removeChecklistFromUser(
            email, widget.checklist!.id);
      }
    }

    try {
      if (widget.checklist != null) {
        final editedChecklist = widget.checklist!.copyWith(
          id: widget.checklist!.id,
          title: title,
          options: options,
          checked: _checkedValues,
          sharedWith: sharedWith,
        );

        await FirebaseService.updateChecklistItem(editedChecklist);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Checklist Saved Successfully.',
            style: GoogleFonts.pangolin(),
          ),
        ),
      );
      Future.delayed(Duration(seconds: 2), () {});
      Navigator.of(context).pop();
    } catch (e) {
      // Handle error
      print('Failed to save checklist: $e');
      // Show error message to user
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to save checklist: $e',
            style: GoogleFonts.pangolin(),
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Firestore Checklist'),
        actions: [
          IconButton(
            onPressed: _saveChecklist,
            icon: Icon(Icons.save),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(labelText: 'Title'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Field cannot be empty';
                  }
                  return null;
                },
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
                                return 'Field cannot be empty';
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
                  ElevatedButton(
                    onPressed: _addOption,
                    child: Text('Add Option'),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Text('Shared With', style: TextStyle(fontSize: 18)),
              SizedBox(height: 10),
              Column(
                children: [
                  for (int i = 0; i < _sharedWithControllers.length; i++)
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _sharedWithControllers[i],
                            decoration:
                                InputDecoration(labelText: 'Email ${i + 1}'),
                            validator: _emailValidator, // Apply email validator
                          ),
                        ),
                        IconButton(
                          onPressed: () => _removeSharedWith(i),
                          icon: Icon(Icons.remove),
                        ),
                      ],
                    ),
                  ElevatedButton(
                    onPressed: _addSharedWith,
                    child: Text('Add Email'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
