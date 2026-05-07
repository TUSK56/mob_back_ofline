import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';

/// Helper method to return the correct ImageProvider based on the string path.
ImageProvider? getAppImageProvider(String? path) {
  if (path == null || path.isEmpty) {
    return null;
  }
  if (path.startsWith('http://') || path.startsWith('https://')) {
    return NetworkImage(path);
  }
  if (path.startsWith('data:image')) {
    try {
      final base64String = path.split(',').last;
      return MemoryImage(base64Decode(base64String));
    } catch (_) {
      return null;
    }
  }
  if (path.startsWith('assets/')) {
    return AssetImage(path);
  }
  return FileImage(File(path));
}
