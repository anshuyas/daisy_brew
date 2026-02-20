import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreen extends StatefulWidget {
  final String token;
  final String? initialProfilePicture;
  final String fullName;
  final void Function(String newURL) onProfileUpdated;

  const ProfileScreen({
    super.key,
    required this.token,
    this.initialProfilePicture,
    this.fullName = "User",
    required this.onProfileUpdated,
  });

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  XFile? _image;
  String? _uploadedImageUrl;
  bool _isUploading = false;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadProfilePicture();
  }

  // Load saved profile image URL from device
  Future<void> _loadProfilePicture() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _uploadedImageUrl = prefs.getString('profile_picture_url');
    });
  }

  // Save profile image URL locally
  Future<void> _saveProfilePictureLocally(String url) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('profile_picture_url', url);
  }

  Future<bool> _requestPermissions() async {
    final cameraStatus = await Permission.camera.request();

    PermissionStatus storageStatus;
    if (Platform.isAndroid) {
      if (await Permission.photos.isGranted ||
          await Permission.storage.isGranted) {
        storageStatus = PermissionStatus.granted;
      } else {
        storageStatus = await Permission.photos.request();
        if (storageStatus.isDenied) {
          storageStatus = await Permission.storage.request();
        }
      }
    } else {
      storageStatus = PermissionStatus.granted;
    }

    return cameraStatus.isGranted && storageStatus.isGranted;
  }

  void _showImageSourceActionSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Navigator.of(context).pop();
                _pickImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take a Photo'),
              onTap: () {
                Navigator.of(context).pop();
                _pickImage(ImageSource.camera);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      // Request permissions
      bool granted = await _requestPermissions();
      if (!granted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Permissions denied")));
        return;
      }

      final XFile? image = await _picker.pickImage(
        source: source,
        imageQuality: 80,
      );

      if (image != null) {
        setState(() => _image = image);
        await _uploadProfilePicture(image);
      }
    } catch (_) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Failed to pick image")));
    }
  }

  Future<void> _uploadProfilePicture(XFile image) async {
    setState(() => _isUploading = true);

    final baseUrl = Platform.isAndroid
        ? 'http://192.168.254.10:3000/api/v1' // real device
        : 'http://10.0.2.2:3000/api/v1'; // emulator

    final url = "$baseUrl/profile/upload";

    final formData = FormData.fromMap({
      "profilePicture": await MultipartFile.fromFile(
        image.path,
        filename: image.name,
      ),
    });

    final dio = Dio();
    dio.options.headers['Authorization'] = 'Bearer ${widget.token}';

    try {
      final response = await dio.post(url, data: formData);
      final newURL = response.data['filename'] as String?;

      if (newURL != null) {
        final fullUrl =
            "http://192.168.254.10:3000/public/profile_pictures/$newURL";

        setState(() {
          _uploadedImageUrl = fullUrl;
        });

        await _saveProfilePictureLocally(fullUrl); // save locally

        widget.onProfileUpdated(fullUrl);
        // Directly show success message here
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Profile picture updated successfully")),
        );
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Upload failed")));
      }
    } catch (_) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Upload failed")));
    } finally {
      setState(() => _isUploading = false);
    }
  }

  Widget _buildMenuCard({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.brown[100],
          child: Icon(icon, color: Colors.brown),
        ),
        title: Text(title, style: const TextStyle(fontSize: 16)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
        backgroundColor: Colors.brown,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            children: [
              Stack(
                children: [
                  CircleAvatar(
                    radius: 70,
                    backgroundColor: Colors.grey[300],
                    backgroundImage: _uploadedImageUrl != null
                        ? NetworkImage(_uploadedImageUrl!)
                        : null,
                    child: _uploadedImageUrl == null
                        ? const Icon(
                            Icons.person,
                            size: 70,
                            color: Colors.white,
                          )
                        : null,
                  ),
                  // Loading overlay
                  if (_isUploading)
                    Container(
                      width: 140,
                      height: 140,
                      decoration: BoxDecoration(
                        color: Colors.black45,
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      ),
                    ),
                  // Camera icon
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: _showImageSourceActionSheet,
                      child: CircleAvatar(
                        radius: 22,
                        backgroundColor: Colors.brown,
                        child: const Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _showImageSourceActionSheet,
                icon: const Icon(Icons.upload_file),
                label: const Text("Change Profile Picture"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.brown,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  textStyle: const TextStyle(fontSize: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              _buildMenuCard(
                icon: Icons.edit,
                title: "Edit Profile",
                onTap: () {},
              ),
              _buildMenuCard(
                icon: Icons.notifications,
                title: "Notifications",
                onTap: () {},
              ),
              _buildMenuCard(
                icon: Icons.location_on,
                title: "Shipping Address",
                onTap: () {},
              ),
              _buildMenuCard(
                icon: Icons.lock,
                title: "Change Password",
                onTap: () {},
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.brown,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text("Sign Out", style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
