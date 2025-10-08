import 'package:flutter/foundation.dart';
import '../../features/admin/data/models/appointment.dart' as admin_models;
import '../../features/admin/data/services/user_storage_service.dart';

class AdminReportService {
  static Future<_ReportData> _loadData({DateTime? from, DateTime? to}) async {
    final all = await UserStorageService.getAppointments();
    final f = from ?? DateTime.fromMillisecondsSinceEpoch(0);
    final t = to ?? DateTime.now().add(const Duration(days: 3650));
    final filtered = all
        .where((a) =>
            a.appointmentDate.isAfter(f) && a.appointmentDate.isBefore(t))
        .toList(growable: false);
    return _ReportData(all: all, filtered: filtered);
  }

  static Future<AdminKpi> getKpis({DateTime? from, DateTime? to}) async {
    final data = await _loadData(from: from, to: to);
    final list = data.filtered;
    final total = list.length;
    int pending = 0, confirmed = 0, completed = 0, cancelled = 0;
    double revenue = 0;
    for (final a in list) {
      switch (a.status) {
        case admin_models.AppointmentStatus.pending:
          pending++;
          break;
        case admin_models.AppointmentStatus.confirmed:
          confirmed++;
          break;
        case admin_models.AppointmentStatus.completed:
          completed++;
          revenue += a.fee;
          break;
        case admin_models.AppointmentStatus.cancelled:
          cancelled++;
          break;
      }
    }
    return AdminKpi(
      totalAppointments: total,
      pending: pending,
      confirmed: confirmed,
      completed: completed,
      cancelled: cancelled,
      revenue: revenue,
    );
  }

  /// Heatmap theo ngày trong tuần (0..6) × slot (timeSlot string)
  static Future<Map<int, Map<String, int>>> getHeatmap(
      {DateTime? from, DateTime? to}) async {
    final data = await _loadData(from: from, to: to);
    final result = <int, Map<String, int>>{};
    for (final a in data.filtered) {
      final dow = a.appointmentDate.weekday % 7; // 0..6 với CN=0
      final slotMap = result.putIfAbsent(dow, () => <String, int>{});
      slotMap[a.timeSlot] = (slotMap[a.timeSlot] ?? 0) + 1;
    }
    return result;
  }

  /// Phân rã theo luật sư: số lịch, doanh thu hoàn thành
  static Future<List<LawyerBreakdown>> getLawyerBreakdown(
      {DateTime? from, DateTime? to}) async {
    final data = await _loadData(from: from, to: to);
    final map = <String, LawyerBreakdown>{};
    for (final a in data.filtered) {
      final existing = map[a.lawyerId];
      if (existing == null) {
        map[a.lawyerId] = LawyerBreakdown(
          lawyerId: a.lawyerId,
          lawyerName: a.lawyerName,
          total: 1,
          completed:
              a.status == admin_models.AppointmentStatus.completed ? 1 : 0,
          revenue:
              a.status == admin_models.AppointmentStatus.completed ? a.fee : 0,
        );
      } else {
        map[a.lawyerId] = LawyerBreakdown(
          lawyerId: existing.lawyerId,
          lawyerName: existing.lawyerName,
          total: existing.total + 1,
          completed: existing.completed +
              (a.status == admin_models.AppointmentStatus.completed ? 1 : 0),
          revenue: existing.revenue +
              (a.status == admin_models.AppointmentStatus.completed
                  ? a.fee
                  : 0),
        );
      }
    }
    final list = map.values.toList()
      ..sort((a, b) => b.total.compareTo(a.total));
    return list;
  }
}

@immutable
class AdminKpi {
  final int totalAppointments;
  final int pending;
  final int confirmed;
  final int completed;
  final int cancelled;
  final double revenue;
  const AdminKpi({
    required this.totalAppointments,
    required this.pending,
    required this.confirmed,
    required this.completed,
    required this.cancelled,
    required this.revenue,
  });
}

@immutable
class LawyerBreakdown {
  final String lawyerId;
  final String lawyerName;
  final int total;
  final int completed;
  final double revenue;
  LawyerBreakdown({
    required this.lawyerId,
    required this.lawyerName,
    this.total = 0,
    this.completed = 0,
    this.revenue = 0,
  });
}

class _ReportData {
  final List<admin_models.Appointment> all;
  final List<admin_models.Appointment> filtered;
  const _ReportData({required this.all, required this.filtered});
}
