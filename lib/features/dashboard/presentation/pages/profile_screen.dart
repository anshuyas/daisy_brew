import 'dart:io';
import 'package:daisy_brew/features/auth/presentation/pages/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'notification_screen.dart';
import 'shipping_address_screen.dart';
import 'change_password_screen.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  final String token;
  final String? initialProfilePicture;
  final String fullName;
  final String email;
  final void Function(String newURL, {String? updatedName}) onProfileUpdated;

  const ProfileScreen({
    super.key,
    required this.token,
    this.initialProfilePicture,
    required this.fullName,
    required this.email,
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

  late String currentFullName;
  late String currentEmail;

  @override
  void initState() {
    super.initState();
    _loadProfilePicture();
    _loadProfileInfo();
    currentFullName = widget.fullName;
    currentEmail = widget.email;
  }

  // Load saved profile info
  Future<void> _loadProfileInfo() async {
    final prefs = await SharedPreferences.getInstance();
    final userKey = widget.email;
    setState(() {
      currentFullName = prefs.getString('$userKey-fullName') ?? widget.fullName;
      currentEmail = prefs.getString('$userKey-email') ?? widget.email;
    });
  }

  // Load saved profile picture
  Future<void> _loadProfilePicture() async {
    final prefs = await SharedPreferences.getInstance();
    final userKey = widget.email;
    final savedUrl = prefs.getString('$userKey-profile_picture');

    if (savedUrl != null && savedUrl.isNotEmpty) {
      setState(() {
        _uploadedImageUrl = savedUrl;
      });
    }
  }

  // Save profile picture locally
  Future<void> _saveProfilePictureLocally(String url) async {
    final prefs = await SharedPreferences.getInstance();
    final userKey = widget.email;
    await prefs.setString('$userKey-profile_picture', url);
  }

  // Save fullName & email locally
  Future<void> _saveProfileInfoLocally(String fullName, String email) async {
    final prefs = await SharedPreferences.getInstance();
    final userKey = widget.email;
    await prefs.setString('$userKey-fullName', fullName);
    await prefs.setString('$userKey-email', email);
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
        ? 'http://192.168.254.50:3000/api/v1'
        : 'http://10.0.2.2:3000/api/v1';
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
            "http://192.168.254.50:3000/public/profile_pictures/$newURL";

        setState(() {
          _uploadedImageUrl = fullUrl;
        });

        await _saveProfilePictureLocally(fullUrl);
        widget.onProfileUpdated(fullUrl, updatedName: currentFullName);

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

  void _onMenuTap(String menu) async {
    if (menu == "Edit Profile") {
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => EditProfileScreen(
            token: widget.token,
            fullName: currentFullName,
            email: currentEmail,
            saveProfileInfoLocally: _saveProfileInfoLocally, // pass function
          ),
        ),
      );

      // Update UI if user updated profile
      if (result != null) {
        setState(() {
          currentFullName = result["fullName"];
          currentEmail = result["email"];
        });
        widget.onProfileUpdated(
          _uploadedImageUrl ?? "",
          updatedName: currentFullName,
        );
      }
    } else if (menu == "Notifications") {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => NotificationScreen(token: widget.token),
        ),
      );
    } else if (menu == "Shipping Address") {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ShippingAddressScreen(
            token: widget.token,
            currentEmail: currentEmail,
          ),
        ),
      );
    } else if (menu == "Change Password") {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ChangePasswordScreen(token: widget.token),
        ),
      );
    }
  }

  void _signOut() async {
    final prefs = await SharedPreferences.getInstance();
    final userKey = widget.email;
    await prefs.remove('$userKey-profile_picture');
    await prefs.remove('$userKey-fullName');
    await prefs.remove('$userKey-email');
    await prefs.remove('$userKey-shipping_address');
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => LoginScreen()),
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
              Text(
                currentFullName,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                currentEmail,
                style: const TextStyle(fontSize: 16, color: Colors.grey),
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
                onTap: () => _onMenuTap("Edit Profile"),
              ),
              _buildMenuCard(
                icon: Icons.notifications,
                title: "Notifications",
                onTap: () => _onMenuTap("Notifications"),
              ),
              _buildMenuCard(
                icon: Icons.location_on,
                title: "Shipping Address",
                onTap: () => _onMenuTap("Shipping Address"),
              ),
              _buildMenuCard(
                icon: Icons.lock,
                title: "Change Password",
                onTap: () => _onMenuTap("Change Password"),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _signOut,
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

Widget buildInputField({
  required TextEditingController controller,
  required String label,
  required IconData icon,
  bool obscureText = false,
  int maxLines = 1,
}) {
  return TextField(
    controller: controller,
    obscureText: obscureText,
    maxLines: maxLines,
    decoration: InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: Colors.brown),
      filled: true,
      fillColor: Colors.brown[50],
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.brown, width: 2),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.brown.shade100, width: 1),
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
    ),
  );
}
