import 'package:flutter/material.dart';
class CategoryCard extends StatelessWidget {
  final String title;
  final dynamic imagePath;
  final VoidCallback onTap;

  const CategoryCard({
    Key? key,
    required this.title,
    required this.imagePath,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        child: Column(
          children: [
            Expanded(
              child: imagePath is String
                  ? Image.asset(imagePath, fit: BoxFit.cover)
                  : Image.memory(imagePath, fit: BoxFit.cover),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(title, style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}
