import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'dart:convert';
import '../models/destination.dart';
import '../services/destination_provider.dart';
import '../services/auth_provider.dart';

class AddDestinationScreen extends StatefulWidget {
  const AddDestinationScreen({super.key});

  @override
  _AddDestinationScreenState createState() => _AddDestinationScreenState();
}

class _AddDestinationScreenState extends State<AddDestinationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _locationController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _ratingController = TextEditingController();
  List<File> _selectedImages = [];
  bool _isLoading = false;

  final ImagePicker _picker = ImagePicker();

  // Cloudinary config - Replace with your own
  final String cloudName = 'dojmlppez'; // Thay bằng cloud name của bạn
  final String uploadPreset = 'ej0fmspl'; // Thay bằng upload preset

  Future<void> _pickImage(ImageSource source) async {
    final XFile? image = await _picker.pickImage(source: source);
    if (image != null) {
      setState(() {
        _selectedImages.add(File(image.path));
      });
    }
  }

  Future<String?> _uploadToCloudinary(File image) async {
    try {
      final uri = Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/upload');
      final request = http.MultipartRequest('POST', uri)
        ..fields['upload_preset'] = uploadPreset
        ..files.add(await http.MultipartFile.fromPath('file', image.path));

      final response = await request.send();
      if (response.statusCode == 200) {
        final responseData = await response.stream.bytesToString();
        final json = jsonDecode(responseData);
        return json['secure_url'];
      }
    } catch (e) {
      // Handle upload error silently or show user-friendly message
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    if (user == null || user.role != 'admin') {
      return Scaffold(
        appBar: AppBar(title: const Text('Access Denied')),
        body: const Center(
          child: Text('You do not have permission to add destinations.'),
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Add Destination')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Name'),
                  validator: (value) => value!.isEmpty ? 'Required' : null,
                ),
                TextFormField(
                  controller: _locationController,
                  decoration: const InputDecoration(labelText: 'Location'),
                  validator: (value) => value!.isEmpty ? 'Required' : null,
                ),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(labelText: 'Description'),
                  maxLines: 3,
                  validator: (value) => value!.isEmpty ? 'Required' : null,
                ),
                TextFormField(
                  controller: _priceController,
                  decoration: const InputDecoration(labelText: 'Price'),
                  keyboardType: TextInputType.number,
                  validator: (value) => value!.isEmpty ? 'Required' : null,
                ),
                TextFormField(
                  controller: _ratingController,
                  decoration: const InputDecoration(labelText: 'Rating (0-5)'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    final rating = double.tryParse(value!);
                    if (rating == null || rating < 0 || rating > 5) {
                      return 'Enter a valid rating (0-5)';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                const Text('Images', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Row(
                  children: [
                    ElevatedButton.icon(
                      onPressed: () => _pickImage(ImageSource.camera),
                      icon: const Icon(Icons.camera),
                      label: const Text('Camera'),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton.icon(
                      onPressed: () => _pickImage(ImageSource.gallery),
                      icon: const Icon(Icons.photo),
                      label: const Text('Gallery'),
                    ),
                  ],
                ),
                if (_selectedImages.isNotEmpty)
                  SizedBox(
                    height: 100,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _selectedImages.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Image.file(_selectedImages[index], width: 80, height: 80, fit: BoxFit.cover),
                        );
                      },
                    ),
                  ),
                const SizedBox(height: 20),
                _isLoading
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                        onPressed: _addDestination,
                        child: const Text('Add Destination'),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _addDestination() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      double price;
      double rating;
      try {
        price = double.parse(_priceController.text.trim());
        rating = double.parse(_ratingController.text.trim());
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid price or rating format')),
        );
        return;
      }

      // Upload selected images to Cloudinary
      List<String> uploadedUrls = [];
      for (var image in _selectedImages) {
        final url = await _uploadToCloudinary(image);
        if (url != null) {
          uploadedUrls.add(url);
        }
      }

      final destination = Destination(
        id: '', // Will be set by Realtime DB
        name: _nameController.text.trim(),
        location: _locationController.text.trim(),
        description: _descriptionController.text.trim(),
        price: price,
        rating: rating,
        imageUrls: uploadedUrls,
      );

      await context.read<DestinationProvider>().addDestination(destination);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Destination added successfully!')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add destination: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _ratingController.dispose();
    super.dispose();
  }
}