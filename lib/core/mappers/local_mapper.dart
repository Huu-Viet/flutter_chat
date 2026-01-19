abstract class LocalMapper<TEntity, TDomain> {
  TDomain toDomain(TEntity entity);

  TEntity toEntity(TDomain domain);

  List<TDomain> toDomainList(List<TEntity> entities) {
    return entities.map((entity) => toDomain(entity)).toList();
  }

  List<TEntity> toEntityList(List<TDomain> domains) {
    return domains.map((domain) => toEntity(domain)).toList();
  }
}