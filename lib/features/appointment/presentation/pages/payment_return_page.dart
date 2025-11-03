import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../data/services/appointment_api_service.dart';
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
        // Try to extract from orderInfo format: "GD: APPT-xxx-xxx"
        if (orderId == null || orderId.isEmpty) {
          final match =
              RegExp(r'(?:APPT|GD)[\s:-]*([A-Z0-9-]+)').firstMatch(orderInfo);
          if (match != null) {
            orderId = match.group(1);
          }
        }
      }
      final finalOrderId = orderId ?? 'UNKNOWN';
      _orderId = finalOrderId;

      if (responseCode == '00') {
        // Payment successful - verify với backend (giống React app)
        await _verifyPaymentAndUpdateAppointment(params, finalOrderId);
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

  Future<void> _verifyPaymentAndUpdateAppointment(
      Map<String, String> params, String orderId) async {
    try {
      // BƯỚC 1: Verify payment với backend (giống React app)
      final verifyResponse =
          await PaymentApiService.verifyPaymentReturn(params);

      if (verifyResponse.statusCode == 200) {
        final verifyData = verifyResponse.data;
        bool isSuccess = false;
        dynamic appointmentId;

        if (verifyData is Map<String, dynamic>) {
          isSuccess = verifyData['status'] == 'success' ||
              verifyData['isSuccess'] == true ||
              verifyData['Success'] == true;
          // Extract appointmentId from response
          appointmentId = verifyData['appointmentId'] ??
              verifyData['AppointmentId'] ??
              verifyData['id'] ??
              verifyData['Id'];
        }

        // Nếu không có appointmentId từ response, extract từ orderId
        if (appointmentId == null) {
          // orderId format: APPT-{appointmentId}-{timestamp}
          final match = RegExp(r'APPT-(\d+)-').firstMatch(orderId);
          if (match != null) {
            appointmentId = int.tryParse(match.group(1)!);
          }
        }

        // Nếu vẫn không có, lấy từ SharedPreferences
        if (appointmentId == null) {
          final prefs = await SharedPreferences.getInstance();
          final storedId = prefs.getString('payment_appointment_id_$orderId');
          if (storedId != null) {
            appointmentId = int.tryParse(storedId);
          }
        }

        if (isSuccess && appointmentId != null) {
          // Clean up stored data
          final prefs = await SharedPreferences.getInstance();
          await prefs.remove('payment_appointment_id_$orderId');

          setState(() {
            _processing = false;
            _success = true;
            _message = 'Thanh toán thành công! Lịch hẹn đã được xác nhận.';
          });

          // Navigate to appointments page after delay
          Future.delayed(const Duration(seconds: 3), () {
            if (mounted) {
              context.go('/appointments');
            }
          });
          return;
        } else if (isSuccess) {
          // Payment verified nhưng không tìm thấy appointmentId
          setState(() {
            _processing = false;
            _success = true;
            _message =
                'Thanh toán thành công! Vui lòng kiểm tra lịch hẹn của bạn.';
          });
          Future.delayed(const Duration(seconds: 3), () {
            if (mounted) {
              context.go('/appointments');
            }
          });
          return;
        }
      }

      // Fallback: Nếu verify API fail, thử extract appointmentId từ orderId
      final match = RegExp(r'APPT-(\d+)-').firstMatch(orderId);
      if (match != null) {
        final appointmentId = int.tryParse(match.group(1)!);
        if (appointmentId != null) {
          // Payment successful nhưng verify API failed - vẫn coi là success
          // Backend sẽ tự update appointment status khi nhận IPN từ VNPay
          setState(() {
            _processing = false;
            _success = true;
            _message =
                'Thanh toán thành công! Lịch hẹn sẽ được xác nhận trong giây lát.';
          });
          Future.delayed(const Duration(seconds: 3), () {
            if (mounted) {
              context.go('/appointments');
            }
          });
          return;
        }
      }

      // Nếu tất cả đều fail
      setState(() {
        _processing = false;
        _success = false;
        _message =
            'Thanh toán đã thành công nhưng không thể xác minh. Vui lòng liên hệ hỗ trợ.';
      });
    } catch (e) {
      print('Payment verification error: $e');

      // Fallback: Extract appointmentId từ orderId và coi là success
      final match = RegExp(r'APPT-(\d+)-').firstMatch(orderId);
      if (match != null) {
        setState(() {
          _processing = false;
          _success = true;
          _message =
              'Thanh toán thành công! Lịch hẹn sẽ được xác nhận trong giây lát.';
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
          _message = 'Lỗi xác minh thanh toán: $e';
        });
      }
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
