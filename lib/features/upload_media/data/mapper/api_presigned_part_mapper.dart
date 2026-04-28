import 'package:flutter_chat/core/mappers/remote_mapper.dart';
import 'package:flutter_chat/features/upload_media/data/dtos/presigned_part_dto.dart';
import 'package:flutter_chat/features/upload_media/domain/entities/presigned_part.dart';

class ApiPresignedPartMapper extends RemoteMapper<PresignedPartDto, PresignedPart> {
  @override
  PresignedPart toDomain(PresignedPartDto dto) {
    return PresignedPart(
      partNumber: dto.partNumber,
      presignedUrl: dto.url
    );
  }

  @override
  List<PresignedPart> toDomainList(List<PresignedPartDto> dtos) {
    return dtos.map((dto) => toDomain(dto)).toList();
  }

  @override
  PresignedPartDto? toDto(PresignedPart domain) {
    return PresignedPartDto(
      partNumber: domain.partNumber,
      url: domain.presignedUrl
    );
  }
}