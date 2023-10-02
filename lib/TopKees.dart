import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kees/Top_reusable_card.dart';
import 'package:kees/reusable_card.dart';
import 'package:kees/screen/mainPage.dart'; // Import your LieEntry class

class TopKees extends StatelessWidget {
  final List<LieEntry> lieEntries;

  const TopKees({Key? key, required this.lieEntries}) : super(key: key);

  List<LieEntry> calculateTopLiars(List<LieEntry> entries) {
    // Sort the entries based on selected sack count in descending order
    entries.sort((a, b) {
      double countA = double.tryParse(a.selectedSackCount) ?? 0.0;
      double countB = double.tryParse(b.selectedSackCount) ?? 0.0;
      return countB.compareTo(countA);
    });

    // Get the top three liars
    return entries.take(3).toList();
  }

  Future<List<LieEntry>> fetchTopLiars() async {
    // Simulate a delay (you can remove this in a real app)
    await Future.delayed(const Duration(seconds: 2));

    // Calculate and return the top liars
    return calculateTopLiars(lieEntries);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(8.0),
      child: Column(
        children: [
          ElevatedButton(
            onPressed: () {
              // You can trigger the fetchTopLiars method here if needed.
            },
            child: Text(
              "عرض اكثر المكيسين",
              style: const TextStyle(
                color: Color.fromARGB(255, 253, 253, 253),
                fontSize: 19,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          FutureBuilder<List<LieEntry>>(
            future: fetchTopLiars(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                // While waiting for the future to complete, show a loading indicator.
                return const CircularProgressIndicator();
              } else if (snapshot.hasError) {
                // If there is an error, display an error message.
                return Text("Error: ${snapshot.error}");
              } else if (snapshot.hasData) {
                // If the data is available and not null, display the top liars.
                List<LieEntry> topLiars = snapshot.data!;
                if (topLiars.isEmpty) {
                  // If the topLiars list is empty, display a message indicating that no top liars are available.
                  return const Text("للاسف لا يوجد مكيسين",
                      style: TextStyle(color: Colors.black));
                }
                return Column(
                  children: topLiars
                      .asMap()
                      .entries
                      .map((entry) => Column(
                            children: [
                              Text(
                                '${DateFormat('MMMM yyyy').format(DateTime.now())} : اكثر المكيسين',
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 19,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              TopReusableCard(
                                kess:
                                    'المكيس رقم ${entry.key + 1}: ${entry.value.name}',
                                total: double.tryParse(
                                        entry.value.selectedSackCount) ??
                                    0.0,
                              ),
                            ],
                          ))
                      .toList(),
                );
              } else {
                // If there is no data, display a message indicating that no top liars are available.
                return Text(
                  "No top liars available.",
                  style: TextStyle(color: Colors.black),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
