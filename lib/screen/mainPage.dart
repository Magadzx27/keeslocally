import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:shared_preferences/shared_preferences.dart';

class LieEntry {
  late String name;
  List<String> dates = [];
  List<String> lieDetailsList = [];

  LieEntry({required this.name});
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'dates': dates,
      'lieDetailsList': lieDetailsList,
    };
  }

  factory LieEntry.fromJson(Map<String, dynamic> json) {
    final name = json['name'];
    final dates = List<String>.from(json['dates']);
    final lieDetailsList = List<String>.from(json['lieDetailsList']);
    return LieEntry(name: name)
      ..dates = dates
      ..lieDetailsList = lieDetailsList;
  }
  int numberofLiesInMonth(int year, int month) {
    int count = 0;
    for (int i = 0; i < dates.length; i++) {
      DateTime lieDate = DateTime.parse(dates[i]);
      if (lieDate.year == year && lieDate.month == month) {
        count++;
      }
    }
    return count;
  }

  void addLie(String date, String lieDetails) {
    dates.add(date);
    lieDetailsList.add(lieDetails);
  }

  void removeLastLie() {
    if (dates.isNotEmpty) {
      dates.removeLast();
      lieDetailsList.removeLast();
    }
  }

  int get numberOfLies {
    return dates.length;
  }
}

class LieEntryStorage {
  static const String _lieEntriesKey = 'lie_entries';

  // Store lie entries as JSON strings in shared preferences
  static Future<void> saveLieEntries(List<LieEntry> entries) async {
    final prefs = await SharedPreferences.getInstance();
    final entriesJson = entries.map((entry) => entry.toJson()).toList();
    await prefs.setStringList(
        _lieEntriesKey, entriesJson.map((e) => jsonEncode(e)).toList());
  }

  // Retrieve lie entries from shared preferences and convert them to objects
  static Future<List<LieEntry>> loadLieEntries() async {
    final prefs = await SharedPreferences.getInstance();
    final entriesJson = prefs.getStringList(_lieEntriesKey) ?? [];
    return entriesJson
        .map((json) => LieEntry.fromJson(jsonDecode(json)))
        .toList();
  }
}

class mainPage extends StatefulWidget {
  const mainPage({super.key});

  @override
  State<mainPage> createState() => _mainPageState();
}

class _mainPageState extends State<mainPage> {
  List<LieEntry> lieEntries = [];
  bool showTopLiars = false; // Flag to control when to show the top liars

  TextEditingController nameController = TextEditingController();
  TextEditingController lieDetailsController = TextEditingController();
  List<LieEntry> findTop3LiarsForMonth(int year, int month) {
    List<LieEntry> topLiars = List.from(lieEntries);

    topLiars.sort((a, b) {
      int aCount = a.numberofLiesInMonth(year, month);
      int bCount = b.numberofLiesInMonth(year, month);
      return bCount.compareTo(aCount);
    });

    return topLiars.take(3).toList();
  }

  void toggleTopLiars() {
    setState(() {
      showTopLiars = !showTopLiars;
    });
  }

  @override
  void initState() {
    super.initState();
    // Call setState to initialize the widget with any existing data
    LieEntryStorage.loadLieEntries().then((entries) {
      setState(() {
        lieEntries = entries;
      });
    });
  }

  @override
  void dispose() {
    // Save lie entries to SharedPreferences when the widget is disposed
    LieEntryStorage.saveLieEntries(lieEntries);
    super.dispose();
  }

  void displayTop3LiarsForCurrentMonth() {
    DateTime now = DateTime.now();
    int year = now.year;
    int month = now.month;

    List<LieEntry> topLiars = findTop3LiarsForMonth(year, month);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Top 3 Liars for ${DateFormat('MMMM yyyy').format(now)}'),
          content: Column(
            children: topLiars.map((entry) {
              return ListTile(
                title: Text(entry.name),
                subtitle: Text(
                    'عدد الاكياس: ${entry.numberofLiesInMonth(year, month)}'),
              );
            }).toList(),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                LieEntryStorage.saveLieEntries(lieEntries);
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
    LieEntryStorage.saveLieEntries(lieEntries);
  }

  Future<void> showInformationDialog(BuildContext context) async {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            backgroundColor: const Color.fromARGB(255, 181, 171, 171),
            insetPadding: const EdgeInsets.all(10),
            content: Row(children: [
              SizedBox(
                width: screenWidth * 0.6,
                height: screenHeight * 0.5,
                child: Form(
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      TextFormField(
                        controller: nameController,
                        decoration: const InputDecoration(
                          hintText: 'اسم المكيس',
                          hintStyle: TextStyle(color: Colors.black),
                        ),
                      ),
                      const SizedBox(height: 30),
                      Expanded(
                        child: TextFormField(
                          controller: lieDetailsController,
                          keyboardType: TextInputType.multiline,
                          expands: true,
                          maxLines: null,
                          minLines: null,
                          decoration: const InputDecoration(
                            hintText: "عنوان الكيس",
                            hintStyle: TextStyle(color: Colors.black),
                            border: OutlineInputBorder(
                              borderSide: BorderSide(width: 2),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            ]),
            title: const Text(
              'اضافه كيس جديد',
              style: TextStyle(color: Colors.black),
            ),
            actions: [
              TextButton(
                child: const Text('الغاء'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: const Text('حفظ'),
                onPressed: () {
                  // Get the values from the text controllers
                  String name = nameController.text;
                  String lieDetails = lieDetailsController.text;
                  String date = DateFormat('yyyy-MM-dd')
                      .format(DateTime.now()); // Current date

                  LieEntry? existingEntry;

                  for (var entry in lieEntries) {
                    if (entry.name == name) {
                      existingEntry = entry;
                      break;
                    }
                  }

                  if (existingEntry != null) {
                    existingEntry.addLie(date, lieDetails);
                  } else {
                    LieEntry newEntry = LieEntry(name: name);
                    newEntry.addLie(date, lieDetails);
                    lieEntries.add(newEntry);
                  }

                  // Clear the text controllers
                  nameController.clear();
                  lieDetailsController.clear();

                  // Close the dialog
                  Navigator.of(context).pop();
                  setState(() {
                    LieEntryStorage.saveLieEntries(lieEntries);
                  });
                },
              ),
            ],
          );
        });
      },
    );
  }

  void removeLastEntry(LieEntry entry) {
    entry.removeLastLie();
    if (entry.dates.isEmpty) {
      lieEntries.remove(entry);
    }
    setState(() {
      LieEntryStorage.saveLieEntries(lieEntries);
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(10, 20, 10, 10),
          child: SizedBox(
            width: double.infinity,
            child: Card(
              color: const Color(0xFF110F1A),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0),
              ),
              elevation: 10,
              child: Column(
                children: [
                  Container(
                    height: 6,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.black,
                          Color.fromARGB(255, 243, 2, 155)
                        ],
                      ),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(16.0),
                        topRight: Radius.circular(16.0),
                      ),
                    ),
                  ),
                  const Row(
                    children: [
                      Padding(
                        padding: EdgeInsets.fromLTRB(70, 10, 10, 10),
                        child: Text(
                          '20',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                        child: Text(
                          ': عدد الاكياس الشهريه',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  Container(
                    height: 6,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.black,
                          Color.fromARGB(255, 243, 2, 155)
                        ],
                      ),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(16.0),
                        topRight: Radius.circular(16.0),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextButton(
              style: TextButton.styleFrom(
                textStyle: const TextStyle(fontSize: 20),
              ),
              onPressed: () {
                showInformationDialog(context);
              },
              child: const Text(
                'اضافه كيس جديد',
                style: TextStyle(color: Colors.black),
              ),
            )
          ],
        ),
        SizedBox(
          width: double.infinity,
          child: Card(
            color: Color.fromARGB(255, 193, 182, 182),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            elevation: 20,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                border: const TableBorder(horizontalInside: BorderSide()),
                columns: const <DataColumn>[
                  DataColumn(
                    label: Expanded(
                      child: Text(
                        'التاريخ',
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 15,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Expanded(
                      child: Text(
                        'عدد الاكياس',
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 15,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Expanded(
                      child: Text(
                        'عنوان الكيس',
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 15,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Expanded(
                      child: Text(
                        'الاسم',
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 15,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Expanded(
                      child: Text(''),
                    ),
                  ),
                ],
                rows: lieEntries.map((entry) {
                  return DataRow(
                    cells: <DataCell>[
                      DataCell(
                        Text(
                          entry.dates.isNotEmpty
                              ? entry.dates.last
                              : 'لا يوجد كذبات مسجلة',
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      DataCell(
                        Text(
                          entry.numberOfLies.toString(),
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 19,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      DataCell(
                        Text(
                          entry.lieDetailsList.isNotEmpty
                              ? entry.lieDetailsList.last
                              : 'لا يوجد كذبات مسجلة',
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 19,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      DataCell(
                        Text(
                          entry.name,
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 19,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      DataCell(
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () {
                            removeLastEntry(entry);
                          },
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ),
        SizedBox(
          height: 10,
        ),
        ElevatedButton(
          onPressed: toggleTopLiars,
          child: Text(
            showTopLiars ? "جاري التحليل" : "عرض اكثر المكيسين",
            style: const TextStyle(
              color: Color.fromARGB(255, 253, 253, 253),
              fontSize: 19,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        if (showTopLiars)
          FutureBuilder(
            // Simulate a delay to show the top liars after a week
            future: Future.delayed(const Duration(seconds: 5), () => true),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                // Show a loading indicator while waiting
                return const CircularProgressIndicator();
              } else if (snapshot.hasError) {
                // Handle errors if needed
                return Text("Error: ${snapshot.error}");
              } else {
                // Show the top liars when the week ends
                DateTime now = DateTime.now();
                int year = now.year;
                int month = now.month;
                List<LieEntry> topLiars = findTop3LiarsForMonth(year, month);

                return Column(
                  children: [
                    Text(
                      '${DateFormat('MMMM yyyy').format(now)} : اكثر المكيسين',
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Column(
                      children: topLiars.map((entry) {
                        return ListTile(
                          title: Text(
                            entry.name,
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 19,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Text(
                            'عدد الاكياس: ${entry.numberofLiesInMonth(year, month)}',
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 19,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                );
              }
            },
          ),
      ],
    );
  }
}
