import 'package:flutter_chat/features/auth/auth_providers.dart';
import 'package:flutter_chat/features/upload_media/export.dart';
import 'package:riverpod/riverpod.dart';

//service
final presignMediaServiceProvider = Provider<PresignMediaService>((ref) {
	return PresignMediaServiceImpl(ref.watch(authDioProvider));
});

//repository
final uploadMediaRepoProvider = Provider<UploadMediaRepository>((ref) {
	return UploadMediaRepoImpl(ref.read(presignMediaServiceProvider));
});

//use case
final uploadMediaUseCaseProvider = Provider<UploadMediaUseCase>((ref) {
	return UploadMediaUseCase(ref.read(uploadMediaRepoProvider));
});

final getImageUrlByMediaIdUseCaseProvider = Provider<GetImageUrlByMediaIdUseCase>((ref) {
	return GetImageUrlByMediaIdUseCase(ref.read(uploadMediaRepoProvider));
});
