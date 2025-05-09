import 'package:flutter/material.dart';

class ClothingCard extends StatelessWidget {
  final dynamic imagePath;

  const ClothingCard({
    Key? key,
    required this.imagePath,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          // Handle tap event if needed
        },
        child: Container(
          decoration: BoxDecoration(
            color: Color(0xFF1E1E1E), // Dark card background for dark mode
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Color(0xFF2C2C2C), width: 1), // Dark border
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.5),
                blurRadius: 6,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: imagePath is String
                ? Image.network(imagePath, fit: BoxFit.cover)
                : Image.memory(imagePath, fit: BoxFit.cover),
          ),
        ),
      ),
    );
  }
}
