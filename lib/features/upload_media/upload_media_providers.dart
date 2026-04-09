import 'package:flutter_chat/features/auth/auth_providers.dart';
import 'package:flutter_chat/features/upload_media/data/api/upload_media_service_impl.dart';
import 'package:flutter_chat/features/upload_media/data/repo_impl/upload_media_repo_impl.dart';
import 'package:flutter_chat/features/upload_media/export.dart';
import 'package:riverpod/riverpod.dart';

//service
final presignMediaServiceProvider = Provider<PresignMediaService>((ref) {
	return PresignMediaServiceImpl(ref.read(authDioProvider));
});

//repository
final uploadMediaRepoProvider = Provider<UploadMediaRepository>((ref) {
	return UploadMediaRepoImpl(ref.read(presignMediaServiceProvider));
});

//use case
final uploadMediaUseCaseProvider = Provider<UploadMediaUseCase>((ref) {
	return UploadMediaUseCase(ref.read(uploadMediaRepoProvider));
});
