import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../data/services/appointment_api_service.dart';
import '../../../../core/services/appointment_sync_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PaymentReturnPage extends StatefulWidget {
  final Map<String, String>? queryParams;

  const PaymentReturnPage({super.key, this.queryParams});

  @override
  State<PaymentReturnPage> createState() => _PaymentReturnPageState();
}

class _PaymentReturnPageState extends State<PaymentReturnPage> {
  bool _processing = true;
  bool _success = false;
  String _message = 'Đang xử lý...';
  String? _orderId;

  @override
  void initState() {
    super.initState();
    _processPaymentResult();
  }

  Future<void> _processPaymentResult() async {
    try {
      // Get query params from URL
      final params = widget.queryParams ?? _extractParamsFromUrl();

      // Check response code: 00 = success
      final responseCode = params['vnp_ResponseCode'] ?? '';
      // Extract orderId from vnp_TxnRef or vnp_OrderInfo
      String? orderId = params['vnp_TxnRef'];
      if (orderId == null || orderId.isEmpty) {
        final orderInfo = params['vnp_OrderInfo'] ?? '';
        if (orderInfo.contains(':')) {
          orderId = orderInfo.split(':').last.trim();
        } else if (orderInfo.startsWith('APPT-')) {
          orderId = orderInfo;
        }
      }
      final finalOrderId = orderId ?? 'UNKNOWN';
      _orderId = finalOrderId;

      if (responseCode == '00') {
        // Payment successful
        await _createAppointmentFromOrder(finalOrderId);
      } else {
        // Payment failed
        setState(() {
          _processing = false;
          _success = false;
          _message = 'Thanh toán thất bại. Vui lòng thử lại.';
        });
      }
    } catch (e) {
      setState(() {
        _processing = false;
        _success = false;
        _message = 'Lỗi xử lý: $e';
      });
    }
  }

  Map<String, String> _extractParamsFromUrl() {
    final uri = Uri.base;
    final params = <String, String>{};
    uri.queryParameters.forEach((key, value) {
      params[key] = value;
    });
    return params;
  }

  Future<void> _createAppointmentFromOrder(String orderId) async {
    try {
      // Retrieve stored booking data
      final prefs = await SharedPreferences.getInstance();
      final bookingDataStr = prefs.getString('pending_booking_$orderId');

      if (bookingDataStr == null) {
        setState(() {
          _processing = false;
          _success = false;
          _message = 'Không tìm thấy thông tin đặt lịch. Vui lòng đặt lại.';
        });
        return;
      }

      final bookingData = bookingDataStr.split('|');
      if (bookingData.length < 5) {
        setState(() {
          _processing = false;
          _success = false;
          _message = 'Dữ liệu đặt lịch không hợp lệ.';
        });
        return;
      }

      final userId = bookingData[0];
      final lawyerId = bookingData[1];
      final lawyerName = bookingData[2];
      final selectedDate = DateTime.parse(bookingData[3]);
      final selectedSlot = bookingData[4];
      final services = bookingData.length > 5
          ? bookingData[5].split(',').where((s) => s.isNotEmpty).toList()
          : <String>[];
      final notes = bookingData.length > 6 ? bookingData[6] : '';

      // Create appointment via API
      try {
        final appointmentData = {
          'userId': userId,
          'lawyerId': lawyerId,
          'scheduledAt': selectedDate.toIso8601String(),
          'slot': selectedSlot,
          'spec': services.isEmpty ? '' : services.join(', '),
          'services': services,
          'note': notes.isEmpty
              ? 'Đặt lịch từ mobile app - Đã thanh toán cọc'
              : notes,
        };

        final response =
            await AppointmentApiService.createAppointment(appointmentData);

        if (response.statusCode == 200) {
          final responseData = response.data;
          bool isSuccess = false;

          if (responseData is Map<String, dynamic>) {
            isSuccess = responseData['success'] == true ||
                responseData['isSuccess'] == true ||
                responseData['Success'] == true;
          } else {
            isSuccess = true;
          }

          if (isSuccess) {
            // Clean up stored data
            await prefs.remove('pending_booking_$orderId');

            setState(() {
              _processing = false;
              _success = true;
              _message = 'Thanh toán thành công! Lịch hẹn đã được tạo.';
            });

            // Navigate to appointments page after delay
            Future.delayed(const Duration(seconds: 3), () {
              if (mounted) {
                context.go('/appointments');
              }
            });
            return;
          }
        }
      } catch (e) {
        print('API appointment creation failed: $e');
      }

      // Fallback to local storage
      final ok = await AppointmentSyncService.createBookingForLawyerMulti(
        lawyerId: lawyerId,
        lawyerName: lawyerName,
        services: services,
        date: selectedDate,
        timeSlot: selectedSlot,
      );

      await prefs.remove('pending_booking_$orderId');

      if (ok) {
        setState(() {
          _processing = false;
          _success = true;
          _message = 'Thanh toán thành công! Lịch hẹn đã được tạo.';
        });

        Future.delayed(const Duration(seconds: 3), () {
          if (mounted) {
            context.go('/appointments');
          }
        });
      } else {
        setState(() {
          _processing = false;
          _success = false;
          _message = 'Không thể tạo lịch hẹn. Vui lòng liên hệ hỗ trợ.';
        });
      }
    } catch (e) {
      setState(() {
        _processing = false;
        _success = false;
        _message = 'Lỗi tạo lịch hẹn: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kết quả thanh toán'),
        backgroundColor: const Color(0xFF1E3A8A),
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_processing)
                const CircularProgressIndicator()
              else if (_success)
                Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: 80,
                )
              else
                Icon(
                  Icons.error_outline,
                  color: Colors.red,
                  size: 80,
                ),
              const SizedBox(height: 24),
              Text(
                _message,
                style: const TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ),
              if (_orderId != null) ...[
                const SizedBox(height: 12),
                Text(
                  'Mã đơn: $_orderId',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
              if (!_processing) ...[
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () => context.go('/appointments'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E3A8A),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                  ),
                  child: const Text('Xem lịch hẹn'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
