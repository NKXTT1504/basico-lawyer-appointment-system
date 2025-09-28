part of 'appointment_bloc.dart';

abstract class AppointmentEvent extends Equatable {
  const AppointmentEvent();

  @override
  List<Object> get props => [];
}

class GetAppointmentsRequested extends AppointmentEvent {
  const GetAppointmentsRequested();
}

class GetUpcomingAppointmentsRequested extends AppointmentEvent {
  const GetUpcomingAppointmentsRequested();
}

class GetAppointmentHistoryRequested extends AppointmentEvent {
  const GetAppointmentHistoryRequested();
}