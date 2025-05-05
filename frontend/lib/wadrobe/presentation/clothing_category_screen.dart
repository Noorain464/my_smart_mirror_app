// ClothingCategoryScreen.dart

import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:my_smart_mirror_app/wadrobe/widgets/clothing_card.dart';

class ClothingCategoryScreen extends StatefulWidget {
  final String categoryName;

  const ClothingCategoryScreen({Key? key, required this.categoryName}) : super(key: key);

  @override
  _ClothingCategoryScreenState createState() => _ClothingCategoryScreenState();
}

class _ClothingCategoryScreenState extends State<ClothingCategoryScreen> {
  List<Uint8List> clothingItems = [];

  void _uploadClothing() async {
    try {
      final XFile? pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 50);
      if (pickedFile != null) {
        final Uint8List bytes = await pickedFile.readAsBytes();
        setState(() {
          clothingItems.add(bytes);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error uploading item: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          widget.categoryName,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            color: Colors.white,
          ),
        ),
        backgroundColor: Color(0xFF121212),
        elevation: 1,
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: clothingItems.isEmpty
          ? Center(
              child: Text(
                "No items in this category",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: clothingItems.length,
              itemBuilder: (context, index) {
                return ClothingCard(imagePath: clothingItems[index]);
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _uploadClothing,
        label: Text("Add Item"),
        icon: Icon(Icons.add),
        backgroundColor: Color(0xFF3A8DFF),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
