import 'package:flutter_chat/features/call/domain/repositories/call_repository.dart';

import '../api/call_remote_ds.dart';

class CallRepoImpl extends CallRepository {
  final CallRemoteDataSource _callRemoteDataSource;

  CallRepoImpl(this._callRemoteDataSource);
}