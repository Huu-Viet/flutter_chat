
abstract class RemoteMapper<TDto, TDomain> {
  TDomain toDomain(TDto dto);

  TDto? toDto(TDomain domain) => null;

  List<TDomain> toDomainList(List<TDto> dtos) {
    return dtos.map((dto) => toDomain(dto)).toList();
  }

  List<TDto> toDtoList(List<TDomain> domains) {
    return domains
        .map((domain) => toDto(domain))
        .where((dto) => dto != null)
        .cast<TDto>()
        .toList();
  }
}