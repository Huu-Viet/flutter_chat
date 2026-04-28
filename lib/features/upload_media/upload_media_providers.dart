import 'package:flutter_chat/features/auth/auth_providers.dart';
import 'package:flutter_chat/features/upload_media/data/mapper/api_multipart_init_mapper.dart';
import 'package:flutter_chat/features/upload_media/data/mapper/api_upload_result_part_mapper.dart';
import 'package:flutter_chat/features/upload_media/domain/usecases/upload_multipart_usecase.dart';
import 'package:flutter_chat/features/upload_media/export.dart';
import 'package:riverpod/riverpod.dart';

//service
final presignMediaServiceProvider = Provider<PresignMediaService>((ref) {
	return PresignMediaServiceImpl(ref.watch(authDioProvider));
});

//mapper
final apiPresignedPartMapperProvider = Provider<ApiPresignedPartMapper>((ref) {
	return ApiPresignedPartMapper();
});

final apiMultipartInitMapperProvider = Provider<ApiMultipartInitMapper>((ref) {
	return ApiMultipartInitMapper();
});

final apiUploadResultPartMapperProvider = Provider<ApiUploadResultPartMapper>((ref) {
	return ApiUploadResultPartMapper();
});

//repository
final uploadMediaRepoProvider = Provider<UploadMediaRepository>((ref) {
	return UploadMediaRepoImpl(
			presignMediaService: ref.read(presignMediaServiceProvider),
			apiPresignedPartMapper: ref.read(apiPresignedPartMapperProvider),
			apiMultipartInitMapper: ref.read(apiMultipartInitMapperProvider),
			apiUploadResultPartMapper: ref.read(apiUploadResultPartMapperProvider),
	);
});

//use case
final uploadMediaUseCaseProvider = Provider<UploadMediaUseCase>((ref) {
	return UploadMediaUseCase(ref.read(uploadMediaRepoProvider));
});

final uploadMultipartUseCaseProvider = Provider<UploadMultipartUseCase>((ref) {
	return UploadMultipartUseCase(ref.read(uploadMediaRepoProvider));
});

final getImageUrlByMediaIdUseCaseProvider = Provider<GetUrlByMediaIdUseCase>((ref) {
	return GetUrlByMediaIdUseCase(ref.read(uploadMediaRepoProvider));
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

final abortMultipartUploadUseCaseProvider = Provider<AbortMultipartUploadUseCase>((ref) {
	return AbortMultipartUploadUseCase(ref.read(uploadMediaRepoProvider));
});
