// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SFTPLsData _$SFTPLsDataFromJson(Map<String, dynamic> json) {
  return SFTPLsData(
    filename: json['filename'] as String,
    fileSize: json['fileSize'] as int,
    isDirectory: json['isDirectory'] as bool,
    permissions: json['permissions'] as String,
    ownerGroupID: json['ownerGroupID'] as int,
    ownerUserID: json['ownerUserID'] as int,
    modificationDate: DateTime.parse(json['modificationDate'] as String),
    lastAccess: DateTime.parse(json['lastAccess'] as String),
    flags: json['flags'] as int,
  );
}

Map<String, dynamic> _$SFTPLsDataToJson(SFTPLsData instance) =>
    <String, dynamic>{
      'filename': instance.filename,
      'fileSize': instance.fileSize,
      'isDirectory': instance.isDirectory,
      'permissions': instance.permissions,
      'ownerGroupID': instance.ownerGroupID,
      'ownerUserID': instance.ownerUserID,
      'modificationDate': instance.modificationDate.toIso8601String(),
      'lastAccess': instance.lastAccess.toIso8601String(),
      'flags': instance.flags,
    };
