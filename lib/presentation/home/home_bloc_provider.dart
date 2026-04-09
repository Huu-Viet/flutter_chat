import 'package:flutter_chat/presentation/home/blocs/home_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Binds [HomeBloc] lifecycle to Riverpod.
///
/// - Automatically loads conversations once.
/// - Closes bloc on dispose.
final homeBlocProvider = Provider<HomeBloc>((ref) {
  final bloc = ref.read(_homeBlocFactoryProvider);
  bloc.add(const LoadHomeEvent());
  ref.onDispose(bloc.close);
  return bloc;
});

/// This indirection keeps wiring (usecase deps) in one place.
final _homeBlocFactoryProvider = Provider<HomeBloc>((ref) {
  // NOTE: import is kept local by using a separate provider file.
  throw UnimplementedError('Override _homeBlocFactoryProvider in home_provider.dart');
});

