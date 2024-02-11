import 'package:check_yourself/model/shared_checklist.dart';
import 'package:check_yourself/services/firestoreService.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FirestoreChecklistSaveForm extends StatefulWidget {
  final FirestoreChecklistItem? checklist;

  const FirestoreChecklistSaveForm({Key? key, this.checklist})
      : super(key: key);

  @override
  _FirestoreChecklistSaveFormState createState() =>
      _FirestoreChecklistSaveFormState();
}

class _FirestoreChecklistSaveFormState
    extends State<FirestoreChecklistSaveForm> {
  late TextEditingController _titleController;
  late List<TextEditingController> _optionControllers;
  late List<TextEditingController> _sharedWithControllers;
  final _formKey = GlobalKey<FormState>();

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
    });
  }

  void _removeOption(int index) {
    setState(() {
      _optionControllers.removeAt(index);
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

  String? _emailValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    } else if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Enter a valid email address';
    }
    return null;
  }

  String? _optionsValidator(List<TextEditingController> controllers) {
    if (controllers.any((controller) => controller.text.isEmpty)) {
      return 'Options cannot be empty';
    }
    return null;
  }

  void _saveChecklist() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final currentUserEmail = FirebaseAuth.instance.currentUser?.email;
    final title = _titleController.text.trim();
    final options =
        _optionControllers.map((controller) => controller.text.trim()).toList();
    final sharedWith = [
      ..._sharedWithControllers
          .map((controller) => controller.text.trim())
          .where((email) => email.isNotEmpty && _emailValidator(email) == null),
      currentUserEmail!,
    ];

    final checkedValues = List<bool>.filled(options.length, false);

    final newChecklistId =
        FirebaseFirestore.instance.collection('checklists').doc().id;

    final editedChecklist = FirestoreChecklistItem(
      id: newChecklistId,
      title: title,
      options: options,
      checked: checkedValues,
      sharedWith: sharedWith,
    );

    try {
      await FirebaseService.createChecklistItem(editedChecklist);

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
      print('Failed to save checklist: $e');

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
        title: Text('Create Checklist'),
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
                    return 'Title is required';
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
                                return 'Option cannot be empty';
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
