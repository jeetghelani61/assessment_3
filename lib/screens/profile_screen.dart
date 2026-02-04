// screens/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'edit_profile_screen.dart';
import 'login_screen.dart';


class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String userName = 'Guest User';
  String userEmail = 'guest@example.com';
  bool _isDarkMode = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadTheme();
  }

  void _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final storedName = prefs.getString('userName');
    final storedEmail = prefs.getString('userEmail');

    setState(() {
      userName = storedName ?? 'Guest User';
      userEmail = storedEmail ?? 'guest@example.com';
    });
  }

  void _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkMode = prefs.getBool('isDarkMode') ?? false;
    });
  }

  void _toggleTheme(bool value) async {
    setState(() {
      _isDarkMode = value;
    });
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', value);
  }

  void _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: _isDarkMode ? Colors.black87 : Colors.white,
        foregroundColor: _isDarkMode ? Colors.white : Colors.black,
        elevation: 0,
      ),
      backgroundColor: _isDarkMode ? Colors.black87 : Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Profile Image Section
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 130,
                  height: 130,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.deepPurple,
                      width: 3,
                    ),
                  ),
                  child: ClipOval(
                    child: Image.network(
                      'https://cdn-icons-png.flaticon.com/512/3135/3135715.png',
                      width: 120,
                      height: 120,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                                : null,
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[200],
                          child: const Icon(
                            Icons.person,
                            size: 80,
                            color: Colors.grey,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // User Name
            Text(
              userName,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: _isDarkMode ? Colors.white : Colors.black,
              ),
            ),

            const SizedBox(height: 8),

            // User Email
            Text(
              userEmail,
              style: TextStyle(
                fontSize: 16,
                color: _isDarkMode ? Colors.grey[400] : Colors.grey[600],
              ),
            ),

            const SizedBox(height: 30),

            // Account Information Card
            Card(
              color: _isDarkMode ? Colors.grey[900] : Colors.white,
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Section Title
                    Text(
                      'ACCOUNT INFORMATION',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: _isDarkMode ? Colors.grey[400] : Colors.grey[600],
                        letterSpacing: 1,
                      ),
                    ),

                    const SizedBox(height: 16),

                    // User Info Items - માત્ર Name અને Email
                    _buildInfoItem(
                      icon: Icons.person_outline,
                      label: 'Full Name',
                      value: userName,
                    ),

                    const SizedBox(height: 12),

                    _buildInfoItem(
                      icon: Icons.email_outlined,
                      label: 'Email Address',
                      value: userEmail,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Settings Card
            Card(
              color: _isDarkMode ? Colors.grey[900] : Colors.white,
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Edit Profile Button
                    _buildSettingItem(
                      icon: Icons.edit,
                      title: 'Edit Profile',
                      onTap: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditProfileScreen(
                              initialName: userName,
                              initialEmail: userEmail,
                            ),
                          ),
                        );
                        if (result != null) {
                          setState(() {
                            userName = result['name'];
                            userEmail = result['email'];
                          });

                          // Update in SharedPreferences
                          final prefs = await SharedPreferences.getInstance();
                          await prefs.setString('userName', result['name']);
                          await prefs.setString('userEmail', result['email']);

                          // Show success message
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Profile updated successfully!'),
                              backgroundColor: Colors.green,
                              duration: Duration(seconds: 2),
                            ),
                          );
                        }
                      },
                      showDivider: true,
                    ),

                    // Theme Switcher
                    _buildSettingItem(
                      icon: Icons.dark_mode,
                      title: 'Dark Mode',
                      trailing: Switch(
                        value: _isDarkMode,
                        onChanged: _toggleTheme,
                        activeColor: Colors.deepPurple,
                        inactiveTrackColor: Colors.grey[300],
                      ),
                      showDivider: true,
                    ),

                    // Notifications
                    _buildSettingItem(
                      icon: Icons.notifications,
                      title: 'Notifications',
                      trailing: Switch(
                        value: true,
                        onChanged: (value) {},
                        activeColor: Colors.deepPurple,
                      ),
                      showDivider: false,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 30),

            // Logout Button Only
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _logout,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                icon: const Icon(
                  Icons.logout,
                  color: Colors.white,
                  size: 20,
                ),
                label: const Text(
                  'Logout',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.deepPurple.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: Colors.deepPurple,
            size: 20,
          ),
        ),

        const SizedBox(width: 12),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: _isDarkMode ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: _isDarkMode ? Colors.white : Colors.black,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),

        Icon(
          Icons.chevron_right,
          color: _isDarkMode ? Colors.grey[600] : Colors.grey[400],
          size: 20,
        ),
      ],
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    Widget? trailing,
    VoidCallback? onTap,
    bool showDivider = true,
  }) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.deepPurple.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: Colors.deepPurple,
                    size: 20,
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      color: _isDarkMode ? Colors.white : Colors.black,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),

                if (trailing != null)
                  trailing
                else
                  Icon(
                    Icons.chevron_right,
                    color: _isDarkMode ? Colors.grey[600] : Colors.grey[400],
                    size: 20,
                  ),
              ],
            ),
          ),
        ),

        if (showDivider)
          Divider(
            color: _isDarkMode ? Colors.grey[800] : Colors.grey[200],
            height: 1,
          ),
      ],
    );
  }
}