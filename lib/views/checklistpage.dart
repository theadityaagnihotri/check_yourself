import 'package:check_yourself/model/checklist.dart';
import 'package:check_yourself/services/checklist_storge.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ChecklistPage extends StatefulWidget {
  final ChecklistItem checklistItem;

  const ChecklistPage({Key? key, required this.checklistItem})
      : super(key: key);

  @override
  _ChecklistPageState createState() => _ChecklistPageState();
}

class _ChecklistPageState extends State<ChecklistPage> {
  late List<bool> _checkedValues;

  @override
  void initState() {
    super.initState();
    _checkedValues = List<bool>.from(widget.checklistItem.checked);
  }

  void _saveCheckedValues() async {
    final updatedItem = ChecklistItem(
      title: widget.checklistItem.title,
      options: widget.checklistItem.options,
      checked: _checkedValues,
    );

    await ChecklistStorage.saveChecklist(updatedItem);
    setState(() {
      _checkedValues = List<bool>.from(updatedItem.checked);
    });

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
          widget.checklistItem.title,
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
        itemCount: widget.checklistItem.options.length,
        itemBuilder: (context, index) {
          return CheckboxListTile(
            title: Text(
              widget.checklistItem.options[index],
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
