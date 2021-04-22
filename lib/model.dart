import 'package:json_annotation/json_annotation.dart';

part 'model.g.dart';

@JsonSerializable()
class SFTPLsData {
  const SFTPLsData({
    required this.filename,
    required this.fileSize,
    required this.isDirectory,
    required this.permissions,
    required this.ownerGroupID,
    required this.ownerUserID,
    required this.modificationDate,
    required this.lastAccess,
    required this.flags,
  });

  factory SFTPLsData.fromJson(Map<String, dynamic> json) => _$SFTPLsDataFromJson(json);
  Map<String, dynamic> toJson() => _$SFTPLsDataToJson(this);

  final String filename;
  final int fileSize;
  final bool isDirectory;
  final String permissions;
  final int ownerGroupID;
  final int ownerUserID;
  final DateTime modificationDate;
  final DateTime lastAccess;
  final int flags;
}
