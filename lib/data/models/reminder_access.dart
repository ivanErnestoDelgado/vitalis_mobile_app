// lib/data/models/reminder_access.dart
import 'user_profile.dart';

class ReminderAccess {
  final int id;
  final int reminder;
  final int user;
  final UserProfile userInfo;

  final bool canEdit;
  final bool canDelete;
  final bool receiveNotifications;
  final DateTime addedAt;

  ReminderAccess({
    required this.id,
    required this.reminder,
    required this.user,
    required this.userInfo,
    required this.canEdit,
    required this.canDelete,
    required this.receiveNotifications,
    required this.addedAt,
  });

  factory ReminderAccess.fromJson(Map<String, dynamic> json) {
    return ReminderAccess(
      id: json["id"],
      reminder: json["reminder"],
      user: json["user"],
      userInfo: UserProfile.fromJson(json["user_info"]),
      canEdit: json["can_edit"],
      canDelete: json["can_delete"],
      receiveNotifications: json["receive_notifications"],
      addedAt: DateTime.parse(json["added_at"]).toLocal(),
    );
  }
}
