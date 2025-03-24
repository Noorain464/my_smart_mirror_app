import 'package:flutter/material.dart';
class ClothingCard extends StatelessWidget {
  final dynamic imagePath;

  const ClothingCard({
    Key? key,
    required this.imagePath,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Card(
        child: Column(
          children: [
            Expanded(
              child: imagePath is String
                  ? Image.asset(imagePath, fit: BoxFit.cover)
                  : Image.memory(imagePath, fit: BoxFit.cover),
            ),
          ],
        ),
      ),
    );
  }
}
