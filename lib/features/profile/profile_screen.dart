import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:moneyvesto/core/global_components/global_button.dart';
import 'package:moneyvesto/core/global_components/global_text.dart';
import 'package:moneyvesto/core/global_components/global_text_fields.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final String userName = 'John Doe';
  final String avatarUrl = 'https://i.pravatar.cc/150?img=3';

  late TextEditingController emailController;
  late TextEditingController phoneController;

  bool isEditing = false; // state apakah sedang edit atau tidak

  @override
  void initState() {
    super.initState();
    emailController = TextEditingController(text: 'john.doe@example.com');
    phoneController = TextEditingController(text: '081234567890');
  }

  @override
  void dispose() {
    emailController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  void onEditPressed() {
    setState(() {
      isEditing = !isEditing;
    });
  }

  void onLogoutPressed() {
showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: const Color(0xFF002366), // background gelap
            title: const Text(
              'Logout',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: const Text(
              'Are you sure you want to logout?',
              style: TextStyle(color: Colors.white70),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Cancel',
                  style: TextStyle(color: Colors.white70),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  // Tambahkan aksi logout di sini
                },
                style: TextButton.styleFrom(
                  foregroundColor:
                      Colors.redAccent, // tombol logout warna merah
                ),
                child: const Text(
                  'Logout',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF002366),
      appBar: AppBar(
        backgroundColor: const Color(0xFF002366),
        elevation: 0,
        title: GlobalText.bold(
          'Profile',
          color: Colors.white,
          fontSize: 20.sp,
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.white,),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          TextButton(
            onPressed: onEditPressed,
            child: Text(
              isEditing ? 'Save' : 'Edit',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),

      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          children: [
            CircleAvatar(
              radius: 50.r,
              backgroundImage: NetworkImage(avatarUrl),
              backgroundColor: Colors.white.withOpacity(0.2),
            ),
            SizedBox(height: 16.h),
            GlobalText.semiBold(userName, color: Colors.white, fontSize: 24.sp),
            SizedBox(height: 24.h),
            GlobalTextField(
              controller: emailController,
              hintText: 'Email',
              keyboardType: TextInputType.emailAddress,
              isPassword: false,
              enabled: isEditing,
            ),
            SizedBox(height: 16.h),
            GlobalTextField(
              controller: phoneController,
              hintText: 'Phone Number',
              keyboardType: TextInputType.phone,
              isPassword: false,
              enabled: isEditing,
            ),
            const Spacer(),
            GlobalButton(
              backgroundColor: Colors.red,
              text: 'Logout',
            )
          ],
        ),
      ),
    );
  }
}
