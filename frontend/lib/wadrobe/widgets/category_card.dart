import 'dart:typed_data';
import 'package:flutter/material.dart';

class CategoryCard extends StatelessWidget {
  final String title;
  final dynamic imagePath;
  final VoidCallback onTap;
  final VoidCallback? onDelete;

  const CategoryCard({
    Key? key,
    required this.title,
    required this.imagePath,
    required this.onTap,
    this.onDelete,
  }) : super(key: key);

  bool get isValidImage =>
      (imagePath is String && imagePath != "empty") || imagePath is Uint8List;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          clipBehavior: Clip.none, // Allows button to overflow outside card
          children: [
            // Card Body
            Container(
              constraints: const BoxConstraints(
                minHeight: 180,
                maxHeight: 220,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF2C2C2C)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.5),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Image
                  Flexible(
                    flex: 2,
                    child: ClipRRect(
                      borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(12)),
                      child: isValidImage
                          ? (imagePath is String
                              ? Image.network(
                                  imagePath,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                )
                              : Image.memory(
                                  imagePath,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                ))
                          : Container(
                              color: Colors.grey[800],
                              child: const Center(
                                child: Icon(
                                  Icons.image_not_supported,
                                  color: Colors.grey,
                                  size: 48,
                                ),
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Title
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 8.0,
                      horizontal: 12.0,
                    ),
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),

            // Floating small delete "X"
            if (onDelete != null)
              Positioned(
                top: -8, // slightly above the card
                right: -8, // slightly outside the card
                child: GestureDetector(
                  onTap: onDelete,
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: Colors.redAccent,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.4),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 16, // small X
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
