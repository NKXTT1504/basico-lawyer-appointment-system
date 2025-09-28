import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/appointment.dart';
import '../../data/datasources/appointment_local_data_source.dart';

part 'appointment_event.dart';
part 'appointment_state.dart';

class AppointmentBloc extends Bloc<AppointmentEvent, AppointmentState> {
  final AppointmentLocalDataSource _dataSource;

  AppointmentBloc({required AppointmentLocalDataSource dataSource})
      : _dataSource = dataSource,
        super(AppointmentInitial()) {
    on<GetAppointmentsRequested>(_onGetAppointmentsRequested);
    on<GetUpcomingAppointmentsRequested>(_onGetUpcomingAppointmentsRequested);
    on<GetAppointmentHistoryRequested>(_onGetAppointmentHistoryRequested);
  }

  Future<void> _onGetAppointmentsRequested(
    GetAppointmentsRequested event,
    Emitter<AppointmentState> emit,
  ) async {
    emit(AppointmentLoading());
    try {
      final appointments = await _dataSource.getAppointments();
      emit(AppointmentSuccess(appointments));
    } catch (e) {
      emit(AppointmentFailure(e.toString()));
    }
  }

  Future<void> _onGetUpcomingAppointmentsRequested(
    GetUpcomingAppointmentsRequested event,
    Emitter<AppointmentState> emit,
  ) async {
    emit(AppointmentLoading());
    try {
      final appointments = await _dataSource.getUpcomingAppointments();
      emit(AppointmentSuccess(appointments));
    } catch (e) {
      emit(AppointmentFailure(e.toString()));
    }
  }

  Future<void> _onGetAppointmentHistoryRequested(
    GetAppointmentHistoryRequested event,
    Emitter<AppointmentState> emit,
  ) async {
    emit(AppointmentLoading());
    try {
      final appointments = await _dataSource.getAppointmentHistory();
      emit(AppointmentSuccess(appointments));
    } catch (e) {
      emit(AppointmentFailure(e.toString()));
    }
  }
}