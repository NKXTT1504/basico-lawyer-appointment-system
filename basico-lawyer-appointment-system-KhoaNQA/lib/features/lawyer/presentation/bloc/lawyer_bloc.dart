import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

part 'lawyer_event.dart';
part 'lawyer_state.dart';

class LawyerBloc extends Bloc<LawyerEvent, LawyerState> {
  LawyerBloc() : super(LawyerInitial()) {
    on<GetLawyersRequested>(_onGetLawyersRequested);
  }

  Future<void> _onGetLawyersRequested(
    GetLawyersRequested event,
    Emitter<LawyerState> emit,
  ) async {
    emit(LawyerLoading());
    // TODO: Implement get lawyers logic
    emit(LawyerSuccess([]));
  }
}