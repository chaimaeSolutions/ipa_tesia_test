import 'package:flutter/material.dart';

void showSnack(
  BuildContext context,
  String message, {
  bool error = false,
  String? actionLabel,
  VoidCallback? onAction,
  Duration throttleDuration = const Duration(milliseconds: 800),
}) {
  
  _SnackDebouncer.instance.show(
    context,
    message,
    error: error,
    actionLabel: actionLabel,
    onAction: onAction,
    throttleDuration: throttleDuration,
  );
}

class _SnackDebouncer {
  _SnackDebouncer._();
  static final _SnackDebouncer instance = _SnackDebouncer._();

  DateTime? _lastShownAt;
  String? _lastMessage;

  void show(
    BuildContext context,
    String message, {
    required bool error,
    String? actionLabel,
    VoidCallback? onAction,
    required Duration throttleDuration,
  }) {
    final now = DateTime.now();
    if (_lastMessage == message &&
        _lastShownAt != null &&
        now.difference(_lastShownAt!) < throttleDuration) {
      
      return;
    }
    _lastShownAt = now;
    _lastMessage = message;

    final theme = Theme.of(context);
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        backgroundColor:
            error ? theme.colorScheme.error : theme.colorScheme.surfaceVariant,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 4),
        content: Text(
          message,
          style: TextStyle(
            color: error ? theme.colorScheme.onError : theme.colorScheme.onSurface,
            fontSize: 14,
          ),
        ),
        action: (actionLabel != null && onAction != null)
            ? SnackBarAction(
                label: actionLabel,
                onPressed: onAction,
                textColor: theme.colorScheme.primary,
              )
            : null,
      ),
    );
  }
}