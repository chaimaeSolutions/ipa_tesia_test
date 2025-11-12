import 'package:flutter/widgets.dart';
import 'package:tesia_app/l10n/app_localizations.dart';
import 'package:tesia_app/services/kit_service_exception.dart';

String kitErrorToUserMessage(Object err, BuildContext context) {
  final loc = AppLocalizations.of(context)!;
  if (err is KitServiceException) {
    switch (err.code) {
      case 'network_error':
        return loc.networkError; 
      case 'request_timed_out':
        return loc.requestTimedOut;
      case 'kit_not_found':
        return loc.kitNotFound;
      case 'invalid_qr':
        return loc.invalidQr;
      case 'already_reserved':
        return loc.kitAlreadyReserved;
      case 'already_used':
        return loc.kitAlreadyUsed;
      case 'signup_failed':
        return loc.signupFailed;
      case 'link_failed':
        return loc.linkFailed;
      case 'server_error':
      default:
        return err.serverMessage?.toString().isNotEmpty == true
            ? '${loc.serverErrorShort}: ${err.serverMessage}'
            : loc.serverError;
    }
  }
  return loc.unexpectedError;
}
