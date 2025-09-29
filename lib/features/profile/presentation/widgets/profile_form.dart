import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/responsive_helper.dart';

import '../../domain/entities/user_profile.dart';
import '../bloc/profile_bloc.dart';
import 'change_password_dialog.dart';

class ProfileForm extends StatefulWidget {
  final UserProfile profile;

  const ProfileForm({
    super.key,
    required this.profile,
  });

  @override
  State<ProfileForm> createState() => _ProfileFormState();
}

class _ProfileFormState extends State<ProfileForm> {
  late TextEditingController _fullNameController;
  late TextEditingController _phoneNumberController;
  late TextEditingController _emailController;
  
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _fullNameController = TextEditingController(text: widget.profile.fullName);
    _phoneNumberController = TextEditingController(text: widget.profile.phoneNumber);
    _emailController = TextEditingController(text: widget.profile.email);
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneNumberController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _saveChanges() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<ProfileBloc>().add(
        UpdateProfileRequested(
          fullName: _fullNameController.text.trim(),
          phoneNumber: _phoneNumberController.text.trim(),
        ),
      );
    }
  }

  void _showChangePasswordDialog() {
    showDialog(
      context: context,
      builder: (context) => ChangePasswordDialog(
        profile: widget.profile,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = ResponsiveHelper.isTablet(context);
    final screenWidth = MediaQuery.of(context).size.width;
    
    return Container(
      width: isTablet ? screenWidth * 0.8 : screenWidth * 0.95,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.all(Radius.circular(12)),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.1),
              spreadRadius: 2,
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
      ),
      child: Column(
        children: [
          // Header Banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Color(0xFF1E3A8A),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Text(
              'Thông tin cá nhân',
              style: TextStyle(
                color: Colors.white,
                fontSize: isTablet ? 24 : 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          
          // Form Content
          Padding(
            padding: EdgeInsets.all(isTablet ? 40 : 30),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTextField(
                    label: 'Họ và tên',
                    controller: _fullNameController,
                    icon: Icons.person,
                    enabled: true,
                  ),
                  
                  const SizedBox(height: 24),
                  
                  _buildTextField(
                    label: 'Email',
                    controller: _emailController,
                    icon: Icons.email,
                    enabled: false,
                    helperText: 'Email không thể thay đổi',
                  ),
                  
                  const SizedBox(height: 24),
                  
                  _buildTextField(
                    label: 'Số điện thoại',
                    controller: _phoneNumberController,
                    icon: Icons.phone,
                    enabled: true,
                    keyboardType: TextInputType.phone,
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // Action Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: _showChangePasswordDialog,
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                            horizontal: isTablet ? 24 : 20,
                            vertical: isTablet ? 12 : 10,
                          ),
                          side: BorderSide(color: Colors.grey.shade400),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          'Đổi mật khẩu',
                          style: TextStyle(
                            fontSize: isTablet ? 16 : 14,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ),
                      
                      const SizedBox(width: 16),
                      
                      ElevatedButton(
                        onPressed: _saveChanges,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1E3A8A),
                          padding: EdgeInsets.symmetric(
                            horizontal: isTablet ? 24 : 20,
                            vertical: isTablet ? 12 : 10,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          'Lưu thay đổi',
                          style: TextStyle(
                            fontSize: isTablet ? 16 : 14,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    required bool enabled,
    String? helperText,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: ResponsiveHelper.isTablet(context) ? 16 : 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          enabled: enabled,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: Colors.grey.shade600),
            hintText: 'Nhập $label',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF1E3A8A)),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            filled: !enabled,
            fillColor: enabled ? Colors.white : Colors.grey.shade50,
            contentPadding: EdgeInsets.symmetric(
              horizontal: ResponsiveHelper.isTablet(context) ? 16 : 12,
              vertical: ResponsiveHelper.isTablet(context) ? 16 : 12,
            ),
          ),
          validator: (value) {
            if (value?.isEmpty ?? true) {
              return 'Vui lòng nhập $label';
            }
            if (label == 'Họ và tên' && (value?.length ?? 0) < 2) {
              return 'Tên phải có ít nhất 2 ký tự';
            }
            if (label == 'Số điện thoại') {
              final phoneRegex = RegExp(r'^(\+84|0)[0-9]{9,10}$');
              if (!phoneRegex.hasMatch(value ?? '')) {
                return 'Số điện thoại không hợp lệ';
              }
            }
            return null;
          },
        ),
        if (helperText != null) ...[
          const SizedBox(height: 4),
          Text(
            helperText,
            style: TextStyle(
              fontSize: ResponsiveHelper.isTablet(context) ? 12 : 10,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ],
    );
  }
}
