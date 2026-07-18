import 'dart:async';

import '../../../../core/session/current_session.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_state.dart';

/// [CurrentSession] backed by [AuthBloc] — the only file allowed to bridge
/// the two, so no other feature has to know [AuthBloc] exists.
class AuthCurrentSession extends CurrentSession {
  AuthCurrentSession(this._authBloc) {
    _subscription = _authBloc.stream.listen((_) => notifyListeners());
  }

  final AuthBloc _authBloc;
  late final StreamSubscription _subscription;

  AuthState get _state => _authBloc.state;
  AuthAuthenticated? get _authenticated =>
      _state is AuthAuthenticated ? _state as AuthAuthenticated : null;

  @override
  bool get isSignedIn => _authenticated != null;

  @override
  String get uid => _authenticated?.user.uid ?? '';

  @override
  String get name => _authenticated?.user.name ?? '';

  @override
  bool get isDoctor => _authenticated?.user.isDoctor ?? false;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
