import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker_web/image_picker_web.dart';
import 'package:my_smart_mirror_app/wadrobe/widgets/clothing_card.dart';

// Reusable screen for any clothing category
class ClothingCategoryScreen extends StatefulWidget {
  final String categoryName;

  const ClothingCategoryScreen({
    Key? key,
    required this.categoryName,
  }) : super(key: key);

  @override
  _ClothingCategoryScreenState createState() => _ClothingCategoryScreenState();
}

class _ClothingCategoryScreenState extends State<ClothingCategoryScreen> {
  List<Uint8List> clothingItems = [];

  void _uploadClothing() async {
    try {
      final Uint8List? pickedFile = await ImagePickerWeb.getImageAsBytes();
      if (pickedFile != null) {
        clothingItems.add(pickedFile);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error uploading item: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.categoryName,
          style: const TextStyle(color: Colors.white24),
        ),
        backgroundColor: Colors.black,
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: clothingItems.length,
        itemBuilder: (context, index) {
          return ClothingCard(
            imagePath: clothingItems[index],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _uploadClothing,
        tooltip: 'Add Item',
        child: const Icon(Icons.add),
      ),
    );
  }
}
