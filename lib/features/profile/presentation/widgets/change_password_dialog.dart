import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/responsive_helper.dart';
import '../../domain/entities/user_profile.dart';
import '../bloc/profile_bloc.dart';

class ChangePasswordDialog extends StatefulWidget {
  final UserProfile profile;

  const ChangePasswordDialog({
    super.key,
    required this.profile,
  });

  @override
  State<ChangePasswordDialog> createState() => _ChangePasswordDialogState();
}

class _ChangePasswordDialogState extends State<ChangePasswordDialog> {
  final _formKey = GlobalKey<FormState>();
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  bool _obscureOldPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _changePassword() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<ProfileBloc>().add(
        ChangePasswordRequested(
          oldPassword: _oldPasswordController.text.trim(),
          newPassword: _newPasswordController.text.trim(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = ResponsiveHelper.isTablet(context);
    final screenWidth = MediaQuery.of(context).size.width;
    
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        width: isTablet ? screenWidth * 0.6 : screenWidth * 0.9,
        padding: EdgeInsets.all(isTablet ? 32 : 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              children: [
                Icon(
                  Icons.lock_outline,
                  size: isTablet ? 32 : 28,
                  color: const Color(0xFF1E3A8A),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Đổi mật khẩu',
                    style: TextStyle(
                      fontSize: isTablet ? 24 : 20,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1E3A8A),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Form
            Form(
              key: _formKey,
              child: Column(
                children: [
                  _buildPasswordField(
                    label: 'Mật khẩu hiện tại',
                    controller: _oldPasswordController,
                    obscureText: _obscureOldPassword,
                    onToggleObscure: () {
                      setState(() {
                        _obscureOldPassword = !_obscureOldPassword;
                      });
                    },
                  ),
                  
                  const SizedBox(height: 16),
                  
                  _buildPasswordField(
                    label: 'Mật khẩu mới',
                    controller: _newPasswordController,
                    obscureText: _obscureNewPassword,
                    onToggleObscure: () {
                      setState(() {
                        _obscureNewPassword = !_obscureNewPassword;
                      });
                    },
                  ),
                  
                  const SizedBox(height: 16),
                  
                  _buildPasswordField(
                    label: 'Xác nhận mật khẩu mới',
                    controller: _confirmPasswordController,
                    obscureText: _obscureConfirmPassword,
                    onToggleObscure: () {
                      setState(() {
                        _obscureConfirmPassword = !_obscureConfirmPassword;
                      });
                    },
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    'Hủy',
                    style: TextStyle(
                      fontSize: isTablet ? 16 : 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                
                BlocConsumer<ProfileBloc, ProfileState>(
                  listener: (context, state) {
                    if (state is PasswordChangeSuccess) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(state.message),
                          backgroundColor: Colors.green,
                        ),
                      );
                      Navigator.of(context).pop();
                    } else if (state is ProfileFailure) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(state.message),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  builder: (context, state) {
                    final isLoading = state is PasswordChangeLoading;
                    return ElevatedButton(
                      onPressed: isLoading ? null : _changePassword,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1E3A8A),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: isLoading
                          ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : Text(
                              'Đổi mật khẩu',
                              style: TextStyle(
                                fontSize: isTablet ? 16 : 14,
                                color: Colors.white,
                              ),
                            ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required String label,
    required TextEditingController controller,
    required bool obscureText,
    required VoidCallback onToggleObscure,
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
          obscureText: obscureText,
          decoration: InputDecoration(
            hintText: 'Nhập $label',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF1E3A8A)),
            ),
            suffixIcon: IconButton(
              onPressed: onToggleObscure,
              icon: Icon(
                obscureText ? Icons.visibility : Icons.visibility_off,
                color: Colors.grey.shade600,
              ),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: ResponsiveHelper.isTablet(context) ? 16 : 12,
              vertical: ResponsiveHelper.isTablet(context) ? 16 : 12,
            ),
          ),
          validator: (value) {
            if (value?.isEmpty ?? true) {
              return 'Vui lòng nhập $label';
            }
            
            if (label.contains('Mật khẩu mới') && (value?.length ?? 0) < 6) {
              return 'Mật khẩu phải có ít nhất 6 ký tự';
            }
            
            if (label == 'Xác nhận mật khẩu mới') {
              if (value != _newPasswordController.text) {
                return 'Mật khẩu xác nhận không khớp';
              }
            }
            
            return null;
          },
        ),
      ],
    );
  }
}
