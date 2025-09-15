part of 'lawyer_bloc.dart';

abstract class LawyerState extends Equatable {
  const LawyerState();

  @override
  List<Object> get props => [];
}

class LawyerInitial extends LawyerState {}

class LawyerLoading extends LawyerState {}

class LawyerSuccess extends LawyerState {
  final List<dynamic> lawyers;

  const LawyerSuccess(this.lawyers);

  @override
  List<Object> get props => [lawyers];
}

class LawyerFailure extends LawyerState {
  final String message;

  const LawyerFailure(this.message);

  @override
  List<Object> get props => [message];
}