// WardrobeScreen.dart

import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:firebase_storage/firebase_storage.dart';
import '../widgets/category_card.dart';
import 'clothing_category_screen.dart';

class WardrobeScreen extends StatefulWidget {
  @override
  _WardrobeScreenState createState() => _WardrobeScreenState();
}

class _WardrobeScreenState extends State<WardrobeScreen> {
  List<Map<String, dynamic>> categories = [];
  final String backendUrl = '10.51.9.84:8000'; 

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  Future<void> _fetchCategories() async {
    try {
      final response = await http.get(Uri.parse('$backendUrl/wardrobe'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          categories = data.map((item) => {
            'name': item['name'],
            'image': item['image_url'],
          }).toList();
        });
      } else {
        throw Exception('Failed to load categories');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error fetching categories: \$e')));
    }
  }

  Future<String> _uploadImage(Uint8List imageBytes, String categoryName) async {
    try {
      final storageRef = FirebaseStorage.instance.ref().child('wardrobe_images/\$categoryName.jpg');
      final uploadTask = storageRef.putData(imageBytes);
      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      throw Exception('Image upload failed: \$e');
    }
  }

  void _addCategory() async {
    try {
      final XFile? pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (pickedFile == null) return;
      final Uint8List imageBytes = await pickedFile.readAsBytes();

      final categoryName = await showDialog<String>(
        context: context,
        builder: (context) {
          final _formKey = GlobalKey<FormState>();
          final _controller = TextEditingController();

          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Text('New Category', style: TextStyle(fontWeight: FontWeight.bold)),
            content: Form(
              key: _formKey,
              child: TextFormField(
                controller: _controller,
                decoration: InputDecoration(
                  hintText: 'Enter Category Name',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Please enter a name';
                  if (categories.any((cat) => cat['name'] == value)) return 'Name already exists';
                  return null;
                },
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.of(context).pop(), child: Text('Cancel')),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    Navigator.of(context).pop(_controller.text);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF3A8DFF),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: Text('Add'),
              ),
            ],
          );
        },
      );

      if (categoryName != null) {
        final imageUrl = await _uploadImage(imageBytes, categoryName);
        final response = await http.post(
          Uri.parse('$backendUrl/wardrobe'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({'name': categoryName, 'image_url': imageUrl}),
        );
        if (response.statusCode == 201) {
          setState(() {
            categories.add({'name': categoryName, 'image': imageUrl});
          });
        } else {
          throw Exception('Failed to add category');
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: \$e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Color(0xFF121212),
        elevation: 1,
        centerTitle: true,
        title: Text(
          "Wardrobe",
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 24,
            color: Colors.white,
          ),
        ),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: categories.isEmpty
          ? Center(
              child: Text(
                "No categories yet",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
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
                        categoryName: category['name'],
                      ),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addCategory,
        label: Text("Add Category"),
        icon: Icon(Icons.add),
        backgroundColor: Color(0xFF3A8DFF),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
