import 'package:flutter_chat/core/mappers/remote_mapper.dart';
import 'package:flutter_chat/features/upload_media/data/dtos/upload_part_result_dto.dart';
import 'package:flutter_chat/features/upload_media/domain/entities/upload_part_result.dart';

class ApiUploadResultPartMapper extends RemoteMapper<UploadPartResultDto, UploadPartResult> {
  @override
  UploadPartResult toDomain(UploadPartResultDto dto) {
    return UploadPartResult(
      partNumber: dto.partNumber,
      eTag: dto.eTag,
    );
  }

  @override
  List<UploadPartResult> toDomainList(List<UploadPartResultDto> dtos) {
    return dtos.map((dto) => toDomain(dto)).toList();
  }

  @override
  UploadPartResultDto? toDto(UploadPartResult domain) {
    return UploadPartResultDto(
      partNumber: domain.partNumber,
      eTag: domain.eTag,
    );
  }

  @override
  List<UploadPartResultDto> toDtoList(List<UploadPartResult> domains) {
    return domains.map((domain) => toDto(domain)!).toList();
  }
}