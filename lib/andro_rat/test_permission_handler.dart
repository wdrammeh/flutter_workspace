// https://pub.dev/packages/permission_handler

import 'package:permission_handler/permission_handler.dart';

void main() async {
  // There are a number of Permissions. You can get a Permission's status, which is either granted, denied, restricted or permanentlyDenied.
  var status = await Permission.camera.status;
  if (status.isDenied) {
    // We didn't ask for permission yet or the permission has been denied before but not permanently.
  }

  // You can can also directly ask the permission about its status.
  if (await Permission.location.isRestricted) {
    // The OS restricts access, for example because of parental controls.
  }


  // Call request() on a Permission to request it. If it has already been granted before, nothing happens.
  // request() returns the new status of the Permission.
  if (await Permission.contacts.request().isGranted) {
    // Either the permission was already granted before or the user just granted it.
  }

  // You can request multiple permissions at once.
  Map<Permission, PermissionStatus> statuses = await [
    Permission.location,
    Permission.storage,
  ].request();
  print(statuses[Permission.location]);

  // Some permissions, for example location or acceleration sensor permissions, have an associated service, which can be enabled or disabled.
  if (await Permission.locationWhenInUse.serviceStatus.isEnabled) {
    // Use location.
  }

  // Ye can also open the settings
  if (await Permission.speech.isPermanentlyDenied) {
    // The user opted to never again see the permission request dialog for this
    // app. The only way to change the permission's status now is to let the
    // user manually enable it in the system settings.
    openAppSettings();
  }
}