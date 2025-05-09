// ClothingCategoryScreen.dart

import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:my_smart_mirror_app/wadrobe/widgets/clothing_card.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:uuid/uuid.dart';

class ClothingCategoryScreen extends StatefulWidget {
  final String categoryName;

  const ClothingCategoryScreen({Key? key, required this.categoryName})
    : super(key: key);

  @override
  _ClothingCategoryScreenState createState() => _ClothingCategoryScreenState();
}

class _ClothingCategoryScreenState extends State<ClothingCategoryScreen> {
  List<Map<String, dynamic>> clothingItems = [];
  final String backendUrl = 'http://192.168.1.233:8000';
  final String cloudinaryUploadUrl =
      'https://api.cloudinary.com/v1_1/dgqvheahf/image/upload';
  final String cloudinaryUploadPreset = 'flutter_upload';

  @override
  void initState() {
    super.initState();
    _fetchClothingItems();
  }

  Future<void> _fetchClothingItems() async {
    try {
      final response = await http.get(
        Uri.parse('$backendUrl/wardrobe/${widget.categoryName}'),
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          clothingItems =
              data
                  .map(
                    (item) => {
                      'id': item['id'],
                      'image_url': item['image_url'],
                    },
                  )
                  .toList();
        });
      } else {
        throw Exception('Failed to load clothing items');
      }

    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error fetching items: $e')));
    }
  }

  Future<String> _uploadToCloudinary(Uint8List imageBytes) async {
    final uri = Uri.parse(cloudinaryUploadUrl);
    final request =
        http.MultipartRequest('POST', uri)
          ..fields['upload_preset'] = cloudinaryUploadPreset
          ..files.add(
            http.MultipartFile.fromBytes(
              'file',
              imageBytes,
              filename: 'image.jpg',
            ),
          );

    final response = await request.send();

    if (response.statusCode == 200) {
      final resStr = await response.stream.bytesToString();
      final resJson = json.decode(resStr);
      return resJson['secure_url'];
    } else {
      throw Exception('Failed to upload image to Cloudinary');
    }
  }

  void _uploadClothing() async {
    try {
      final XFile? pickedFile = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: 50,
      );
      if (pickedFile != null) {
        final Uint8List bytes = await pickedFile.readAsBytes();
        final imageUrl = await _uploadToCloudinary(bytes);

        // Generate a unique id for the item
        final String id = Uuid().v4();

        final response = await http.post(
          Uri.parse('$backendUrl/wardrobe/${widget.categoryName}'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({'id': id, 'image_url': imageUrl}),
        );

        if (response.statusCode == 201) {
          setState(() {
            clothingItems.add({'id': id, 'image_url': imageUrl});
          });
        } else {
          throw Exception('Failed to add clothing item');
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error uploading item: $e')));
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
      body:
          clothingItems.isEmpty
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
                  final item = clothingItems[index];
                  return ClothingCard(imagePath: item['image_url']);
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
