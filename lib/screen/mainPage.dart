// ignore: file_names
// ignore: file_names
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:kees/TopKees.dart';
import 'package:kees/reusable_card.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants.dart';

class AppState extends ChangeNotifier {
  String selectedSackCount = '';

  void setSelectedSackCount(String sackCount) {
    selectedSackCount = sackCount;
    notifyListeners();
  }
}

class LieEntry {
  late String name;
  List<String> dates = [];
  List<String> lieTopsList = [];
  List<String> lieDetailsList = [];
  String selectedSackCount = '';

  LieEntry({
    required this.name,
  });
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'dates': dates,
      'lieDetailsList': lieDetailsList,
      'lieTopsList': lieTopsList,
      'selectedSackCount': selectedSackCount
    };
  }

  factory LieEntry.fromJson(Map<String, dynamic> json) {
    final name =
        json['name'] ?? ''; // Provide a default empty string if 'name' is null
    final dates = List<String>.from(json['dates'] ?? []);
    final lieDetailsList = List<String>.from(json['lieDetailsList'] ?? []);
    final lieTopsList = List<String>.from(json['lieTopsList'] ?? []);
    final selectedSackCount = json['selectedSackCount'] ?? '';

    return LieEntry(name: name)
      ..selectedSackCount = selectedSackCount
      ..dates = dates
      ..lieTopsList = lieTopsList
      ..lieDetailsList = lieDetailsList;
  }

  void addLie(String date, String lieDetails, String lieTopList) {
    dates.add(date);
    lieTopsList.add(lieTopList);
    lieDetailsList.add(lieDetails);
  }

  void removeLastLie() {
    if (dates.isNotEmpty) {
      dates.removeLast();
      lieTopsList.removeLast();
      lieDetailsList.removeLast();
    }
  }

  int get numberOfLies {
    return dates.length;
  }

  int numberOfLiesInMonth(int year, int month) {
    int count = 0;
    for (int i = 0; i < dates.length; i++) {
      DateTime lieDate = DateTime.parse(dates[i]);
      if (lieDate.year == year && lieDate.month == month) {
        count++;
      }
    }
    return count;
  }
}

class LieEntryStorage {
  static const String _lieEntriesKey = 'lie_entries';
  void saveLieEntries(List<LieEntry> entries) async {
    final prefs = await SharedPreferences.getInstance();
    final entriesJson = entries.map((entry) => entry.toJson()).toList();
    await prefs.setStringList(
        _lieEntriesKey, entriesJson.map((e) => jsonEncode(e)).toList());
  }

  static Future<List<LieEntry>> loadLieEntries() async {
    final prefs = await SharedPreferences.getInstance();
    final entriesJson = prefs.getStringList(_lieEntriesKey) ?? [];
    return entriesJson
        .map((json) => LieEntry.fromJson(jsonDecode(json)))
        .toList();
  }
}

// ignore: camel_case_types
class mainPage extends StatefulWidget {
  const mainPage({super.key});

  @override
  State<mainPage> createState() => _mainPageState();
}

class _mainPageState extends State<mainPage> {
  final LieEntryStorage lieEntryStorage = LieEntryStorage();
  List<Map<String, dynamic>> lawsWithSackCounts = [];
  List<LieEntry> lieEntries = [];
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController nameController = TextEditingController();
  TextEditingController lieDetailsController = TextEditingController();
  TextEditingController lieTopListController = TextEditingController();
  TextEditingController selectedLawController = TextEditingController();

  List<LieEntry> topLiars = [];

  double calculateTotalSackCount() {
    double totalSackCount = 0.0;
    for (var entry in lieEntries) {
      double entrySackCount = double.tryParse(entry.selectedSackCount) ?? 0.0;
      totalSackCount += entrySackCount;
    }
    return totalSackCount;
  }

  @override
  void initState() {
    super.initState();
    LieEntryStorage.loadLieEntries().then((entries) {
      setState(() {
        lieEntries = entries;
      });
    });
  }

  @override
  void dispose() {
    lieEntryStorage.saveLieEntries(lieEntries);

    super.dispose();
  }

  void removeLastEntry(LieEntry entry) {
    entry.removeLastLie();
    if (entry.dates.isEmpty) {
      lieEntries.remove(entry);
    }
    setState(() {
      lieEntryStorage.saveLieEntries(lieEntries);
    });
  }

//
  @override
  Widget build(BuildContext context) {
    double totalSackCount = calculateTotalSackCount();
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return ListView(
      children: [
        Column(
          children: [
            ReusableCard(
              kess: ': مجموع الاكياس',
              total: totalSackCount,
            ),
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: <Color>[
                            Color(0xFF019587),
                            Color.fromARGB(255, 1, 128, 115),
                            Color.fromARGB(255, 1, 108, 97),
                          ],
                        ),
                      ),
                    ),
                  ),
                  TextButton(
                    style: TextButton.styleFrom(
                      foregroundColor: Color(0xFF019587),
                      padding: const EdgeInsets.all(16.0),
                      textStyle: const TextStyle(fontSize: 20),
                    ),
                    child: const Text(
                      'اضافه كيس جديد',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return StatefulBuilder(builder: (context, setState) {
                            return SingleChildScrollView(
                              child: AlertDialog(
                                backgroundColor:
                                    const Color.fromARGB(255, 181, 171, 171),
                                insetPadding:
                                    const EdgeInsets.fromLTRB(10, 10, 10, 1),
                                content: Row(children: [
                                  SizedBox(
                                    width: screenWidth * 0.6,
                                    height: screenHeight * 0.5,
                                    child: Form(
                                      key: _formKey,
                                      child: Column(
                                        mainAxisSize: MainAxisSize.max,
                                        children: [
                                          TextFormField(
                                            validator: (value) {
                                              if (value == null ||
                                                  value.isEmpty) {
                                                return 'ادخل اسم المكيس';
                                              }
                                              return null;
                                            },
                                            controller: nameController,
                                            textAlign: TextAlign.right,
                                            decoration: const InputDecoration(
                                              hintText: 'اسم المكيس',
                                              hintStyle: TextStyle(
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                          const SizedBox(height: 30),
                                          TextFormField(
                                            validator: (value) {
                                              if (value == null ||
                                                  value.isEmpty) {
                                                return 'ادخل عنوان الكيس';
                                              }
                                              return null;
                                            },
                                            controller: lieTopListController,
                                            keyboardType:
                                                TextInputType.multiline,
                                            textAlign: TextAlign.right,
                                            decoration: const InputDecoration(
                                              hintText: "عنوان الكيس",
                                              hintStyle: TextStyle(
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                          const SizedBox(height: 30),
                                          TextFormField(
                                            validator: (value) {
                                              if (value == null ||
                                                  value.isEmpty) {
                                                return 'وووو كم كيس';
                                              }
                                              return null;
                                            },
                                            controller: selectedLawController,
                                            keyboardType: TextInputType.number,
                                            textAlign: TextAlign.right,
                                            decoration: const InputDecoration(
                                              hintText: "عدد الاكياس",
                                              hintStyle: TextStyle(
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                          const SizedBox(height: 30),
                                          Expanded(
                                            child: TextFormField(
                                              validator: (value) {
                                                if (value == null ||
                                                    value.isEmpty) {
                                                  return 'ادخل تفاصيل الكيس';
                                                }
                                                return null;
                                              },
                                              controller: lieDetailsController,
                                              keyboardType:
                                                  TextInputType.multiline,
                                              textAlign: TextAlign.right,
                                              decoration: const InputDecoration(
                                                hintText: "تفاصيل الكيس",
                                                hintStyle: TextStyle(
                                                    color: Colors.black,
                                                    fontWeight:
                                                        FontWeight.bold),
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
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold),
                                  textAlign: TextAlign.right,
                                ),
                                actions: [
                                  TextButton(
                                    child: const Text(
                                      'الغاء',
                                      textAlign: TextAlign.left,
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    onPressed: () {
                                      nameController.clear();
                                      lieDetailsController.clear();
                                      selectedLawController.clear();
                                      lieTopListController.clear();
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                  TextButton(
                                    child: const Text(
                                      'حفظ',
                                      textAlign: TextAlign.left,
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    onPressed: () async {
                                      if (_formKey.currentState!.validate()) {
                                        String name = nameController.text;
                                        String lieDetails =
                                            lieDetailsController.text;
                                        String date = DateFormat('yyyy-MM-dd')
                                            .format(DateTime.now());
                                        String lieTopList =
                                            lieTopListController.text;
                                        String selectcount =
                                            selectedLawController.text;
                                        LieEntry? existingEntry;

                                        for (var entry in lieEntries) {
                                          if (entry.name == name) {
                                            existingEntry = entry;
                                            break;
                                          }
                                        }
                                        if (existingEntry != null) {
                                          double oldCount = double.tryParse(
                                                  existingEntry
                                                      .selectedSackCount) ??
                                              0.0;
                                          double newCount =
                                              double.tryParse(selectcount) ??
                                                  0.0;
                                          double updatedCount =
                                              oldCount + newCount;
                                          existingEntry.addLie(
                                              date, lieDetails, lieTopList);
                                          existingEntry.selectedSackCount =
                                              updatedCount
                                                  .toString(); // Set the selected sack count for this specific LieEntry
                                        } else {
                                          LieEntry newEntry =
                                              LieEntry(name: name);
                                          newEntry.addLie(
                                              date, lieDetails, lieTopList);
                                          newEntry.selectedSackCount =
                                              selectcount; // Set the selected sack count for this specific LieEntry
                                          lieEntries.add(newEntry);
                                        }

                                        nameController.clear();
                                        lieDetailsController.clear();
                                        selectedLawController.clear();
                                        lieTopListController.clear();
                                        Navigator.of(context).pop();

                                        setState(() {
                                          lieEntryStorage
                                              .saveLieEntries(lieEntries);
                                        });
                                      }
                                    },
                                  ),
                                ],
                              ),
                            );
                          });
                        },
                      );
                    },
                  ),
                ],
              ),
            )
          ],
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: Card(
            color: Color.fromARGB(255, 255, 255, 255),
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
                      child: Text('التاريخ', style: kLabelTextStylehead),
                    ),
                  ),
                  DataColumn(
                    label: Expanded(
                      child: Text(
                        'عدد الأكياس',
                        style: kLabelTextStylehead,
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Expanded(
                      child: Text('عنوان الكيس', style: kLabelTextStylehead),
                    ),
                  ),
                  DataColumn(
                    label: Expanded(
                      child: Text('الاسم', style: kLabelTextStylehead),
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
                            style: kLabelTextStylebody),
                      ),
                      DataCell(
                        Row(
                          children: [
                            Text(entry.selectedSackCount,
                                style: kLabelTextStylebody),
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.black),
                              onPressed: () {
                                double subtractValue =
                                    0.0; // Step 1: Initialize subtractValue
                                showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        backgroundColor:
                                            Color.fromARGB(255, 181, 171, 171),
                                        title: Text('تعديل عدد الاكياس'),
                                        content: TextFormField(
                                          validator: (value) {
                                            if (value == null ||
                                                value.isEmpty) {
                                              return 'رقم';
                                            }
                                            return null;
                                          },
                                          onChanged: (value) => {
                                            subtractValue =
                                                double.tryParse(value) ?? 0.0
                                          },
                                          controller: selectedLawController,
                                          keyboardType: TextInputType.number,
                                          textAlign: TextAlign.right,
                                          decoration: const InputDecoration(
                                            hintStyle: TextStyle(
                                                color: Colors.black,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                        actions: <Widget>[
                                          TextButton(
                                            style: TextButton.styleFrom(
                                              textStyle: Theme.of(context)
                                                  .textTheme
                                                  .labelLarge,
                                            ),
                                            child: const Text('الغاء'),
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                          ),
                                          TextButton(
                                            style: TextButton.styleFrom(
                                              textStyle: Theme.of(context)
                                                  .textTheme
                                                  .labelLarge,
                                            ),
                                            child: const Text('حفظ'),
                                            onPressed: () {
                                              if (subtractValue != 0) {
                                                double currentCount =
                                                    double.tryParse(entry
                                                            .selectedSackCount) ??
                                                        0.0;
                                                double updatedCount =
                                                    currentCount -
                                                        subtractValue;
                                                if (updatedCount < 0) {
                                                  updatedCount == 0.0;
                                                }
                                                entry.selectedSackCount =
                                                    updatedCount.toString();
                                              }

                                              // Save the updated lieEntries
                                              lieEntryStorage
                                                  .saveLieEntries(lieEntries);
                                              selectedLawController.clear();
                                              Navigator.of(context).pop();
                                              setState(() {});
                                            },
                                          ),
                                        ],
                                      );
                                    });
                              },
                            ),
                          ],
                        ),
                      ),
                      DataCell(Row(
                        children: [
                          Text(
                              entry.lieTopsList.isNotEmpty
                                  ? entry.lieTopsList.last
                                  : 'لا يوجد كذبات مسجلة',
                              style: kLabelTextStylebody),
                          IconButton(
                            icon: const Icon(
                              Icons.arrow_drop_down_sharp,
                              color: Colors.black,
                            ),
                            onPressed: () {
                              showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      backgroundColor: const Color.fromARGB(
                                          255, 181, 171, 171),
                                      title: const Text('تفاصيل الكيس'),
                                      content: Text(
                                        entry.lieDetailsList.isNotEmpty
                                            ? entry.lieDetailsList.last
                                            : 'لا يوجد كذبات مسجلة',
                                        style: const TextStyle(
                                          color: Colors.black,
                                          fontSize: 19,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    );
                                  });
                            },
                          ),
                        ],
                      )),
                      DataCell(
                        Text(entry.name, style: kLabelTextStylebody),
                      ),
                      DataCell(
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.black),
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
        const SizedBox(
          height: 10,
        ),
        TopKees(lieEntries: lieEntries),
      ],
    );
  }
}
