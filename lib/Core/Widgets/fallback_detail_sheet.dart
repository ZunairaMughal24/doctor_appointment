import 'package:flutter/material.dart';

class FallbackDetailSheet extends StatelessWidget {
  final Map<String, dynamic> doc;
  const FallbackDetailSheet({super.key, required this.doc});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      builder: (_, ctrl) => Container(
        decoration: const BoxDecoration(
          color: Color.fromARGB(255, 247, 249, 252),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: ListView(
          controller: ctrl,
          padding: const EdgeInsets.all(20),
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            _row('Name', doc['name'] ?? ''),
            _row('Speciality', doc['speciality'] ?? ''),
            _row('Experience', doc['experience'] ?? ''),
            _row('Location', doc['location'] ?? ''),
            _row('Availability', doc['availability'] ?? ''),
            _row('Contact', doc['number'] ?? ''),
            const SizedBox(height: 8),
            const Text(
              'Description',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: Color.fromARGB(255, 11, 77, 105),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              doc['description'] ?? '',
              style: const TextStyle(
                fontSize: 14,
                color: Color.fromARGB(255, 120, 120, 120),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(String label, String value) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: Color.fromARGB(255, 11, 77, 105),
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                color: Color.fromARGB(255, 120, 120, 120),
              ),
            ),
          ],
        ),
      );
}
