import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

part 'appointment_event.dart';
part 'appointment_state.dart';

class AppointmentBloc extends Bloc<AppointmentEvent, AppointmentState> {
  AppointmentBloc() : super(AppointmentInitial()) {
    on<GetAppointmentsRequested>(_onGetAppointmentsRequested);
  }

  Future<void> _onGetAppointmentsRequested(
    GetAppointmentsRequested event,
    Emitter<AppointmentState> emit,
  ) async {
    emit(AppointmentLoading());
    // TODO: Implement get appointments logic
    emit(AppointmentSuccess([]));
  }
}