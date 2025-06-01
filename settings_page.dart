import 'dart:io';

import 'package:flutter/material.dart';
import 'package:petroleum_management_system/login_screen.dart';
import 'help_center_page.dart';
import 'personal_information_page.dart';
import 'user_store.dart';
import 'notification_dialog.dart'; // import the dialog

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool notificationsEnabled = false;  // track notification status
  final UserStore _userStore = UserStore();

  @override
  Widget build(BuildContext context) {
    final String userName = _userStore.fullName ?? 'Your Name';
    final String userEmail = _userStore.email ?? 'email@example.com';

    // Colors for light mode only (no dark mode)
    final backgroundColor = Colors.white;
    final textColor = Colors.black;
    final dividerColor = Colors.grey.shade300;
    final tileColor = Colors.transparent;

    File? profileImageFile;
    if (_userStore.profileImagePath != null) {
      profileImageFile = File(_userStore.profileImagePath!);
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: backgroundColor,
        title: Text("Settings", style: TextStyle(color: textColor)),
        iconTheme: IconThemeData(color: textColor),
        elevation: 1,
      ),
      backgroundColor: backgroundColor,
      body: ListView(
        children: [
          const SizedBox(height: 20),
          ListTile(
            tileColor: tileColor,
            leading: CircleAvatar(
              radius: 25,
              backgroundColor: Colors.grey.shade400,
              backgroundImage: profileImageFile != null ? FileImage(profileImageFile) : null,
              child: profileImageFile == null
                  ? const Icon(Icons.person, color: Colors.white)
                  : null,
            ),
            title: Text(userName, style: TextStyle(color: textColor)),
            subtitle: Text(userEmail, style: TextStyle(color: textColor.withOpacity(0.7))),
            trailing: Icon(Icons.edit, color: textColor),
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const PersonalInformationPage()),
              );
              setState(() {}); // Refresh UI after returning from PersonalInformationPage
            },
          ),
          Divider(color: dividerColor),

          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text("Account Settings", style: TextStyle(fontWeight: FontWeight.bold, color: textColor)),
          ),
          ListTile(
            tileColor: tileColor,
            leading: Icon(Icons.person, color: textColor),
            title: Text('Personal Information', style: TextStyle(color: textColor)),
            trailing: Icon(Icons.arrow_forward_ios, size: 16, color: textColor),
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const PersonalInformationPage()),
              );
              setState(() {});
            },
          ),

          ListTile(
            tileColor: tileColor,
            leading: Icon(Icons.notifications_none, color: textColor),
            title: Text("Notifications", style: TextStyle(color: textColor)),
            trailing: Icon(
              notificationsEnabled ? Icons.notifications_active : Icons.notifications_off,
              color: notificationsEnabled ? Colors.green : Colors.grey,
            ),
            onTap: () async {
              final bool? result = await NotificationDialog.show(context, notificationsEnabled);
              if (result != null && result) {
                setState(() {
                  notificationsEnabled = !notificationsEnabled;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      notificationsEnabled
                          ? 'Notifications turned ON'
                          : 'Notifications turned OFF',
                    ),
                  ),
                );
              }
            },
          ),
          Divider(color: dividerColor),

          // Removed the "Preferences" section with Dark Mode toggle

          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text("Help & Support", style: TextStyle(fontWeight: FontWeight.bold, color: textColor)),
          ),
          ListTile(
            leading: Icon(Icons.help_outline, color: textColor),
            title: Text(
              "Help & Support",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: textColor,
                fontSize: 16,
              ),
            ),
            trailing: Icon(Icons.arrow_forward_ios, size: 16, color: textColor),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const HelpCenterPage()),
              );
            },
          ),

          const SizedBox(height: 30),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: OutlinedButton(
              onPressed: () {
                // Navigate back to SignUpScreen and clear the navigation stack
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                      (route) => false,
                );
              },
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
                side: BorderSide(color: textColor),
              ),
              child: Text("Log Out", style: TextStyle(color: textColor)),
            ),
          ),

          const SizedBox(height: 0),
        ],
      ),
    );
  }
}
