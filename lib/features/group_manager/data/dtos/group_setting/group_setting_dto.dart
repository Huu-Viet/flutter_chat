import 'package:freezed_annotation/freezed_annotation.dart';

part 'group_setting_dto.freezed.dart';
part 'group_setting_dto.g.dart';

@freezed
abstract class GroupSettingDTO with _$GroupSettingDTO {
  const factory GroupSettingDTO({
    @Default(true) bool allowMemberMessage,
    @Default(false) bool isPublic,
    @Default(false) bool joinApprovalRequired,
  }) = _GroupSettingDTO;

  factory GroupSettingDTO.fromJson(Map<String, dynamic> json)
  => _$GroupSettingDTOFromJson(json);
}