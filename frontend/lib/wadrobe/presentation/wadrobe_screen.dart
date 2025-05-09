// WardrobeScreen.dart

import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../widgets/category_card.dart';
import 'clothing_category_screen.dart';

class WardrobeScreen extends StatefulWidget {
  @override
  _WardrobeScreenState createState() => _WardrobeScreenState();
}

class _WardrobeScreenState extends State<WardrobeScreen> {
  List<Map<String, dynamic>> categories = [];
  final String backendUrl = 'http://192.168.1.233:8000';

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  Future<void> _fetchCategories() async {
    try {
      final response = await http.get(Uri.parse('$backendUrl/wardrobe'));
      print("Fetching categories, status code: ${response.statusCode}");
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        print("Fetched categories JSON: $data");

        setState(() {
          categories =
              data
                  .map(
                    (item) => {
                      'name': item['name'],
                      'image': item['image_url'],
                    },
                  )
                  .toList();
        });

        print("Mapped categories: $categories");
      } else {
        throw Exception('Failed to load categories');
      }
    } catch (e) {
      print("Error in _fetchCategories: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error fetching categories: $e')));
    }
  }

  Future<String> _uploadToCloudinary(Uint8List imageBytes) async {
    print("Uploading image to Cloudinary...");
    final uri = Uri.parse(
      'https://api.cloudinary.com/v1_1/dgqvheahf/image/upload',
    );

    final request =
        http.MultipartRequest('POST', uri)
          ..fields['upload_preset'] = 'flutter_upload'
          ..files.add(
            http.MultipartFile.fromBytes(
              'file',
              imageBytes,
              filename: 'image.jpg',
            ),
          );

    final response = await request.send();
    print("Cloudinary response status: ${response.statusCode}");

    if (response.statusCode == 200) {
      final resStr = await response.stream.bytesToString();
      final resJson = json.decode(resStr);
      print("Cloudinary response JSON: $resJson");

      return resJson['secure_url'];
    } else {
      throw Exception('Failed to upload image to Cloudinary');
    }
  }

  void _addCategory() async {
    try {
      final XFile? pickedFile = await ImagePicker().pickImage(
        source: ImageSource.gallery,
      );
      if (pickedFile == null) {
        print("No image picked.");
        return;
      }
      final Uint8List imageBytes = await pickedFile.readAsBytes();
      print("Image picked. Size: ${imageBytes.length}");

      final categoryName = await showDialog<String>(
        context: context,
        builder: (context) {
          final _formKey = GlobalKey<FormState>();
          final _controller = TextEditingController();

          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Text(
              'New Category',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            content: Form(
              key: _formKey,
              child: TextFormField(
                controller: _controller,
                decoration: InputDecoration(
                  hintText: 'Enter Category Name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty)
                    return 'Please enter a name';
                  if (categories.any((cat) => cat['name'] == value))
                    return 'Name already exists';
                  return null;
                },
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    Navigator.of(context).pop(_controller.text);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF3A8DFF),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text('Add'),
              ),
            ],
          );
        },
      );

      if (categoryName != null) {
        print("Uploading category: $categoryName");
        final imageUrl = await _uploadToCloudinary(imageBytes);
        print("Received image URL: $imageUrl");

        final response = await http.post(
          Uri.parse('$backendUrl/wardrobe'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({'name': categoryName, 'image_url': imageUrl}),
        );
        print(
          "POST /wardrobe response: ${response.statusCode}, body: ${response.body}",
        );

        if (response.statusCode == 201) {
          setState(() {
            categories.add({'name': categoryName, 'image': imageUrl});
          });
          print("Category added to UI.");
        } else {
          throw Exception('Failed to add category');
        }
      }
    } catch (e) {
      print("Error in _addCategory: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
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
      body:
          categories.isEmpty
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
                    onTap:
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => ClothingCategoryScreen(
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
