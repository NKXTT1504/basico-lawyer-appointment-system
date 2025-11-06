import '../models/appointment.dart' as admin_models;
import 'user_storage_service.dart';

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
          revenue += (a.fee).toDouble();
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
}

class _ReportData {
  final List<admin_models.Appointment> all;
  final List<admin_models.Appointment> filtered;
  _ReportData({required this.all, required this.filtered});
}

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
