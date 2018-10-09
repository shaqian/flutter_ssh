# ssh

SSH and SFTP client for Flutter. Wraps iOS library [NMSSH](https://github.com/NMSSH/NMSSH) and Android library [JSch](http://www.jcraft.com/jsch/).

## Installation

Add `ssh` as a [dependency in your pubspec.yaml file](https://flutter.io/using-packages/).

## Usage

### Create a client using password authentication
```dart
import 'package:ssh/ssh.dart';

var client = new SSHClient(
  host: "my.sshtest",
  port: 22,
  username: "sha",
  passwordOrKey: "Password01.",
);
```

### Create a client using public key authentication
```dart
import 'package:ssh/ssh.dart';

var client = new SSHClient(
  host: "my.sshtest",
  port: 22,
  username: "sha",
  passwordOrKey: {
    "privateKey": """-----BEGIN RSA PRIVATE KEY-----
    ......
-----END RSA PRIVATE KEY-----""",
  },
);
```

### Connect client
```dart
await client.connect();
```

### Close client
```dart
await client.disconnect();
```

### Execute SSH command
```dart
var result = await client.execute("ps");
```

### Shell

#### Start shell: 
- Supported ptyType: vanilla, vt100, vt102, vt220, ansi, xterm
```dart
var result = await client.startShell(
  ptyType: "xterm", // defaults to vanilla
  callback: (dynamic res) {
    print(res);     // read from shell
  }
);
```

#### Write to shell: 
```dart
await client.writeToShell("ls\n");
```

#### Close shell: 
```dart
await client.closeShell();
```

### SFTP

#### Connect SFTP:
```dart
await client.connectSFTP();
```

#### List directory: 
```dart
var array = await client.sftpLs("/home"); // defaults to .
```

#### Create directory: 
```dart
await client.sftpMkdir("testdir");
```

#### Rename file or directory: 
```dart
await client.sftpRename(
  oldPath: "testfile",
  newPath: "newtestfile",
);
```

#### Remove directory: 
```dart
await client.sftpRmdir("testdir");
```

#### Remove file: 
```dart
await client.sftpRm("testfile");
```

#### Download file: 
```dart
var filePath = await client.sftpDownload(
  path: "testfile",
  toPath: tempPath,
  callback: (progress) {
    print(progress); // read download progress
  },
);

// Cancel download:
await client.sftpCancelDownload();
```

#### Upload file: 
```dart
await client.sftpUpload(
  path: filePath,
  toPath: ".",
  callback: (progress) {
    print(progress); // read upload progress
  },
);

// Cancel upload:
await client.sftpCancelUpload();
```

#### Close SFTP: 
```dart
await client.disconnectSFTP();
```

## Demo

Refer to the [example](https://github.com/shaqian/flutter_ssh/tree/master/example).