part of 'appointment_bloc.dart';

abstract class AppointmentEvent extends Equatable {
  const AppointmentEvent();

  @override
  List<Object> get props => [];
}

class GetAppointmentsRequested extends AppointmentEvent {
  const GetAppointmentsRequested();
}