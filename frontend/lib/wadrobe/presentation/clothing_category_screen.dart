import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:uuid/uuid.dart';
import 'package:my_smart_mirror_app/wadrobe/widgets/clothing_card.dart';

class ClothingCategoryScreen extends StatefulWidget {
  final String categoryName;

  const ClothingCategoryScreen({Key? key, required this.categoryName})
      : super(key: key);

  @override
  _ClothingCategoryScreenState createState() => _ClothingCategoryScreenState();
}

class _ClothingCategoryScreenState extends State<ClothingCategoryScreen> {
  List<Map<String, dynamic>> clothingItems = [];
  final String backendUrl = 'http://192.168.13.212:8000';
  final String cloudinaryUploadUrl =
      'https://api.cloudinary.com/v1_1/dgqvheahf/image/upload';
  final String cloudinaryUploadPreset = 'flutter_upload';

  @override
  void initState() {
    super.initState();
    _fetchClothingItems();
  }

  // Fetch items in category
  Future<void> _fetchClothingItems() async {
    try {
      final response =
          await http.get(Uri.parse('$backendUrl/wardrobe/${widget.categoryName}'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          clothingItems = data
              .map((item) => {
                    'id': item['id'],
                    'image_url': item['image_url'],
                  })
              .toList();
        });
      } else {
        throw Exception('Failed to load clothing items');
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error fetching items: $e')));
    }
  }

  // Upload to Cloudinary
  Future<String> _uploadToCloudinary(Uint8List imageBytes) async {
    final uri = Uri.parse(cloudinaryUploadUrl);
    final request = http.MultipartRequest('POST', uri)
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

  // Add new item to wardrobe
  void _uploadClothing() async {
    try {
      final XFile? pickedFile = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: 50,
      );
      if (pickedFile != null) {
        final Uint8List bytes = await pickedFile.readAsBytes();
        final imageUrl = await _uploadToCloudinary(bytes);

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
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error uploading item: $e')));
    }
  }

  // Delete clothing item
  void _deleteClothingItem(String itemId) async {
    try {
      final response = await http.delete(
        Uri.parse('$backendUrl/wardrobe/${widget.categoryName}/$itemId'),
      );

      if (response.statusCode == 204) {
        setState(() {
          clothingItems.removeWhere((item) => item['id'] == itemId);
        });
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Item deleted')));
      } else if (response.statusCode == 404) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Item not found')));
      } else {
        throw Exception('Failed to delete item');
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error deleting item: $e')));
    }
  }

  // Confirm delete dialog
  void _confirmDelete(String itemId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Item'),
        content: const Text('Are you sure you want to delete this item?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteClothingItem(itemId);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
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
        backgroundColor: const Color(0xFF121212),
        elevation: 1,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: clothingItems.isEmpty
          ? const Center(
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
                return GestureDetector(
                  onLongPress: () => _confirmDelete(item['id']),
                  child: ClothingCard(imagePath: item['image_url']),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _uploadClothing,
        label: const Text("Add Item"),
        icon: const Icon(Icons.add),
        backgroundColor: const Color(0xFF3A8DFF),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
