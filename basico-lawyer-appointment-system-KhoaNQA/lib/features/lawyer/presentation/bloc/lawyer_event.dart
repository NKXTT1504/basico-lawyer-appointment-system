part of 'lawyer_bloc.dart';

abstract class LawyerEvent extends Equatable {
  const LawyerEvent();

  @override
  List<Object> get props => [];
}

class GetLawyersRequested extends LawyerEvent {
  const GetLawyersRequested();
}