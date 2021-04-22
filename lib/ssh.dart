import 'dart:async';

import 'package:flutter/services.dart';
import 'package:ssh/model.dart';
import 'package:uuid/uuid.dart';

const MethodChannel _channel = MethodChannel('ssh');
const EventChannel _eventChannel = EventChannel('shell_sftp');
Stream<dynamic>? get onStateChanged => _eventChannel.receiveBroadcastStream();

typedef Callback = void Function(dynamic result);

class SSHClient {
  SSHClient({
    required this.host,
    required this.port,
    required this.username,
    required this.passwordOrKey, // password or {privateKey: value, [publicKey: value, passphrase: value]}
  })   : id = const Uuid().v4(),
        shellCallback = null,
        uploadCallback = null,
        downloadCallback = null,
        stateSubscription = null {
    stateSubscription = onStateChanged?.listen((dynamic result) {
      _parseOutput(result);
    });
  }

  final String id;
  final String host;
  final int port;
  final String username;
  final dynamic passwordOrKey;
  StreamSubscription<dynamic>? stateSubscription;
  Callback? shellCallback;
  Callback? uploadCallback;
  Callback? downloadCallback;

  void _parseOutput(dynamic result) {
    switch (result["name"]) {
      case "Shell":
        if (shellCallback != null && result["key"] == id) shellCallback!(result["value"]);
        break;
      case "DownloadProgress":
        if (downloadCallback != null && result["key"] == id) downloadCallback!(result["value"]);
        break;
      case "UploadProgress":
        if (uploadCallback != null && result["key"] == id) uploadCallback!(result["value"]);
        break;
    }
  }

  Future<String?> connect() async {
    final result = await _channel.invokeMethod<String>('connectToHost', <String, dynamic>{
      "id": id,
      "host": host,
      "port": port,
      "username": username,
      "passwordOrKey": passwordOrKey,
    });

    return result;
  }

  Future<String?> execute(String cmd) async {
    final result = await _channel.invokeMethod<String>('execute', {
      "id": id,
      "cmd": cmd,
    });

    return result;
  }

  Future<String?> portForwardL(int rport, int lport, String rhost) async {
    final result = await _channel.invokeMethod<String>('portForwardL', {
      "id": id,
      "rhost": rhost,
      "rport": rport,
      "lport": lport,
    });
    return result;
  }

  Future<String?> startShell({
    String ptyType = "vanilla", // vanilla, vt100, vt102, vt220, ansi, xterm
    required Callback callback,
  }) async {
    shellCallback = callback;

    final result = await _channel.invokeMethod<String>('startShell', {
      "id": id,
      "ptyType": ptyType,
    });

    return result;
  }

  Future<String?> writeToShell(String cmd) async {
    final result = await _channel.invokeMethod<String>('writeToShell', {
      "id": id,
      "cmd": cmd,
    });

    return result;
  }

  Future<dynamic> closeShell() {
    shellCallback = null;
    return _channel.invokeMethod<dynamic>('closeShell', {
      "id": id,
    });
  }

  Future<String?> connectSFTP() async {
    final result = await _channel.invokeMethod<String>('connectSFTP', {
      "id": id,
    });
    return result;
  }

  Future<List<SFTPLsData>?> sftpLs([String path = '.']) async {
    final rawResult = await _channel.invokeMethod<List<dynamic>>('sftpLs', {
      "id": id,
      "path": path,
    });

    if (rawResult == null) return null;

    // convert from Map<dynamic, dynamic> to Map<String, dynamic>
    return rawResult
        .map((dynamic r) {
          return (r as Map<dynamic, dynamic>)
              .map<String, dynamic>((dynamic key, dynamic value) => MapEntry<String, dynamic>(key.toString(), value));
        })
        .map((e) => SFTPLsData.fromJson(e))
        .toList();
  }

  Future<String?> sftpRename({required String oldPath, required String newPath}) async {
    final result = await _channel.invokeMethod<String>('sftpRename', {
      "id": id,
      "oldPath": oldPath,
      "newPath": newPath,
    });

    return result;
  }

  Future<String?> sftpMkdir(String path) async {
    final result = await _channel.invokeMethod<String>('sftpMkdir', {
      "id": id,
      "path": path,
    });

    return result;
  }

  Future<String?> sftpRm(String path) async {
    final result = await _channel.invokeMethod<String>('sftpRm', {
      "id": id,
      "path": path,
    });

    return result;
  }

  Future<String?> sftpRmdir(String path) async {
    final result = await _channel.invokeMethod<String>('sftpRmdir', {
      "id": id,
      "path": path,
    });

    return result;
  }

  Future<String?> sftpDownload({
    required String path,
    required String toPath,
    Callback? callback,
  }) async {
    downloadCallback = callback;
    final result = await _channel.invokeMethod<String>('sftpDownload', {
      "id": id,
      "path": path,
      "toPath": toPath,
    });

    return result;
  }

  Future<dynamic> sftpCancelDownload() {
    return _channel.invokeMethod<dynamic>('sftpCancelDownload', {
      "id": id,
    });
  }

  Future<String?> sftpUpload({
    required String path,
    required String toPath,
    Callback? callback,
  }) async {
    uploadCallback = callback;
    final result = await _channel.invokeMethod<String>('sftpUpload', {
      "id": id,
      "path": path,
      "toPath": toPath,
    });
    return result;
  }

  Future<dynamic> sftpCancelUpload() {
    return _channel.invokeMethod<dynamic>('sftpCancelUpload', {
      "id": id,
    });
  }

  Future<dynamic> disconnectSFTP() {
    uploadCallback = null;
    downloadCallback = null;
    return _channel.invokeMethod<dynamic>('disconnectSFTP', {
      "id": id,
    });
  }

  void disconnect() {
    shellCallback = null;
    uploadCallback = null;
    downloadCallback = null;
    stateSubscription?.cancel();
    _channel.invokeMethod<dynamic>('disconnect', {
      "id": id,
    });
  }

  Future<bool> isConnected() async {
    bool connected = false; // default to false
    final result = await _channel.invokeMethod<String>('isConnected', {
      "id": id,
    });

    if (result == "true") {
      connected = true;
    }

    return connected;
  }
}
