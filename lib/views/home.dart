import 'dart:convert';

import 'package:check_yourself/model/checklist.dart';
import 'package:check_yourself/services/auth_service.dart';
import 'package:check_yourself/views/alert.dart';
import 'package:check_yourself/views/shared_checklist.dart';
import 'package:check_yourself/views/checklist_edit.dart';
import 'package:check_yourself/views/checklistpage.dart';
import 'package:connectivity/connectivity.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final List<ChecklistItem> _checklists = [];
  void _onChecklistTapped(ChecklistItem checklistItem) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChecklistPage(checklistItem: checklistItem),
      ),
    );
  }

  _signinuser() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'You are not signed in. Please sign in to continue.',
            style: GoogleFonts.pangolin(
              color: Theme.of(context).primaryColorDark,
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () async {
                final authservice = AuthService();
                await authservice.signinwithgoogle(context);
                if (FirebaseAuth.instance.currentUser != null)
                  Navigator.of(context).pop();
              },
              child: Text('Sign In'),
            ),
          ],
        );
      },
    );
  }

  void _addChecklist() {
    showDialog(
      context: context,
      builder: (context) => ChecklistDetailsForm(
        onSave: _saveChecklist,
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _loadChecklists();
  }

  void _showSignOutConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent dismissing the dialog
      builder: (BuildContext context) {
        bool _loading = false; // Indicator for loading state

        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: Text('Sign Out'),
              content: _loading
                  ? CircularProgressIndicator() // Show CircularProgressIndicator while loading
                  : Text('Are you sure you want to sign out?'),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('Cancel'),
                ),
                TextButton(
                  onPressed: _loading // Disable button when loading
                      ? null
                      : () async {
                          setState(() {
                            _loading = true; // Set loading state to true
                          });
                          await _signOutUser(context);
                          setState(() {
                            _loading =
                                false; // Set loading state to false after sign out
                          });
                        },
                  child: Text('Sign Out'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _signOutUser(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.of(context).pop();
  }

  Future<void> _loadChecklists() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('checklists');
    if (jsonString != null) {
      final List<dynamic> jsonList = jsonDecode(jsonString);
      setState(() {
        _checklists.clear();
        for (final item in jsonList) {
          _checklists.add(ChecklistItem.fromJson(item));
        }
      });
    }
  }

  void _saveChecklist(ChecklistItem checklistItem) async {
    final prefs = await SharedPreferences.getInstance();
    final List<ChecklistItem> existingChecklists =
        await _loadChecklistsFromPrefs();
    existingChecklists.add(checklistItem);
    final jsonList = existingChecklists.map((item) => item.toJson()).toList();
    await prefs.setString('checklists', jsonEncode(jsonList));
    _loadChecklists();
  }

  void _deleteChecklist(int index) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      List<ChecklistItem> existingChecklists = await _loadChecklistsFromPrefs();

      existingChecklists.removeAt(index);

      // Save the updated list of checklists to SharedPreferences
      final jsonList = existingChecklists.map((item) => item.toJson()).toList();
      await prefs.setString('checklists', jsonEncode(jsonList));

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Deleted Checklist.',
            style: GoogleFonts.pangolin(),
          ),
        ),
      );

      _loadChecklists();
    } catch (e) {
      print('Error deleting checklist: $e');
    }
  }

  Future<List<ChecklistItem>> _loadChecklistsFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('checklists');
    if (jsonString != null) {
      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList.map((item) => ChecklistItem.fromJson(item)).toList();
    }
    return [];
  }

  @override
  Widget build(BuildContext context) {
    setState(() {
      _loadChecklists();
    });
    return Scaffold(
      backgroundColor: Theme.of(context).canvasColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColorDark,
        title: Text(
          'My CheckLists',
          style: GoogleFonts.openSans(color: Colors.white),
        ),
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: _addChecklist,
          ),
          SizedBox(
            width: 5,
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColorDark,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome',
                    style: GoogleFonts.openSans(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                  Text(
                    FirebaseAuth.instance.currentUser?.displayName ?? 'User',
                    style: GoogleFonts.openSans(color: Colors.white),
                  ),
                ],
              ),
            ),
            ListTile(
              title: Text(
                'Shared Checklists',
                style: GoogleFonts.openSans(fontWeight: FontWeight.bold),
              ),
              onTap: () async {
                var connectivityResult =
                    await Connectivity().checkConnectivity();
                if (connectivityResult == ConnectivityResult.none) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'No internet connection.',
                        style: GoogleFonts.pangolin(),
                      ),
                    ),
                  );
                } else {
                  if (FirebaseAuth.instance.currentUser == null) {
                    _signinuser();
                  }

                  if (FirebaseAuth.instance.currentUser != null) {
                    Future.microtask(() {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (context) => SharedChecklist(
                              userEmail:
                                  (FirebaseAuth.instance.currentUser?.email)
                                      .toString()),
                        ),
                      );
                    });
                  }
                }
              },
            ),
            if (FirebaseAuth.instance.currentUser != null)
              ListTile(
                title: Text(
                  'Sign Out',
                  style: GoogleFonts.openSans(fontWeight: FontWeight.bold),
                ),
                onTap: () {
                  _showSignOutConfirmationDialog(context);
                },
              ),
          ],
        ),
      ),
      body: SafeArea(
        child: ListView.builder(
          itemCount: _checklists.length,
          itemBuilder: (context, index) {
            final checklist = _checklists[index];
            return Card(
              child: ListTile(
                textColor: Theme.of(context).primaryColor,
                iconColor: Theme.of(context).primaryColor,
                title: Text(
                  checklist.title,
                  style: GoogleFonts.pangolin(),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChecklistDetailsEditForm(
                              checklist: checklist,
                            ),
                          ),
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => _deleteChecklist(index),
                    ),
                  ],
                ),
                onTap: () => _onChecklistTapped(_checklists[index]),
              ),
            );
          },
        ),
      ),
    );
  }
}
