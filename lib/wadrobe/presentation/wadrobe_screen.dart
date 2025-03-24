import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker_web/image_picker_web.dart';
import '../widgets/category_card.dart';
import 'clothing_category_screen.dart';
class WardrobeScreen extends StatefulWidget {
  @override
  _WardrobeScreenState createState() => _WardrobeScreenState();
}

class _WardrobeScreenState extends State<WardrobeScreen> {
  List<Map<String, dynamic>> categories = [];

  void _addCategory() async {
    try {
      final Uint8List? pickedFile = await ImagePickerWeb.getImageAsBytes();
      if (pickedFile == null) {
        throw Exception('No image selected');
      }

      final categoryName = await showDialog<String>(
        context: context,
        builder: (context) {
          final _formKey = GlobalKey<FormState>();
          final _categoryNameController = TextEditingController();
          return AlertDialog(
            title: Text('Add Category'),
            content: Form(
              key: _formKey,
              child: TextFormField(
                decoration: InputDecoration(
                  labelText: 'Category Name',
                ),
                controller: _categoryNameController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a category name';
                  }
                  if (categories.any((category) => category['name'] == value)) {
                    return 'Category name already exists';
                  }
                  return null;
                },
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    Navigator.of(context).pop(_categoryNameController.text);
                  }
                },
                child: Text('Add'),
              ),
            ],
          );
        },
      );
      if (categoryName != null) {
        setState(() {
          categories.add({
            'name': categoryName,
            'image': pickedFile,
          });
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error adding category: $e')),
      );
    }
  }

  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.purple.shade900,
      appBar: AppBar(
        title: Text(
          "Wardrobe",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
            color: Colors.white24,
          ),
        ),
        backgroundColor: Colors.black,
      ),
      body: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        padding: const EdgeInsets.all(16),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          return CategoryCard(
            title: category['name'],
            imagePath: category['image'], 
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ClothingCategoryScreen(
                  categoryName: category['name']
                ),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addCategory,
        tooltip: 'Add Category',
        child: const Icon(Icons.add),
      ),
    );
  }
}
