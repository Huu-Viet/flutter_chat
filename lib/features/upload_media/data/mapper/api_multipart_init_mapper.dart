import 'package:flutter_chat/core/mappers/remote_mapper.dart';
import 'package:flutter_chat/features/upload_media/data/dtos/multipart_init_info_dto.dart';
import 'package:flutter_chat/features/upload_media/domain/entities/multipart_init_info.dart';

class ApiMultipartInitMapper extends RemoteMapper<MultipartInitInfoDto, MultipartInitInfo> {
  @override
  MultipartInitInfo toDomain(MultipartInitInfoDto dto) {
    return MultipartInitInfo(
      mediaId: dto.mediaId,
      uploadId: dto.uploadId,
      objectKey: dto.objectKey,
    );
  }

  @override
  List<MultipartInitInfo> toDomainList(List<MultipartInitInfoDto> dtos) {
    return dtos.map((dto) => toDomain(dto)).toList();
  }

  @override
  MultipartInitInfoDto? toDto(MultipartInitInfo domain) {
    return MultipartInitInfoDto(
      mediaId: domain.mediaId,
      uploadId: domain.uploadId,
      objectKey: domain.objectKey,
    );
  }
}