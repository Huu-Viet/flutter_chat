// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'group_setting_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$GroupSettingDTO {

 bool get allowMemberMessage; bool get isPublic; bool get joinApprovalRequired;
/// Create a copy of GroupSettingDTO
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GroupSettingDTOCopyWith<GroupSettingDTO> get copyWith => _$GroupSettingDTOCopyWithImpl<GroupSettingDTO>(this as GroupSettingDTO, _$identity);

  /// Serializes this GroupSettingDTO to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GroupSettingDTO&&(identical(other.allowMemberMessage, allowMemberMessage) || other.allowMemberMessage == allowMemberMessage)&&(identical(other.isPublic, isPublic) || other.isPublic == isPublic)&&(identical(other.joinApprovalRequired, joinApprovalRequired) || other.joinApprovalRequired == joinApprovalRequired));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,allowMemberMessage,isPublic,joinApprovalRequired);

@override
String toString() {
  return 'GroupSettingDTO(allowMemberMessage: $allowMemberMessage, isPublic: $isPublic, joinApprovalRequired: $joinApprovalRequired)';
}


}

/// @nodoc
abstract mixin class $GroupSettingDTOCopyWith<$Res>  {
  factory $GroupSettingDTOCopyWith(GroupSettingDTO value, $Res Function(GroupSettingDTO) _then) = _$GroupSettingDTOCopyWithImpl;
@useResult
$Res call({
 bool allowMemberMessage, bool isPublic, bool joinApprovalRequired
});




}
/// @nodoc
class _$GroupSettingDTOCopyWithImpl<$Res>
    implements $GroupSettingDTOCopyWith<$Res> {
  _$GroupSettingDTOCopyWithImpl(this._self, this._then);

  final GroupSettingDTO _self;
  final $Res Function(GroupSettingDTO) _then;

/// Create a copy of GroupSettingDTO
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? allowMemberMessage = null,Object? isPublic = null,Object? joinApprovalRequired = null,}) {
  return _then(_self.copyWith(
allowMemberMessage: null == allowMemberMessage ? _self.allowMemberMessage : allowMemberMessage // ignore: cast_nullable_to_non_nullable
as bool,isPublic: null == isPublic ? _self.isPublic : isPublic // ignore: cast_nullable_to_non_nullable
as bool,joinApprovalRequired: null == joinApprovalRequired ? _self.joinApprovalRequired : joinApprovalRequired // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [GroupSettingDTO].
extension GroupSettingDTOPatterns on GroupSettingDTO {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GroupSettingDTO value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GroupSettingDTO() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GroupSettingDTO value)  $default,){
final _that = this;
switch (_that) {
case _GroupSettingDTO():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GroupSettingDTO value)?  $default,){
final _that = this;
switch (_that) {
case _GroupSettingDTO() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool allowMemberMessage,  bool isPublic,  bool joinApprovalRequired)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GroupSettingDTO() when $default != null:
return $default(_that.allowMemberMessage,_that.isPublic,_that.joinApprovalRequired);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool allowMemberMessage,  bool isPublic,  bool joinApprovalRequired)  $default,) {final _that = this;
switch (_that) {
case _GroupSettingDTO():
return $default(_that.allowMemberMessage,_that.isPublic,_that.joinApprovalRequired);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool allowMemberMessage,  bool isPublic,  bool joinApprovalRequired)?  $default,) {final _that = this;
switch (_that) {
case _GroupSettingDTO() when $default != null:
return $default(_that.allowMemberMessage,_that.isPublic,_that.joinApprovalRequired);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _GroupSettingDTO implements GroupSettingDTO {
  const _GroupSettingDTO({this.allowMemberMessage = true, this.isPublic = false, this.joinApprovalRequired = false});
  factory _GroupSettingDTO.fromJson(Map<String, dynamic> json) => _$GroupSettingDTOFromJson(json);

@override@JsonKey() final  bool allowMemberMessage;
@override@JsonKey() final  bool isPublic;
@override@JsonKey() final  bool joinApprovalRequired;

/// Create a copy of GroupSettingDTO
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GroupSettingDTOCopyWith<_GroupSettingDTO> get copyWith => __$GroupSettingDTOCopyWithImpl<_GroupSettingDTO>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$GroupSettingDTOToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GroupSettingDTO&&(identical(other.allowMemberMessage, allowMemberMessage) || other.allowMemberMessage == allowMemberMessage)&&(identical(other.isPublic, isPublic) || other.isPublic == isPublic)&&(identical(other.joinApprovalRequired, joinApprovalRequired) || other.joinApprovalRequired == joinApprovalRequired));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,allowMemberMessage,isPublic,joinApprovalRequired);

@override
String toString() {
  return 'GroupSettingDTO(allowMemberMessage: $allowMemberMessage, isPublic: $isPublic, joinApprovalRequired: $joinApprovalRequired)';
}


}

/// @nodoc
abstract mixin class _$GroupSettingDTOCopyWith<$Res> implements $GroupSettingDTOCopyWith<$Res> {
  factory _$GroupSettingDTOCopyWith(_GroupSettingDTO value, $Res Function(_GroupSettingDTO) _then) = __$GroupSettingDTOCopyWithImpl;
@override @useResult
$Res call({
 bool allowMemberMessage, bool isPublic, bool joinApprovalRequired
});




}
/// @nodoc
class __$GroupSettingDTOCopyWithImpl<$Res>
    implements _$GroupSettingDTOCopyWith<$Res> {
  __$GroupSettingDTOCopyWithImpl(this._self, this._then);

  final _GroupSettingDTO _self;
  final $Res Function(_GroupSettingDTO) _then;

/// Create a copy of GroupSettingDTO
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? allowMemberMessage = null,Object? isPublic = null,Object? joinApprovalRequired = null,}) {
  return _then(_GroupSettingDTO(
allowMemberMessage: null == allowMemberMessage ? _self.allowMemberMessage : allowMemberMessage // ignore: cast_nullable_to_non_nullable
as bool,isPublic: null == isPublic ? _self.isPublic : isPublic // ignore: cast_nullable_to_non_nullable
as bool,joinApprovalRequired: null == joinApprovalRequired ? _self.joinApprovalRequired : joinApprovalRequired // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
