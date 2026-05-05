import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  NotificationService._();

  static final _plugin = FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: android);
    await _plugin.initialize(settings);
  }

  static Future<void> showBinAlert({
    required String binId,
    required String location,
    required double fillPercent,
  }) async {
    final isFull = fillPercent >= 100;
    final title = isFull ? 'Bin Full — Action Required' : 'Bin Almost Full';
    final body = isFull
        ? '$location ($binId) is full. Please empty it now.'
        : '$location ($binId) is at ${fillPercent.toStringAsFixed(0)}% — almost full.';

    await _plugin.show(
      binId.hashCode,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'bin_alerts',
          'Bin Alerts',
          channelDescription: 'Alerts when recycling bins are almost full or full',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
    );
  }

  static Future<void> showCreditAlert(double amount) async {
    await _plugin.show(
      amount.hashCode ^ DateTime.now().millisecond,
      'Wallet Credited',
      'GHS ${amount.toStringAsFixed(2)} has been paid to your Mobile Money.',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'wallet_credits',
          'Wallet Credits',
          channelDescription: 'Notifications when money is credited to your wallet',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
    );
  }
}
