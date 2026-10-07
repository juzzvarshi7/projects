import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/providers/auth_provider.dart';
import '../../../core/models/user_model.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_button.dart';
import '../auth/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _departmentController = TextEditingController();
  
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() {
    final user = Provider.of<AuthProvider>(context, listen: false).currentUser;
    if (user != null) {
      _firstNameController.text = user.firstName;
      _lastNameController.text = user.lastName;
      _emailController.text = user.email;
      _phoneController.text = user.phoneNumber ?? '';
      _departmentController.text = user.department ?? '';
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _departmentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        actions: [
          if (!_isEditing)
            IconButton(
              onPressed: () {
                setState(() {
                  _isEditing = true;
                });
              },
              icon: const Icon(Icons.edit),
              tooltip: 'Edit Profile',
            ),
        ],
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          final user = authProvider.currentUser;
          
          if (user == null) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Profile Header
                _buildProfileHeader(user),
                
                const SizedBox(height: 32),
                
                // Profile Form
                _buildProfileForm(authProvider),
                
                const SizedBox(height: 32),
                
                // Settings Section
                _buildSettingsSection(context),
                
                const SizedBox(height: 32),
                
                // Sign Out Button
                _buildSignOutButton(authProvider),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileHeader(UserModel user) {
    return Column(
      children: [
        // Profile Picture
        CircleAvatar(
          radius: 50,
          backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
          backgroundImage: user.profileImageUrl != null
              ? NetworkImage(user.profileImageUrl!)
              : null,
          child: user.profileImageUrl == null
              ? Icon(
                  Icons.person,
                  size: 50,
                  color: Theme.of(context).colorScheme.primary,
                )
              : null,
        ),
        
        const SizedBox(height: 16),
        
        // Name
        Text(
          user.fullName,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        
        const SizedBox(height: 4),
        
        // Role Badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: user.isStaff
                ? Colors.blue.withOpacity(0.1)
                : Colors.purple.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: user.isStaff
                  ? Colors.blue.withOpacity(0.3)
                  : Colors.purple.withOpacity(0.3),
            ),
          ),
          child: Text(
            user.role.name.toUpperCase(),
            style: TextStyle(
              color: user.isStaff ? Colors.blue.shade700 : Colors.purple.shade700,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        
        const SizedBox(height: 8),
        
        // Department (if available)
        if (user.department != null)
          Text(
            user.department!,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
      ],
    );
  }

  Widget _buildProfileForm(AuthProvider authProvider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Personal Information',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (_isEditing)
                    Row(
                      children: [
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _isEditing = false;
                              _loadUserData(); // Reset form
                            });
                          },
                          child: const Text('Cancel'),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () => _saveProfile(authProvider),
                          child: const Text('Save'),
                        ),
                      ],
                    ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // First Name
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      controller: _firstNameController,
                      labelText: 'First Name',
                      enabled: _isEditing,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Required';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: CustomTextField(
                      controller: _lastNameController,
                      labelText: 'Last Name',
                      enabled: _isEditing,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Required';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Email
              CustomTextField(
                controller: _emailController,
                labelText: 'Email',
                enabled: false, // Email cannot be changed
                prefixIcon: Icons.email,
              ),
              
              const SizedBox(height: 16),
              
              // Phone
              CustomTextField(
                controller: _phoneController,
                labelText: 'Phone Number',
                enabled: _isEditing,
                prefixIcon: Icons.phone,
                keyboardType: TextInputType.phone,
              ),
              
              const SizedBox(height: 16),
              
              // Department
              CustomTextField(
                controller: _departmentController,
                labelText: 'Department',
                enabled: _isEditing,
                prefixIcon: Icons.business,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsSection(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Settings',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Notifications
            ListTile(
              leading: const Icon(Icons.notifications),
              title: const Text('Notifications'),
              subtitle: const Text('Manage notification preferences'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                // Navigate to notification settings
              },
            ),
            
            const Divider(),
            
            // Privacy
            ListTile(
              leading: const Icon(Icons.privacy_tip),
              title: const Text('Privacy'),
              subtitle: const Text('Privacy and security settings'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                // Navigate to privacy settings
              },
            ),
            
            const Divider(),
            
            // About
            ListTile(
              leading: const Icon(Icons.info),
              title: const Text('About'),
              subtitle: const Text('App version and information'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                _showAboutDialog(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSignOutButton(AuthProvider authProvider) {
    return CustomButton(
      text: 'Sign Out',
      onPressed: () => _showSignOutDialog(authProvider),
      backgroundColor: Theme.of(context).colorScheme.error,
      icon: Icons.logout,
    );
  }

  Future<void> _saveProfile(AuthProvider authProvider) async {
    if (!_formKey.currentState!.validate()) return;

    final currentUser = authProvider.currentUser!;
    final updatedUser = currentUser.copyWith(
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      phoneNumber: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
      department: _departmentController.text.trim().isEmpty ? null : _departmentController.text.trim(),
    );

    final success = await authProvider.updateProfile(updatedUser);

    if (success && mounted) {
      setState(() {
        _isEditing = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated successfully'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _showSignOutDialog(AuthProvider authProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await authProvider.signOut();
              
              if (mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'Staff-Principal Appointments',
      applicationVersion: '1.0.0',
      applicationIcon: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(
          Icons.calendar_today,
          color: Colors.white,
          size: 30,
        ),
      ),
      children: [
        const Text('A secure, real-time appointment scheduling system connecting staff members with principals.'),
        const SizedBox(height: 16),
        const Text('Features:'),
        const Text('• Real-time appointment scheduling'),
        const Text('• Audio message support'),
        const Text('• Push notifications'),
        const Text('• Secure authentication'),
        const Text('• Cross-platform compatibility'),
      ],
    );
  }
}