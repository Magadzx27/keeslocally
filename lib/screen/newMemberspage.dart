import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NewMemberPage extends StatefulWidget {
  const NewMemberPage({super.key});

  @override
  State<NewMemberPage> createState() => _NewMemberPageState();
}

class _NewMemberPageState extends State<NewMemberPage> {
  List<String> laws = [];

  @override
  void initState() {
    super.initState();

    _loadLaws();
  }

  void _removeLaw(int index) {
    setState(() {
      laws.removeAt(index);
    });
    _saveLaws();
  }

  List<Map<String, dynamic>> getLawListWithSackCounts() {
    List<Map<String, dynamic>> lawList = [];

    for (String law in laws) {
      // Extract law number and sack count from the law text
      final parts = law.split("عدد الأكياس:");
      if (parts.length == 2) {
        final lawNumber = parts[0].trim();
        final sackCount = parts[1].trim();
        lawList.add({
          'lawTitle': 'قانون $lawNumber',
          'sackCount': sackCount,
        });
      }
    }

    return lawList;
  }

  void _saveLaws() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setStringList('laws', laws);
  }

  void _loadLaws() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? savedLaws = prefs.getStringList('laws');

    if (savedLaws != null) {
      setState(() {
        laws = savedLaws;
      });
    }
  }

  void _showAddLawDialog() async {
    String title = '';
    String details = '';
    double sacks = 0.0;

    int newLawNumber = laws.length + 1; // Calculate the new law number.

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('إضافة قانون جديد'),
          content: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                TextField(
                  textAlign: TextAlign.right,
                  decoration: InputDecoration(labelText: 'عنوان القانون'),
                  onChanged: (value) {
                    title = value;
                  },
                ),
                TextField(
                  textAlign: TextAlign.right,
                  decoration: InputDecoration(labelText: 'تفاصيل القانون'),
                  onChanged: (value) {
                    details = value;
                  },
                ),
                TextField(
                  textAlign: TextAlign.right,
                  decoration: InputDecoration(labelText: 'عدد الأكياس'),
                  onChanged: (value) {
                    sacks = double.tryParse(value) ?? 0;
                  },
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('إلغاء'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('إضافة'),
              onPressed: () async {
                String newLaw = 'القانون $newLawNumber: $title\n'
                    ' مادة $newLawNumber: $details\n'
                    ' عدد الأكياس: $sacks';
                setState(() {
                  laws.add(newLaw);
                });

                // Save the updated laws list to shared_preferences
                _saveLaws();

                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        itemCount: laws.length,
        itemBuilder: (context, index) {
          return Card(
            elevation: 4,
            margin: EdgeInsets.all(8),
            child: ListTile(
              title: Text(
                laws[index],
                textAlign: TextAlign.right,
              ),
              leading: Icon(Icons.article, color: Colors.lightBlueAccent),
              trailing: IconButton(
                icon: Icon(Icons.delete, color: Colors.red),
                onPressed: () {
                  _removeLaw(index);
                },
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Color(0xFF019587),
        onPressed: () {
          _showAddLawDialog();
        },
        child: const Icon(
          Icons.add,
          color: Color.fromARGB(255, 255, 255, 255),
        ),
      ),
    );
  }
}
