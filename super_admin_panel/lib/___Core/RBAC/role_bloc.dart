import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

// Events
abstract class RoleEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class FetchUserRole extends RoleEvent {
  final String email;
  FetchUserRole(this.email);

  @override
  List<Object> get props => [email];
}

// States
abstract class RoleState extends Equatable {
  @override
  List<Object> get props => [];
}

class RoleInitial extends RoleState {}

class RoleLoading extends RoleState {}

class RoleLoaded extends RoleState {
  final String role;
  RoleLoaded(this.role);

  @override
  List<Object> get props => [role];
}

class RoleError extends RoleState {
  final String message;
  RoleError(this.message);

  @override
  List<Object> get props => [message];
}

// Bloc
class RoleBloc extends Bloc<RoleEvent, RoleState> {
  RoleBloc() : super(RoleInitial()) {
    on<FetchUserRole>(_onFetchUserRole);
  }

  Future<void> _onFetchUserRole(
      FetchUserRole event, Emitter<RoleState> emit) async {
    emit(RoleLoading());
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('Admin_Requests')
          .where('email', isEqualTo: event.email)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final role = querySnapshot.docs.first['role'] as String;
        emit(RoleLoaded(role));
      } else {
        emit(RoleError("User not found"));
      }
    } catch (e) {
      emit(RoleError("Failed to fetch role: $e"));
    }
  }
}
