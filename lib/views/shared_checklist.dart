import 'package:check_yourself/model/shared_checklist.dart';
import 'package:check_yourself/views/editfirestoreform.dart';
import 'package:check_yourself/views/firestoreForm.dart';
import 'package:check_yourself/views/firestorechecklistpage.dart';
import 'package:check_yourself/views/home.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SharedChecklist extends StatefulWidget {
  final String userEmail;

  const SharedChecklist({Key? key, required this.userEmail}) : super(key: key);

  @override
  State<SharedChecklist> createState() => _SharedChecklistState();
}

class _SharedChecklistState extends State<SharedChecklist> {
  void _addChecklist() {
    showDialog(
      context: context,
      builder: (context) => FirestoreChecklistSaveForm(),
    );
  }

  void _onFirestoreChecklistTapped(String checklistId) {
    FirebaseFirestore.instance
        .collection('checklists')
        .where('id', isEqualTo: checklistId)
        .get()
        .then((QuerySnapshot querySnapshot) {
      if (querySnapshot.docs.isNotEmpty) {
        DocumentSnapshot documentSnapshot = querySnapshot.docs.first;
        FirestoreChecklistItem firestoreChecklistItem = FirestoreChecklistItem(
          id: documentSnapshot.id,
          title: documentSnapshot['title'],
          options: List<String>.from(documentSnapshot['options'] ?? []),
          checked: List<bool>.from(documentSnapshot['checked'] ?? []),
          sharedWith: List<String>.from(documentSnapshot['sharedWith'] ?? []),
        );

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FirestoreChecklistPage(
              firestoreChecklistItem: firestoreChecklistItem,
            ),
          ),
        );
      } else {
        print('Checklist with ID $checklistId does not exist.');
      }
    }).catchError((error) {
      print('Error fetching checklist: $error');
    });
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
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => const MyHomePage(),
      ),
    );
  }

  void _onFirestoreChecklistedit(String checklistId) {
    FirebaseFirestore.instance
        .collection('checklists')
        .where('id', isEqualTo: checklistId)
        .get()
        .then((QuerySnapshot querySnapshot) {
      if (querySnapshot.docs.isNotEmpty) {
        DocumentSnapshot documentSnapshot = querySnapshot.docs.first;
        FirestoreChecklistItem firestoreChecklistItem = FirestoreChecklistItem(
          id: documentSnapshot.id,
          title: documentSnapshot['title'],
          options: List<String>.from(documentSnapshot['options'] ?? []),
          checked: List<bool>.from(documentSnapshot['checked'] ?? []),
          sharedWith: List<String>.from(documentSnapshot['sharedWith'] ?? []),
        );

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FirestoreChecklistEditForm(
              checklist: firestoreChecklistItem,
            ),
          ),
        );
      } else {
        // Handle the case where the checklist with the provided ID does not exist
        print('Checklist with ID $checklistId does not exist.');
      }
    }).catchError((error) {
      // Handle errors that occur during fetching the checklist
      print('Error fetching checklist: $error');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).canvasColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColorDark,
        title: Text(
          'Shared CheckLists',
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
                'My Checklists',
                style: GoogleFonts.openSans(fontWeight: FontWeight.bold),
              ),
              onTap: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => const MyHomePage(),
                  ),
                );
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
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(widget.userEmail)
            .snapshots(),
        builder:
            (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          }

          if (!snapshot.hasData) {
            return Center(
              child: Text('No data available'),
            );
          }
          List<dynamic>? sharedWithList;
          if (snapshot.hasData && snapshot.data != null) {
            final documentSnapshot = snapshot.data!;
            if (documentSnapshot.exists) {
              final data = documentSnapshot.data() as Map<String, dynamic>?;
              if (data != null) {
                final sharedChecklists = data['sharedChecklists'];
                if (sharedChecklists != null) {
                  sharedWithList = sharedChecklists;
                } else {
                  sharedWithList = null;
                }
              } else {
                sharedWithList = null;
              }
            } else {
              sharedWithList = null;
            }
          } else {
            sharedWithList = null;
          }

          return ListView.builder(
            itemCount: sharedWithList?.length ?? 0,
            itemBuilder: (BuildContext context, int index) {
              return StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('checklists')
                    .where('id', isEqualTo: sharedWithList?[index])
                    .snapshots(),
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> checklistSnapshot) {
                  if (checklistSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!checklistSnapshot.hasData ||
                      checklistSnapshot.data!.docs.isEmpty) {
                    return SizedBox.shrink();
                  }

                  final checklistData =
                      checklistSnapshot.data!.docs.first.data();
                  final title = checklistData != null
                      ? (checklistData as Map<String, dynamic>)['title'] ??
                          'Untitled Checklist'
                      : 'Untitled Checklist';

                  final checklistId = checklistData != null
                      ? (checklistData as Map<String, dynamic>)['id']
                      : null;

                  return Card(
                    child: ListTile(
                      textColor: Theme.of(context).primaryColor,
                      iconColor: Theme.of(context).primaryColor,
                      title: Text(
                        title,
                        style: GoogleFonts.pangolin(),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () {
                              _onFirestoreChecklistedit(checklistId);
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () {
                              print(
                                  "Attempting to delete checklist with ID: $checklistId");

                              setState(() {
                                sharedWithList!.removeAt(index);
                              });
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Checklist deleted successfully',
                                    style: GoogleFonts.pangolin(),
                                  ),
                                ),
                              );
                              print(
                                  "Checklist ID removed from shared list successfully");

                              FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(widget.userEmail)
                                  .update({
                                'sharedChecklists': sharedWithList,
                              }).then((_) {
                                print(
                                    'Checklist ID removed from sharedChecklists in Firestore');
                              }).catchError((error) {
                                print(
                                    'Failed to remove checklist ID from sharedChecklists in Firestore: $error');
                              });
                            },
                          ),
                        ],
                      ),
                      onTap: () {
                        _onFirestoreChecklistTapped(checklistId);
                      },
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
