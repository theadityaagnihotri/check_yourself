import 'package:check_yourself/model/shared_checklist.dart';
import 'package:check_yourself/services/firestoreService.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FirestoreChecklistPage extends StatefulWidget {
  final FirestoreChecklistItem firestoreChecklistItem;

  const FirestoreChecklistPage({Key? key, required this.firestoreChecklistItem})
      : super(key: key);

  @override
  _FirestoreChecklistPageState createState() => _FirestoreChecklistPageState();
}

class _FirestoreChecklistPageState extends State<FirestoreChecklistPage> {
  late List<bool> _checkedValues;

  @override
  void initState() {
    super.initState();
    _checkedValues = List<bool>.from(widget.firestoreChecklistItem.checked);
  }

  void _saveCheckedValues() async {
    final updatedItem = FirestoreChecklistItem(
      id: widget.firestoreChecklistItem.id,
      title: widget.firestoreChecklistItem.title,
      options: widget.firestoreChecklistItem.options,
      checked: _checkedValues,
      sharedWith: widget.firestoreChecklistItem.sharedWith,
    );
    await FirebaseService.updateChecklist(updatedItem);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Saved.',
          style: GoogleFonts.pangolin(),
        ),
      ),
    );
    Future.delayed(Duration(seconds: 2), () {});
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).canvasColor,
      appBar: AppBar(
        title: Text(
          widget.firestoreChecklistItem.title,
          style: GoogleFonts.openSans(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Theme.of(context).primaryColorDark,
        iconTheme: IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _saveCheckedValues,
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: widget.firestoreChecklistItem.options.length,
        itemBuilder: (context, index) {
          return CheckboxListTile(
            title: Text(
              widget.firestoreChecklistItem.options[index],
              style: GoogleFonts.pangolin(
                color: Theme.of(context).primaryColor,
              ),
            ),
            value: _checkedValues[index],
            onChanged: (value) {
              setState(() {
                _checkedValues[index] = value!;
              });
            },
          );
        },
      ),
    );
  }
}
