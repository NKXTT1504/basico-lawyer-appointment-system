import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/utils/responsive_helper.dart';
import '../../../../core/utils/slot_mapper.dart';
import '../../data/services/appointment_api_service.dart';
import '../../../admin/data/services/user_storage_service.dart';
import 'package:url_launcher/url_launcher.dart';

class AppointmentConfirmationPage extends StatefulWidget {
  final String lawyerId;
  final String lawyerName;
  final List<String> services;
  final DateTime selectedDate;
  final String selectedSlot;
  final double depositAmount;
  final double hourlyRate;
  final String? notes;

  const AppointmentConfirmationPage({
    super.key,
    required this.lawyerId,
    required this.lawyerName,
    required this.services,
    required this.selectedDate,
    required this.selectedSlot,
    required this.depositAmount,
    required this.hourlyRate,
    this.notes,
  });

  @override
  State<AppointmentConfirmationPage> createState() =>
      _AppointmentConfirmationPageState();
}

class _AppointmentConfirmationPageState
    extends State<AppointmentConfirmationPage> {
  final TextEditingController _notesController = TextEditingController();
  bool _loading = false;
  String _customerName = '';
  String _customerEmail = '';
  String _customerPhone = '';

  @override
  void initState() {
    super.initState();
    _loadCustomerInfo();
  }

  Future<void> _loadCustomerInfo() async {
    final user = await UserStorageService.getCurrentUser();
    final customer = await UserStorageService.getCurrentCustomerProfile();
    if (mounted) {
      setState(() {
        _customerName = user?.name ?? 'Chưa cập nhật';
        _customerEmail = user?.email ?? 'Chưa cập nhật';
        _customerPhone = customer?.phone ?? 'Chưa cập nhật';
      });
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _processPayment() async {
    setState(() => _loading = true);

    try {
      final currentUser = await UserStorageService.getCurrentUser();
      if (currentUser == null) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vui lòng đăng nhập')),
        );
        return;
      }

      // BƯỚC 1: Tạo appointment TRƯỚC (giống React web app)
      // Convert time range to slot number for backend API
      final slotNumber = SlotMapper.timeToSlot(widget.selectedSlot);
      final appointmentData = {
        'userId': currentUser.id,
        'lawyerId': widget.lawyerId,
        'scheduledAt': widget.selectedDate.toIso8601String(),
        'slot': slotNumber.toString(),
        'spec': widget.services.isEmpty ? '' : widget.services.join(', '),
        'services': widget.services,
        'note': _notesController.text.trim().isEmpty
            ? 'Đặt lịch từ mobile app - Chờ thanh toán cọc'
            : _notesController.text.trim(),
      };

      print('Creating appointment before payment...');
      final appointmentResponse =
          await AppointmentApiService.createAppointment(appointmentData);

      // Extract appointmentId from response
      dynamic appointmentId;
      if (appointmentResponse.statusCode == 200 ||
          appointmentResponse.statusCode == 201) {
        final responseData = appointmentResponse.data;
        if (responseData is Map<String, dynamic>) {
          appointmentId = responseData['appointmentId'] ??
              responseData['AppointmentId'] ??
              responseData['id'] ??
              responseData['Id'];
        }
      }

      if (appointmentId == null) {
        throw Exception('Không nhận được appointment ID từ server');
      }

      print('Appointment created with ID: $appointmentId');

      // BƯỚC 2: Tạo payment URL với appointmentId
      final depositInVnd =
          (widget.depositAmount * 1000).toInt(); // Convert to VND
      final orderId =
          'APPT-$appointmentId-${DateTime.now().millisecondsSinceEpoch}';

      // Store appointmentId for payment return verification
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
          'payment_appointment_id_$orderId', appointmentId.toString());

      // Use web-compatible return URL
      final returnUrl = Uri.base.origin + '/payment-return';

      final paymentData = {
        'vendor': 'vnpay', // Lowercase như React app
        'orderId': orderId,
        'lawyerId': int.tryParse(widget.lawyerId) ?? 0,
        'appointmentId': appointmentId, // Gửi appointmentId
        'durationHours': 1, // Mặc định 1 giờ (hoặc tính từ slot)
        'orderInfo':
            'Dat lich ${widget.services.join(", ")} - ${widget.lawyerName} - ${widget.selectedDate.day}/${widget.selectedDate.month}/${widget.selectedDate.year}',
        'returnUrl': returnUrl,
        'amount': depositInVnd, // Send amount in VND
      };

      print('Creating payment URL with data: $paymentData');
      final paymentResp =
          await PaymentApiService.createVnpayPaymentUrl(paymentData);

      if (paymentResp.statusCode == 200 || paymentResp.statusCode == 201) {
        // Response có thể là String (URL) hoặc Map với paymentUrl
        String? paymentUrl;
        if (paymentResp.data is String) {
          paymentUrl = paymentResp.data as String;
        } else if (paymentResp.data is Map) {
          paymentUrl = paymentResp.data['paymentUrl'] ??
              paymentResp.data['PaymentUrl'] ??
              paymentResp.data['payment_url'];
        }

        if (paymentUrl != null && paymentUrl.isNotEmpty) {
          print('Redirecting to payment URL: $paymentUrl');
          if (await canLaunchUrl(Uri.parse(paymentUrl))) {
            await launchUrl(Uri.parse(paymentUrl),
                mode: LaunchMode.externalApplication);
          } else {
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Không mở được trang thanh toán')),
            );
          }
        } else {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Không nhận được link thanh toán')),
          );
        }
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Lỗi tạo thanh toán: ${paymentResp.statusCode}')),
        );
      }
    } catch (e) {
      print('Error in payment process: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = ResponsiveHelper.isTablet(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Xác nhận & Thanh toán'),
        backgroundColor: const Color(0xFF1E3A8A),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(isTablet ? 24 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Progress indicator
            _buildProgressIndicator(),
            const SizedBox(height: 24),

            // Notes field
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Ghi chú (không bắt buộc)',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _notesController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText:
                            'Bạn có thể ghi chú thêm về vấn đề pháp lý hoặc yêu cầu đặc biệt...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Payment info box
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.amber.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Thông tin thanh toán',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  RichText(
                    text: TextSpan(
                      style:
                          const TextStyle(color: Colors.black87, fontSize: 14),
                      children: [
                        const TextSpan(
                            text: 'Phí đặt cọc (30% giá theo giờ): '),
                        TextSpan(
                          text:
                              '${widget.depositAmount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')} ₫',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Color(0xFF1E3A8A),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Vì bạn đã chọn ${widget.services.length} dịch vụ, vui lòng thanh toán trước 30% phí đặt cọc. Lịch hẹn sẽ chỉ được xác nhận sau khi thanh toán thành công.',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Appointment info box
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Thông tin lịch hẹn',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildInfoRow('Khách hàng:', _customerName),
                    _buildInfoRow('Email:', _customerEmail),
                    _buildInfoRow('Số điện thoại:', _customerPhone),
                    _buildInfoRow('Dịch vụ:',
                        '${widget.services.join(", ")} (${widget.services.length} dịch vụ)'),
                    _buildInfoRow('Luật sư:', widget.lawyerName),
                    _buildInfoRow('Ngày:',
                        '${widget.selectedDate.day}/${widget.selectedDate.month}/${widget.selectedDate.year}'),
                    _buildInfoRow('Giờ:', widget.selectedSlot),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed:
                        _loading ? null : () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                        vertical: isTablet ? 16 : 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Quay lại'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _processPayment,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E3A8A),
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                        vertical: isTablet ? 16 : 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: _loading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('Thanh toán & Xác nhận'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Row(
      children: [
        _buildProgressStep(
          number: 1,
          title: 'Dịch vụ & Luật sư',
          isCompleted: true,
        ),
        Expanded(
          child: Container(
            height: 2,
            color: Colors.grey[300],
            margin: const EdgeInsets.symmetric(horizontal: 8),
          ),
        ),
        _buildProgressStep(
          number: 2,
          title: 'Ngày & Giờ',
          isCompleted: true,
        ),
        Expanded(
          child: Container(
            height: 2,
            color: Colors.grey[300],
            margin: const EdgeInsets.symmetric(horizontal: 8),
          ),
        ),
        _buildProgressStep(
          number: 3,
          title: 'Ghi chú',
          isCompleted: true,
        ),
      ],
    );
  }

  Widget _buildProgressStep({
    required int number,
    required String title,
    required bool isCompleted,
  }) {
    return Column(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: isCompleted ? const Color(0xFF1E3A8A) : Colors.grey[300],
            borderRadius: BorderRadius.circular(16),
          ),
          child: Center(
            child: isCompleted
                ? const Icon(Icons.check, color: Colors.white, size: 20)
                : Text(
                    '$number',
                    style: TextStyle(
                      color: isCompleted ? Colors.white : Colors.grey[600],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 12,
            color: isCompleted ? const Color(0xFF1E3A8A) : Colors.grey[600],
            fontWeight: isCompleted ? FontWeight.w600 : FontWeight.normal,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
