import 'package:flutter/material.dart';
import 'package:tesia_app/l10n/app_localizations.dart';
import 'package:tesia_app/shared/colors.dart';
import 'package:tesia_app/shared/shimmer/notifications_shimmer.dart';
import 'package:lottie/lottie.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tesia_app/services/notification_service.dart';
import 'package:tesia_app/shared/components/showsnackbar.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  final String? _userId = FirebaseAuth.instance.currentUser?.uid;

  @override
  void initState() {
    super.initState();
  }

  void _markAsRead(String notificationId) async {
    if (_userId != null) {
      await NotificationService.markAsRead(_userId, notificationId);
    }
  }

  void _markAllAsRead() async {
    if (_userId != null) {
      await NotificationService.markAllAsRead(_userId);
      if (mounted) {
        final loc = AppLocalizations.of(context)!;
        showSnack(context, loc.allMarkedAsRead);
      }
    }
  }

  void _deleteNotification(String notificationId) async {
    if (_userId != null) {
      await NotificationService.deleteNotification(_userId, notificationId);
      if (mounted) {
        final loc = AppLocalizations.of(context)!;
        showSnack(context, loc.notificationDeleted);
      }
    }
  }

  void _deleteAllNotifications() {
    final loc = AppLocalizations.of(context)!;
    final color = Theme.of(context).colorScheme;

    showDialog(
      context: context,
      barrierDismissible: true,
      builder:
          (ctx) => AlertDialog(
            backgroundColor: color.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Row(
              children: [
                Icon(Icons.delete_sweep, color: color.error),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    loc.deleteAllNotifications,
                    style: TextStyle(
                      color: color.onSurface,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            content: Text(
              loc.deleteAllNotificationsConfirm,
              style: TextStyle(color: color.onSurface.withOpacity(0.9)),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                style: TextButton.styleFrom(foregroundColor: kTesiaColor),
                child: Text(loc.cancel),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.pop(ctx);
                  if (_userId != null) {
                    await NotificationService.deleteAllNotifications(_userId);
                    if (mounted) {
                      showSnack(context, loc.allNotificationsDeleted);
                    }
                  }
                },
                style: TextButton.styleFrom(foregroundColor: color.error),
                child: Text(loc.delete),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_userId == null) {
      return Scaffold(
        backgroundColor: isDark ? const Color(0xFF121212) : Colors.grey[50],
        body: Center(
          child: Text(
            loc.pleaseSignInToViewNotifications ??
                'Please sign in to view notifications',
            style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : Colors.grey[50],
      body: SafeArea(
        child: StreamBuilder<QuerySnapshot>(
          stream: NotificationService.getUserNotificationsStream(_userId),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(
                child: Text(
                  loc.errorLoadingNotifications ??
                      'Error loading notifications',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              );
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const NotificationsShimmer();
            }

            final notifications = snapshot.data?.docs ?? [];
            final unreadCount =
                notifications.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  return data['isRead'] == false;
                }).length;

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              loc.notifications,
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                            if (unreadCount > 0)
                              Text(
                                loc.unreadNotifications(unreadCount),
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface.withOpacity(0.6),
                                ),
                              ),
                          ],
                        ),
                      ),
                      if (notifications.isNotEmpty) ...[
                        if (unreadCount > 0)
                          IconButton(
                            onPressed: _markAllAsRead,
                            tooltip: loc.markAllAsRead,
                            icon: Icon(
                              Icons.done_all,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                        IconButton(
                          onPressed: _deleteAllNotifications,
                          tooltip: loc.deleteAll,
                          icon: Icon(
                            Icons.delete_sweep,
                            color: Colors.red[400],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Expanded(
                  child:
                      notifications.isEmpty
                          ? _buildEmptyState(isDark)
                          : ListView.separated(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            itemCount: notifications.length,
                            separatorBuilder:
                                (_, __) => const SizedBox(height: 8),
                            itemBuilder: (context, index) {
                              final doc = notifications[index];
                              final data = doc.data() as Map<String, dynamic>;

                              final meta =
                                  data['meta'] as Map<String, dynamic>?;
                              final titleKey = data['titleKey'] as String?;
                              final messageKey = data['messageKey'] as String?;
                              final loc = AppLocalizations.of(context)!;

                              String localizedTitle() {
                                final rawTitle = data['title'] as String?;
                                if (titleKey == 'welcome_notification_title') {
                                  return loc.welcomeNotificationTitle;
                                }
                                if (titleKey == 'scan_result_title') {
                                  return loc.scanResultTitle(
                                    meta?['moldType'] ?? '',
                                  );
                                }
                                if (rawTitle != null) {
                                  if (rawTitle ==
                                      'welcome_notification_title') {
                                    return loc.welcomeNotificationTitle;
                                  }
                                  if (rawTitle == 'scan_result_title') {
                                    return loc.scanResultTitle(
                                      meta?['moldType'] ?? '',
                                    );
                                  }
                                  return rawTitle;
                                }
                                return '';
                              }

                              String localizedMessage() {
                                final rawMsg = data['message'] as String?;

                                if (messageKey ==
                                    'welcome_notification_message') {
                                  return loc.welcomeNotificationMessage;
                                }
                                if (messageKey == 'scan_result_message_high') {
                                  return loc.scanResultMessageHigh(
                                    meta?['moldType'] ?? '',
                                    meta?['scansLeft']?.toString() ?? '',
                                  );
                                }
                                if (messageKey ==
                                    'scan_result_message_medium') {
                                  return loc.scanResultMessageMedium(
                                    meta?['moldType'] ?? '',
                                    meta?['scansLeft']?.toString() ?? '',
                                  );
                                }
                                if (messageKey == 'scan_result_message') {
                                  return loc.scanResultMessage(
                                    meta?['moldType'] ?? '',
                                    meta?['scansLeft']?.toString() ?? '',
                                  );
                                }

                                if (rawMsg != null) {
                                  if (rawMsg ==
                                      'welcome_notification_message') {
                                    return loc.welcomeNotificationMessage;
                                  }
                                  if (rawMsg == 'scan_result_message_high') {
                                    return loc.scanResultMessageHigh(
                                      meta?['moldType'] ?? '',
                                      meta?['scansLeft']?.toString() ?? '',
                                    );
                                  }
                                  if (rawMsg == 'scan_result_message_medium') {
                                    return loc.scanResultMessageMedium(
                                      meta?['moldType'] ?? '',
                                      meta?['scansLeft']?.toString() ?? '',
                                    );
                                  }
                                  if (rawMsg == 'scan_result_message') {
                                    return loc.scanResultMessage(
                                      meta?['moldType'] ?? '',
                                      meta?['scansLeft']?.toString() ?? '',
                                    );
                                  }
                                  return rawMsg;
                                }
                                return '';
                              }

                              return _buildNotificationCard(
                                notificationId: doc.id,
                                title: localizedTitle(),
                                message: localizedMessage(),
                                timestamp:
                                    (data['timestamp'] as Timestamp?)
                                        ?.toDate() ??
                                    DateTime.now(),
                                type: data['type'] ?? 'info',
                                isRead: data['isRead'] ?? false,
                                isDark: isDark,
                                loc: loc,
                              );
                            },
                          ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildNotificationCard({
    required String notificationId,
    required String title,
    required String message,
    required DateTime timestamp,
    required String type,
    required bool isRead,
    required bool isDark,
    required AppLocalizations loc,
  }) {
    final iconData = _getNotificationIcon(type);
    final iconColor = _getNotificationColor(type);

    return Dismissible(
      key: Key(notificationId),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => _deleteNotification(notificationId),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.transparent,
              Colors.red.withOpacity(0.3),
              Colors.red.withOpacity(0.7),
              Colors.red,
            ],
            stops: const [0.0, 0.5, 0.8, 1.0],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            const Icon(Icons.delete_outline, color: Colors.white, size: 24),
            const SizedBox(width: 8),
            Text(
              loc.delete,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
      child: InkWell(
        onTap: () => _markAsRead(notificationId),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color:
                isDark
                    ? (isRead
                        ? Theme.of(context).colorScheme.surface
                        : Theme.of(
                          context,
                        ).colorScheme.surface.withOpacity(0.8))
                    : (isRead ? Colors.white : kTesiaColor.withOpacity(0.05)),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color:
                  isRead
                      ? (isDark ? Colors.grey[800]! : Colors.grey[200]!)
                      : (isDark
                          ? kTesiaColor.withOpacity(0.3)
                          : kTesiaColor.withOpacity(0.2)),
            ),
            boxShadow: [
              BoxShadow(
                color:
                    isDark
                        ? Colors.black.withOpacity(0.3)
                        : Colors.grey.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(iconData, color: iconColor, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                        ),
                        if (!isRead)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: kTesiaColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      message,
                      style: TextStyle(
                        fontSize: 13,
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withOpacity(0.7),
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _formatTimestamp(timestamp, loc),
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withOpacity(0.5),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getNotificationIcon(String type) {
    switch (type) {
      case 'success':
        return Icons.check_circle_outline;
      case 'warning':
        return Icons.warning_amber_outlined;
      case 'error':
        return Icons.error_outline;
      case 'info':
      default:
        return Icons.info_outline;
    }
  }

  Color _getNotificationColor(String type) {
    switch (type) {
      case 'success':
        return Colors.green;
      case 'warning':
        return Colors.orange;
      case 'error':
        return Colors.red;
      case 'info':
      default:
        return kTesiaColor;
    }
  }

  Widget _buildEmptyState(bool isDark) {
    final loc = AppLocalizations.of(context)!;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            height: 180,
            width: 180,
            child: Lottie.asset(
              'assets/animations/Notifications.json',
              fit: BoxFit.contain,
              repeat: true,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            loc.noNotificationsYet,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              loc.notificationsDescription,
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp, AppLocalizations loc) {
    final now = DateTime.now();
    final diff = now.difference(timestamp);

    if (diff.inMinutes < 1) {
      return loc.justNow;
    } else if (diff.inMinutes < 60) {
      return loc.minutesAgo(diff.inMinutes);
    } else if (diff.inHours < 24) {
      return loc.hoursAgo(diff.inHours);
    } else if (diff.inDays < 7) {
      return loc.daysAgo(diff.inDays);
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }
}

enum NotificationType { success, warning, error, info }

class NotificationItem {
  final String id;
  final String title;
  final String message;
  final DateTime timestamp;
  final NotificationType type;
  final bool isRead;

  NotificationItem({
    required this.id,
    required this.title,
    required this.message,
    required this.timestamp,
    required this.type,
    required this.isRead,
  });
}
