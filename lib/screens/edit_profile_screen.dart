import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/auth_provider.dart';
import '../models/user_model.dart';
import '../utils/icon_styles.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _usernameController;
  late TextEditingController _phoneController;
  late TextEditingController _genderController;
  late TextEditingController _dateOfBirthController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final user = Provider.of<AuthProvider>(context, listen: false).user;

    _nameController = TextEditingController(text: user?.name ?? '');
    _usernameController = TextEditingController(text: user?.username ?? '');
    _phoneController = TextEditingController(text: user?.phoneNumber ?? '');
    _genderController = TextEditingController(text: user?.gender ?? 'Male');
    _dateOfBirthController = TextEditingController(
      text: user?.dateOfBirth ?? '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _phoneController.dispose();
    _genderController.dispose();
    _dateOfBirthController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dateOfBirthController.text.isNotEmpty
          ? DateFormat('dd MMM, yyyy').parse(_dateOfBirthController.text)
          : DateTime(2000),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).primaryColor,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _dateOfBirthController.text = DateFormat('dd MMM, yyyy').format(picked);
      });
    }
  }

  Future<void> _selectGender(BuildContext context) async {
    final List<String> genders = ['Male', 'Female', 'Other'];

    await showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.only(bottom: 20),
                child: Text(
                  'Select Gender',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ),
              ...genders
                  .map(
                    (gender) => ListTile(
                      title: Text(gender),
                      onTap: () {
                        setState(() {
                          _genderController.text = gender;
                        });
                        Navigator.pop(context);
                      },
                    ),
                  )
                  .toList(),
            ],
          ),
        );
      },
    );
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final success = await authProvider.updateUserProfile(
        name: _nameController.text.trim(),
        username: _usernameController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        gender: _genderController.text,
        dateOfBirth: _dateOfBirthController.text,
      );

      setState(() {
        _isLoading = false;
      });

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully')),
        );
        Navigator.of(context).pop();
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to update profile'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final user = Provider.of<AuthProvider>(context).user;

    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.black : const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Change Name',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          padding: EdgeInsets.zero,
          icon: ModernIconStyles.circularButton(
            icon: Icons.arrow_back_ios_new,
            onPressed: () => Navigator.of(context).pop(),
            context: context,
            size: 36,
            backgroundColor: isDarkMode
                ? Colors.grey.shade800
                : Colors.grey.shade100,
            iconColor: isDarkMode
                ? Colors.white
                : Theme.of(context).primaryColor,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Profile Picture
                Center(
                  child: Column(
                    children: [
                      Stack(
                        children: [
                          CircleAvatar(
                            radius: 40,
                            backgroundColor: Colors.grey.withOpacity(0.2),
                            child: Text(
                              user.name.isNotEmpty
                                  ? user.name[0].toUpperCase()
                                  : '?',
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                          Positioned(
                            right: 0,
                            bottom: 0,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Theme.of(context).primaryColor,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.edit,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Change Profile Picture',
                        style: TextStyle(
                          color: isDarkMode
                              ? Colors.grey
                              : Colors.grey.shade600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Profile Information Section
                _buildSectionHeader('Profile Information'),

                _buildInfoTile(
                  label: 'Name',
                  value: user.name,
                  controller: _nameController,
                  onTap: () {},
                ),

                _buildInfoTile(
                  label: 'Username',
                  value: user.username.isEmpty ? 'Set username' : user.username,
                  controller: _usernameController,
                  onTap: () {},
                ),

                const SizedBox(height: 24),

                // Personal Information Section
                _buildSectionHeader('Personal Information'),

                _buildInfoTile(
                  label: 'User ID',
                  value: user.id.isEmpty ? '45689' : user.id,
                  isEditable: false,
                  hasCopy: true,
                  onTap: () {},
                ),

                _buildInfoTile(
                  label: 'E-mail',
                  value: user.email,
                  isEditable: false,
                  onTap: () {},
                ),

                _buildInfoTile(
                  label: 'Phone Number',
                  value: user.phoneNumber.isEmpty
                      ? 'Add phone number'
                      : user.phoneNumber,
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  onTap: () {},
                ),

                _buildInfoTile(
                  label: 'Gender',
                  value: user.gender.isEmpty ? 'Male' : user.gender,
                  controller: _genderController,
                  readOnly: true,
                  onTap: () => _selectGender(context),
                ),

                _buildInfoTile(
                  label: 'Date of Birth',
                  value: user.dateOfBirth.isEmpty
                      ? 'Select date'
                      : user.dateOfBirth,
                  controller: _dateOfBirthController,
                  readOnly: true,
                  onTap: () => _selectDate(context),
                ),

                const SizedBox(height: 32),

                // Close Account Button
                Center(
                  child: TextButton(
                    onPressed: () {
                      // Show confirmation dialog for closing account
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Close Account'),
                          content: const Text(
                            'Are you sure you want to close your account? This action cannot be undone.',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(ctx).pop(),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.of(ctx).pop();
                                // Implement account closing functionality
                              },
                              child: const Text(
                                'Close Account',
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                    child: const Text(
                      'Close Account',
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDarkMode ? Colors.grey.shade900 : Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: _isLoading ? null : _saveProfile,
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).primaryColor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            disabledBackgroundColor: Colors.grey,
          ),
          child: _isLoading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : const Text(
                  'Save Changes',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white
                : Colors.black87,
          ),
        ),
      ),
    );
  }

  Widget _buildInfoTile({
    required String label,
    required String value,
    TextEditingController? controller,
    bool isEditable = true,
    bool readOnly = false,
    bool hasCopy = false,
    TextInputType keyboardType = TextInputType.text,
    required Function() onTap,
  }) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey.shade900 : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        title: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600,
          ),
        ),
        subtitle: controller != null
            ? TextField(
                controller: controller,
                readOnly: readOnly,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: isDarkMode ? Colors.white : Colors.black87,
                ),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                  isDense: true,
                ),
                keyboardType: keyboardType,
                onTap: readOnly ? onTap : null,
              )
            : Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: isDarkMode ? Colors.white : Colors.black87,
                ),
              ),
        trailing: isEditable
            ? const Icon(Icons.chevron_right)
            : hasCopy
            ? IconButton(
                icon: const Icon(Icons.copy, size: 20),
                onPressed: () {
                  // Copy to clipboard functionality
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Copied to clipboard')),
                  );
                },
              )
            : null,
        onTap: isEditable ? onTap : null,
      ),
    );
  }
}
