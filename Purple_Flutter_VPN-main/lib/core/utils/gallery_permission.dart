// ignore_for_file: use_build_context_synchronously

import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class GalleryPermission {
  Future<PermissionStatus> galleryPermission(BuildContext context) async {
    if (Platform.isIOS) {
      PermissionStatus permission = await Permission.photos.status;
      if (permission == PermissionStatus.permanentlyDenied) {
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("photos_permission").tr(),
            content: const Text("permission_alert_msg").tr(),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text(
                  "cancel",
                  style: TextStyle(
                    color: Color(0xFF2E86C1),
                    fontSize: 16,
                  ),
                ).tr(),
              ),
              TextButton(
                onPressed: () async {
                  await openAppSettings();
                  Navigator.of(context).pop();
                },
                child: const Text(
                  "settings",
                  style: TextStyle(
                    color: Color(0xFF2E86C1),
                    fontSize: 16,
                  ),
                ).tr(),
              ),
            ],
          ),
        );
        PermissionStatus permissionStatus = await Permission.photos.request();
        return permissionStatus;
      } else if (permission != PermissionStatus.granted) {
        PermissionStatus permissionStatus = await Permission.photos.request();
        return permissionStatus;
      } else {
        return permission;
      }
    } else {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      if (androidInfo.version.sdkInt <= 32) {
        PermissionStatus permission = await Permission.storage.status;
        if (permission != PermissionStatus.granted &&
            permission != PermissionStatus.permanentlyDenied) {
          PermissionStatus permissionStatus =
              await Permission.storage.request();
          return permissionStatus;
        } else if (permission == PermissionStatus.permanentlyDenied) {
          await showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text("storage_permission").tr(),
              content: const Text("storage_permission_msg").tr(),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text(
                    "cancel",
                    style: TextStyle(
                      color: Color(0xFF2E86C1),
                      fontSize: 16,
                    ),
                  ).tr(),
                ),
                TextButton(
                  onPressed: () async {
                    await openAppSettings();
                    Navigator.of(context).pop();
                  },
                  child: const Text(
                    "settings",
                    style: TextStyle(
                      color: Color(0xFF2E86C1),
                      fontSize: 16,
                    ),
                  ).tr(),
                ),
              ],
            ),
          );
          PermissionStatus permissionStatus =
              await Permission.storage.request();
          return permissionStatus;
        } else {
          return permission;
        }
      } else {
        PermissionStatus permission = await Permission.photos.status;
        if (permission != PermissionStatus.granted &&
            permission != PermissionStatus.permanentlyDenied) {
          PermissionStatus permissionStatus = await Permission.photos.request();
          return permissionStatus;
        } else if (permission == PermissionStatus.permanentlyDenied) {
          await showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text("photos_permission").tr(),
              content: const Text("permission_alert_msg").tr(),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text(
                    "cancel",
                    style: TextStyle(
                      color: Color(0xFF2E86C1),
                      fontSize: 16,
                    ),
                  ).tr(),
                ),
                TextButton(
                  onPressed: () async {
                    await openAppSettings();
                    Navigator.of(context).pop();
                  },
                  child: const Text(
                    "settings",
                    style: TextStyle(
                      color: Color(0xFF2E86C1),
                      fontSize: 16,
                    ),
                  ).tr(),
                ),
              ],
            ),
          );
          PermissionStatus permissionStatus = await Permission.photos.request();
          return permissionStatus;
        } else {
          return permission;
        }
      }
    }
  }
}
