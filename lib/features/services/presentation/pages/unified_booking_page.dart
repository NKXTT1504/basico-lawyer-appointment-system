import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/slot_mapper.dart';
import '../../../../core/services/appointment_sync_service.dart';
import '../../../../core/network/api_services.dart';
import '../../../lawyer/data/services/lawyer_api_service.dart';
import '../../data/models/service.dart';
import '../../../appointment/data/services/appointment_api_service.dart';
import '../../../admin/data/services/user_storage_service.dart';

class UnifiedBookingPage extends StatefulWidget {
  final List<String> services;
  final String? field;
  final ServiceModel? preselectedService;

  const UnifiedBookingPage({
    super.key,
    required this.services,
    this.field,
    this.preselectedService,
  });

  @override
  State<UnifiedBookingPage> createState() => _UnifiedBookingPageState();
}

class _UnifiedBookingPageState extends State<UnifiedBookingPage> {
  // Step 1: Service & Lawyer Selection
  List<Lawyer> _lawyers = [];
  String? _selectedLawyerId;
  Lawyer? _selectedLawyer;
  bool _isLoadingLawyers = true;
  String? _error;

  // Step 2: Date & Time Selection (shown when lawyer is selected)
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  String? _selectedSlot;
  Set<String> _occupied = <String>{};
  Set<int> _workSlots = <int>{}; // Work slots của luật sư (slot numbers)
  bool _isLoadingSlots = false;
  double? _hourlyRate;

  static List<String> get _slots => SlotMapper.allTimeRanges;

  @override
  void initState() {
    super.initState();
    _loadLawyers();
  }

  Future<void> _loadLawyers() async {
    try {
      setState(() {
        _isLoadingLawyers = true;
        _error = null;
      });

      final response = await LawyerApiService.getLawyers();
      if (response.statusCode == 200) {
        final List<dynamic> data = _extractList(response.data);
        final allLawyers =
            data.map((json) => Lawyer.fromJson(_asMap(json))).toList();

        // Filter lawyers by field or services
        final selectedServiceNames =
            widget.services.map((e) => e.toLowerCase()).toList();
        final selectedField = widget.field?.toLowerCase();
        final filteredLawyers = allLawyers.where((lawyer) {
          final spec = (lawyer.specialization ?? '').toLowerCase();
          final matchField = selectedField == null || selectedField.isEmpty
              ? false
              : spec.contains(selectedField) || selectedField.contains(spec);
          final matchAnyService = selectedServiceNames.any(
              (s) => s.isNotEmpty && (spec.contains(s) || s.contains(spec)));
          return matchField || matchAnyService;
        }).toList();

        // Sort by match score
        filteredLawyers.sort((a, b) {
          int aScore = 0;
          int bScore = 0;
          final aSpec = (a.specialization ?? '').toLowerCase();
          final bSpec = (b.specialization ?? '').toLowerCase();
          for (final s in selectedServiceNames) {
            if (s.isNotEmpty && aSpec.contains(s)) aScore++;
            if (s.isNotEmpty && bSpec.contains(s)) bScore++;
          }
          if (selectedField != null && selectedField.isNotEmpty) {
            if (aSpec.contains(selectedField)) aScore++;
            if (bSpec.contains(selectedField)) bScore++;
          }
          return bScore.compareTo(aScore);
        });

        // Show all filtered lawyers (không filter theo work slots ở đây)
        // Chỉ check work slots khi user chọn luật sư
        setState(() {
          _lawyers = filteredLawyers.take(20).toList();
          _isLoadingLawyers = false;
        });
      } else {
        setState(() {
          _error = 'Lỗi tải danh sách luật sư: ${response.statusCode}';
          _isLoadingLawyers = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Lỗi tải danh sách luật sư: $e';
        _isLoadingLawyers = false;
      });
    }
  }

  Future<void> _selectLawyer(Lawyer lawyer) async {
    setState(() {
      _selectedLawyerId = lawyer.id;
      _selectedLawyer = lawyer;
      _selectedSlot = null;
      _isLoadingSlots = true;
    });

    // Load lawyer profile, work slots, and occupied slots
    await Future.wait([
      _loadLawyerProfile(lawyer.id!),
      _loadWorkSlots(lawyer.id!),
      _loadOccupiedSlots(lawyer.id!),
    ]);

    setState(() {
      _isLoadingSlots = false;
    });
  }

  Future<void> _loadLawyerProfile(String lawyerId) async {
    try {
      final response = await LawyerApiService.getLawyerById(lawyerId);
      if (response.statusCode == 200) {
        final data = response.data;
        final profile =
            data is Map<String, dynamic> ? (data['result'] ?? data) : data;
        if (profile is Map<String, dynamic>) {
          setState(() {
            _hourlyRate = (profile['pricePerHour'] ??
                profile['hourlyRate'] ??
                profile['price'] ??
                0) as double?;
          });
        }
      }
    } catch (e) {
      print('Failed to load lawyer profile: $e');
    }
  }

  Future<void> _loadWorkSlots(String lawyerId) async {
    try {
      final lawyerIdInt = int.tryParse(lawyerId);
      if (lawyerIdInt == null) {
        setState(() => _workSlots = {});
        return;
      }

      // Endpoint đúng: /api/lawyers/api/lawyers/{lawyerId}/workslots
      // lawyersGet sẽ thêm /api/lawyers vào path, nên path cần là: /api/lawyers/{lawyerId}/workslots
      final response =
          await ApiServices.lawyersGet('/api/lawyers/$lawyerIdInt/workslots');

      if (response.statusCode == 200) {
        final data = response.data;
        List<dynamic> workSlotsList = [];

        if (data is List) {
          workSlotsList = data;
        } else if (data is Map<String, dynamic>) {
          final result = data['result'] ?? data['data'] ?? [];
          if (result is List) {
            workSlotsList = result;
          } else {
            workSlotsList = [];
          }
        }

        // Extract slot numbers from work slots (giữ tất cả slot được định nghĩa)
        final allSlotNumbers = <int>{};
        for (final slot in workSlotsList) {
          if (slot is Map<String, dynamic>) {
            final slotNum = slot['slot'] ?? slot['slotNumber'] ?? slot['Slot'];
            if (slotNum != null) {
              final num =
                  slotNum is int ? slotNum : int.tryParse(slotNum.toString());
              if (num != null) {
                allSlotNumbers.add(num);
              }
            }
          }
        }

        // Nếu không có work slots từ API
        if (allSlotNumbers.isEmpty) {
          setState(() => _workSlots = {});
          return;
        }

        // Lưu toàn bộ work slots; việc lọc theo ngày sẽ dựa trên _occupied và _availableTimeSlots
        setState(() => _workSlots = allSlotNumbers);
      } else {
        setState(() => _workSlots = {});
      }
    } catch (e) {
      print('Failed to load work slots: $e');
      // On error, không hiển thị slots
      setState(() => _workSlots = {});
    }
  }

  Future<void> _loadOccupiedSlots(String lawyerId) async {
    try {
      final set = await AppointmentSyncService.getOccupiedTimeSlots(
        lawyerId: lawyerId,
        date: _selectedDate,
      );
      setState(() => _occupied = set);
    } catch (e) {
      print('Failed to load occupied slots: $e');
    }
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 60)),
    );
    if (date != null) {
      setState(() {
        _selectedDate = date;
        _selectedSlot = null;
      });
      if (_selectedLawyerId != null) {
        // Reload work slots và occupied slots khi đổi ngày
        await Future.wait([
          _loadWorkSlots(_selectedLawyerId!),
          _loadOccupiedSlots(_selectedLawyerId!),
        ]);
      }
    }
  }

  List<String> get _availableTimeSlots {
    // Filter slots dựa trên work slots của luật sư
    if (_workSlots.isEmpty) {
      // Nếu không có work slots, trả về tất cả (fail-safe)
      return _slots;
    }
    return _slots.where((s) {
      final slotNumberStr = SlotMapper.timeToSlot(s);
      final slotNumber = int.tryParse(slotNumberStr);
      return slotNumber != null && _workSlots.contains(slotNumber);
    }).toList();
  }

  double _calculateDeposit() {
    // Chỉ tính deposit nếu có từ 2 dịch vụ trở lên
    if (widget.services.length < 2) return 0;

    if (_hourlyRate == null || _selectedSlot == null) return 0;
    // Extract hours from slot: "08:00 - 10:00" -> 2 hours
    final parts = _selectedSlot!.split(' - ');
    if (parts.length != 2) return 0;
    try {
      final start = parts[0].split(':');
      final end = parts[1].split(':');
      final startHour = int.parse(start[0]);
      final startMin = int.parse(start[1]);
      final endHour = int.parse(end[0]);
      final endMin = int.parse(end[1]);
      final startTime = startHour + startMin / 60.0;
      final endTime = endHour + endMin / 60.0;
      final hours = endTime - startTime;
      // Deposit = (hourlyRate × hours) × 30%
      return (_hourlyRate! * hours) * 0.3;
    } catch (_) {
      return 0;
    }
  }

  Future<void> _proceedToConfirmation() async {
    if (_selectedLawyerId == null || _selectedSlot == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn luật sư và khung giờ')),
      );
      return;
    }

    // Nếu chỉ 1 dịch vụ: tạo lịch trực tiếp và quay về cuộc hẹn sắp tới
    if (widget.services.length < 2) {
      try {
        final currentUser = await UserStorageService.getCurrentUser();
        if (currentUser == null) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Vui lòng đăng nhập')),
          );
          return;
        }

        final slotNumber = SlotMapper.timeToSlot(_selectedSlot!);
        final appointmentData = {
          'userId': currentUser.id,
          'lawyerId': _selectedLawyerId,
          'scheduledAt': _selectedDate.toIso8601String(),
          'slot': slotNumber,
          'spec': widget.services.isEmpty ? '' : widget.services.join(', '),
          'services': widget.services,
          'note': 'Đặt lịch từ mobile app',
        };

        final response =
            await AppointmentApiService.createAppointment(appointmentData);
        if (!mounted) return;

        if (response.statusCode == 200 || response.statusCode == 201) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Đặt lịch thành công')),
          );
          context.go('/appointments');
          return;
        }
      } catch (e) {
        print('Create appointment failed: $e');
      }
    }

    // 2+ dịch vụ: sang trang xác nhận & thanh toán (cọc)
    final depositAmount = _calculateDeposit();
    final hourlyRate = _hourlyRate ?? 0.0;

    if (!mounted) return;
    context.push('/appointment-confirmation', extra: {
      'lawyerId': _selectedLawyerId,
      'lawyerName': _selectedLawyer?.name ?? 'Luật sư',
      'services': widget.services,
      'selectedDate': _selectedDate,
      'selectedSlot': _selectedSlot,
      'depositAmount': depositAmount,
      'hourlyRate': hourlyRate,
    });
  }

  List<dynamic> _extractList(dynamic body) {
    if (body == null) return const [];
    if (body is List) return body;
    if (body is Map<String, dynamic>) {
      for (final k in [
        'result',
        'data',
        'items',
        'results',
        'value',
        r'$values',
        'lawyers'
      ]) {
        final v = body[k];
        if (v is List) return v;
      }
      for (final v in body.values) {
        if (v is List) return v;
      }
    }
    return const [];
  }

  Map<String, dynamic> _asMap(dynamic e) {
    if (e is Map<String, dynamic>) return e;
    if (e is Map) return e.map((k, v) => MapEntry(k.toString(), v));
    return <String, dynamic>{};
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isTablet = screenWidth > 600;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: screenWidth * (isTablet ? 0.08 : 0.04),
            vertical: screenHeight * 0.02,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Page Title
              _buildPageTitle(),
              SizedBox(height: screenHeight * 0.03),

              // Progress Indicator
              _buildProgressIndicator(),
              SizedBox(height: screenHeight * 0.03),

              // Content
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Step 1: Lawyer Selection
                      _buildLawyerSelection(),

                      // Step 2: Date & Time Selection (shown when lawyer is selected)
                      if (_selectedLawyerId != null && !_isLoadingSlots) ...[
                        SizedBox(height: screenHeight * 0.03),
                        _buildDateTimeSelection(),
                      ],
                    ],
                  ),
                ),
              ),

              // Continue Button (Step 3)
              if (_selectedLawyerId != null && _selectedSlot != null)
                Padding(
                  padding: EdgeInsets.only(
                      top: screenHeight * 0.02, bottom: screenHeight * 0.01),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _proceedToConfirmation,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.onPrimary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Tiếp tục đến xác nhận',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPageTitle() {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    return Text(
      'ĐẶT LỊCH HẸN',
      style: TextStyle(
        fontSize: screenWidth * (isTablet ? 0.07 : 0.06),
        fontWeight: FontWeight.bold,
        color: AppColors.onBackground,
      ),
    );
  }

  Widget _buildProgressIndicator() {
    final step1Complete = _selectedLawyerId != null;
    final step2Complete = _selectedSlot != null;

    return Row(
      children: [
        _buildProgressStep(
          number: 1,
          title: 'Chọn dịch vụ & luật sư',
          isActive: true,
          isComplete: step1Complete,
        ),
        Expanded(
          child: Container(
            height: 2,
            color: step1Complete ? AppColors.primary : AppColors.outline,
            margin: const EdgeInsets.symmetric(horizontal: 8),
          ),
        ),
        _buildProgressStep(
          number: 2,
          title: 'Ngày & Giờ',
          isActive: step1Complete,
          isComplete: step2Complete,
        ),
        Expanded(
          child: Container(
            height: 2,
            color: step2Complete ? AppColors.primary : AppColors.outline,
            margin: const EdgeInsets.symmetric(horizontal: 8),
          ),
        ),
        _buildProgressStep(
          number: 3,
          title: 'Xác nhận',
          isActive: step2Complete,
          isComplete: false,
        ),
      ],
    );
  }

  Widget _buildProgressStep({
    required int number,
    required String title,
    required bool isActive,
    required bool isComplete,
  }) {
    return Column(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: isComplete
                ? AppColors.primary
                : (isActive ? AppColors.primary : AppColors.outline),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Center(
            child: Text(
              '$number',
              style: TextStyle(
                color: isActive || isComplete
                    ? AppColors.onPrimary
                    : AppColors.onSurfaceVariant,
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
            color: isActive || isComplete
                ? AppColors.primary
                : AppColors.onSurfaceVariant,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildLawyerSelection() {
    if (_isLoadingLawyers) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          children: [
            Icon(Icons.error_outline, size: 64, color: AppColors.error),
            const SizedBox(height: 16),
            Text(_error!, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadLawyers,
              child: const Text('Thử lại'),
            ),
          ],
        ),
      );
    }

    if (_lawyers.isEmpty) {
      return Center(
        child: Column(
          children: [
            Icon(Icons.person_off, size: 64, color: AppColors.onSurfaceVariant),
            const SizedBox(height: 16),
            const Text(
              'Không tìm thấy luật sư phù hợp',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Chọn luật sư',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        ..._lawyers.map((lawyer) => _buildLawyerCard(lawyer)),
      ],
    );
  }

  Widget _buildLawyerCard(Lawyer lawyer) {
    final isSelected = _selectedLawyerId == lawyer.id;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected ? AppColors.primary : Colors.transparent,
          width: 2,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (lawyer.avatarUrl != null &&
                    lawyer.avatarUrl!.startsWith('http'))
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: AppColors.primaryContainer,
                    backgroundImage: NetworkImage(lawyer.avatarUrl!),
                  )
                else
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: AppColors.primaryContainer,
                    child: Icon(
                      Icons.person,
                      size: 30,
                      color: AppColors.primary,
                    ),
                  ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        lawyer.name ?? 'Luật sư',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (lawyer.specialization != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          lawyer.specialization!,
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                      if (lawyer.experience != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          '${lawyer.experience} năm kinh nghiệm',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (lawyer.rating != null)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.warningContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.star, size: 16, color: AppColors.warning),
                        const SizedBox(width: 4),
                        Text(
                          lawyer.rating!.toStringAsFixed(1),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.warning,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            if (lawyer.description != null) ...[
              const SizedBox(height: 12),
              Text(
                lawyer.description!,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      // View profile action
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Xem hồ sơ ${lawyer.name}'),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                    icon: const Icon(Icons.info_outline),
                    label: const Text('Xem hồ sơ'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _selectLawyer(lawyer),
                    icon: const Icon(Icons.schedule),
                    label: Text(isSelected ? 'Đã chọn' : 'Chọn luật sư'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          isSelected ? AppColors.success : AppColors.primary,
                      foregroundColor: AppColors.onPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateTimeSelection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Chọn ngày & giờ',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: _pickDate,
              icon: const Icon(Icons.calendar_today),
              label: Text(
                '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
              ),
              style: OutlinedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              ),
            ),
            const SizedBox(height: 24),
            if (_isLoadingSlots)
              const Center(child: CircularProgressIndicator())
            else if (_workSlots.isEmpty)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.event_busy,
                          size: 48, color: AppColors.onSurfaceVariant),
                      const SizedBox(height: 8),
                      Text(
                        'Luật sư này không có khung giờ trống trong 7 ngày tới',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Vui lòng chọn luật sư khác',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              )
            else ...[
              const Text(
                'Chọn khung giờ',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              _availableTimeSlots.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.all(16),
                      child: Center(
                        child: Column(
                          children: [
                            Icon(Icons.schedule,
                                size: 48, color: AppColors.onSurfaceVariant),
                            const SizedBox(height: 8),
                            Text(
                              'Luật sư không có khung giờ làm việc trong ngày này',
                              style:
                                  TextStyle(color: AppColors.onSurfaceVariant),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    )
                  : Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _availableTimeSlots.map((s) {
                        final disabled = _occupied.contains(s);
                        final selected = _selectedSlot == s;
                        return ChoiceChip(
                          label: Text(s),
                          selected: selected,
                          onSelected: disabled
                              ? null
                              : (_) => setState(() => _selectedSlot = s),
                          selectedColor: AppColors.primary,
                          labelStyle: TextStyle(
                            color: selected
                                ? AppColors.onPrimary
                                : AppColors.onSurface,
                          ),
                          disabledColor: AppColors.outline,
                        );
                      }).toList(),
                    ),
            ],
          ],
        ),
      ),
    );
  }
}

class Lawyer {
  final String? id;
  final String? name;
  final String? specialization;
  final String? description;
  final String? avatarUrl;
  final int? experience;
  final double? rating;

  Lawyer({
    this.id,
    this.name,
    this.specialization,
    this.description,
    this.avatarUrl,
    this.experience,
    this.rating,
  });

  factory Lawyer.fromJson(Map<String, dynamic> json) {
    String? fullNameFromUser;
    if (json['user'] is Map) {
      fullNameFromUser = json['user']['fullName']?.toString() ??
          json['user']['name']?.toString();
    } else if (json['User'] is Map) {
      fullNameFromUser = json['User']['FullName']?.toString() ??
          json['User']['Name']?.toString() ??
          json['User']['fullName']?.toString() ??
          json['User']['name']?.toString();
    }

    return Lawyer(
      id: json['id']?.toString(),
      name: fullNameFromUser?.isNotEmpty == true
          ? fullNameFromUser
          : (json['name']?.toString() ??
              json['fullName']?.toString() ??
              'Luật sư'),
      specialization: json['specialization']?.toString(),
      description: json['description']?.toString(),
      avatarUrl: json['avatarUrl']?.toString() ?? json['img']?.toString(),
      experience: json['experience'] is int
          ? json['experience']
          : (json['expYears'] is int
              ? json['expYears']
              : int.tryParse(json['experience']?.toString() ??
                  json['expYears']?.toString() ??
                  '')),
      rating: json['rating'] is double
          ? json['rating']
          : double.tryParse(json['rating']?.toString() ?? ''),
    );
  }
}
