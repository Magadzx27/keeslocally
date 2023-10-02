import 'package:flutter/material.dart';

// ignore: must_be_immutable
class TopReusableCard extends StatelessWidget {
  final String kess;
  double total = 0.0;

  TopReusableCard({
    Key? key,
    required this.kess,
    required this.total,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: SizedBox(
        width: double.infinity,
        child: Card(
          color: Color(0xFF019587),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          elevation: 10,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.all(30.0),
                child: Row(
                  children: [
                    Padding(
                      padding: EdgeInsets.fromLTRB(50, 1, 10, 1),
                      child: Text(
                        textAlign: TextAlign.center,
                        total.toString(),
                        style: const TextStyle(
                          fontSize: 20,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(1, 1, 10, 1),
                      child: Text(
                        textAlign: TextAlign.center,
                        kess,
                        style: const TextStyle(
                          fontSize: 20,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
