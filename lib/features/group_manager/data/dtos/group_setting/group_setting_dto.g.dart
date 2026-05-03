// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'group_setting_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_GroupSettingDTO _$GroupSettingDTOFromJson(Map<String, dynamic> json) =>
    _GroupSettingDTO(
      allowMemberMessage: json['allowMemberMessage'] as bool? ?? true,
      isPublic: json['isPublic'] as bool? ?? false,
      joinApprovalRequired: json['joinApprovalRequired'] as bool? ?? false,
    );

Map<String, dynamic> _$GroupSettingDTOToJson(_GroupSettingDTO instance) =>
    <String, dynamic>{
      'allowMemberMessage': instance.allowMemberMessage,
      'isPublic': instance.isPublic,
      'joinApprovalRequired': instance.joinApprovalRequired,
    };
