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

final getMyMediaListUseCaseProvider = Provider<GetMyMediaListUseCase>((ref) {
	return GetMyMediaListUseCase(ref.read(uploadMediaRepoProvider));
});

final getMediaUrlByMediaIdUseCaseProvider = Provider<GetMediaUrlByMediaIdUseCase>((ref) {
	return GetMediaUrlByMediaIdUseCase(ref.read(uploadMediaRepoProvider));
});

final getMediaPlayInfoUseCaseProvider = Provider<GetMediaPlayInfoUseCase>((ref) {
	return GetMediaPlayInfoUseCase(ref.read(uploadMediaRepoProvider));
});

final deleteMediaUseCaseProvider = Provider<DeleteMediaUseCase>((ref) {
	return DeleteMediaUseCase(ref.read(uploadMediaRepoProvider));
});

final crossShareMediaUseCaseProvider = Provider<CrossShareMediaUseCase>((ref) {
	return CrossShareMediaUseCase(ref.read(uploadMediaRepoProvider));
});

final initMultipartUploadUseCaseProvider = Provider<InitMultipartUploadUseCase>((ref) {
	return InitMultipartUploadUseCase(ref.read(uploadMediaRepoProvider));
});

final presignMultipartPartsUseCaseProvider = Provider<PresignMultipartPartsUseCase>((ref) {
	return PresignMultipartPartsUseCase(ref.read(uploadMediaRepoProvider));
});

final completeMultipartUploadUseCaseProvider = Provider<CompleteMultipartUploadUseCase>((ref) {
	return CompleteMultipartUploadUseCase(ref.read(uploadMediaRepoProvider));
});

final abortMultipartUploadUseCaseProvider = Provider<AbortMultipartUploadUseCase>((ref) {
	return AbortMultipartUploadUseCase(ref.read(uploadMediaRepoProvider));
});
