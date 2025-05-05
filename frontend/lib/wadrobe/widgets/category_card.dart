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
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            color: Color(0xFF1E1E1E), // Dark card background for dark mode
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Color(0xFF2C2C2C)), // Dark border
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.5),
                blurRadius: 6,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                child: imagePath is String
                    ? Image.asset(imagePath, fit: BoxFit.cover, height: 140)
                    : Image.memory(imagePath, fit: BoxFit.cover, height: 140),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 12.0),
                child: Text(
                  title,
                  style: TextStyle(
                    fontFamily: 'Roboto',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white, // White text for contrast
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
