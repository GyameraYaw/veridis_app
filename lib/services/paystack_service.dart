import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/paystack_config.dart';

class PaystackTransferException implements Exception {
  final String message;
  const PaystackTransferException(this.message);
  @override
  String toString() => message;
}

class PaystackService {
  static final PaystackService _instance = PaystackService._internal();
  factory PaystackService() => _instance;
  PaystackService._internal();

  Map<String, String> get _headers => {
        'Authorization': 'Bearer ${PaystackConfig.secretKey}',
        'Content-Type': 'application/json',
      };

  String _detectBankCode(String number) {
    final n = number;

    if (n.length < 3) {
      throw const PaystackTransferException(
          'Mobile number too short to detect network.');
    }

    final prefix = n.substring(0, 3);

    const mtn = ['024', '054', '055', '059'];
    const vodafone = ['020', '050'];
    const airtelTigo = ['026', '056', '027', '057'];

    if (mtn.contains(prefix)) return 'MTN';
    if (vodafone.contains(prefix)) return 'VOD';
    if (airtelTigo.contains(prefix)) return 'ATL';

    throw PaystackTransferException(
        'Unrecognised MoMo prefix "$prefix". '
        'Accepted prefixes: MTN (024/054/055/059), '
        'Vodafone (020/050), AirtelTigo (026/056/027/057).');
  }

  String _normaliseNumber(String number) {
    String n = number.replaceAll(' ', '');
    if (n.startsWith('+233')) return '0${n.substring(4)}';
    if (n.startsWith('233')) return '0${n.substring(3)}';
    return n;
  }

  Future<String> sendMoMoPayout({
    required String name,
    required String number,
    required double amountGhs,
  }) async {
    // ── Demo mode — skip real API call ───────────────────────────────────
    if (PaystackConfig.demoMode) {
      await Future.delayed(const Duration(seconds: 2)); // simulate network
      return 'TRF_DEMO_${DateTime.now().millisecondsSinceEpoch}';
    }

    final normalisedNumber = _normaliseNumber(number);
    final bankCode = _detectBankCode(normalisedNumber);

    // ── Step 1: Create transfer recipient ────────────────────────────────
    final recipientRes = await http
        .post(
          Uri.parse('${PaystackConfig.baseUrl}/transferrecipient'),
          headers: _headers,
          body: jsonEncode({
            'type': 'mobile_money',
            'name': name,
            'account_number': normalisedNumber,
            'bank_code': bankCode,
            'currency': 'GHS',
          }),
        )
        .timeout(const Duration(seconds: 15));

    final recipientBody = jsonDecode(recipientRes.body) as Map<String, dynamic>;

    if (recipientRes.statusCode < 200 || recipientRes.statusCode >= 300) {
      throw PaystackTransferException(
          recipientBody['message'] as String? ??
              'Failed to create transfer recipient.');
    }

    final recipientCode =
        recipientBody['data']?['recipient_code'] as String?;
    if (recipientCode == null) {
      throw const PaystackTransferException(
          'Paystack did not return a recipient_code.');
    }

    // ── Step 2: Initiate transfer ─────────────────────────────────────────
    final amountPesewas = (amountGhs * 100).round();

    final transferRes = await http
        .post(
          Uri.parse('${PaystackConfig.baseUrl}/transfer'),
          headers: _headers,
          body: jsonEncode({
            'source': 'balance',
            'amount': amountPesewas,
            'recipient': recipientCode,
            'currency': 'GHS',
          }),
        )
        .timeout(const Duration(seconds: 15));

    final transferBody = jsonDecode(transferRes.body) as Map<String, dynamic>;

    if (transferRes.statusCode < 200 || transferRes.statusCode >= 300) {
      throw PaystackTransferException(
          transferBody['message'] as String? ?? 'Transfer request failed.');
    }

    final status = transferBody['data']?['status'] as String?;
    if (status == 'failed') {
      throw PaystackTransferException(
          transferBody['message'] as String? ?? 'Transfer failed.');
    }

    // 'success' and 'pending' are both acceptable for MoMo
    final transferCode =
        transferBody['data']?['transfer_code'] as String?;
    if (transferCode == null) {
      throw const PaystackTransferException(
          'Paystack did not return a transfer_code.');
    }

    return transferCode;
  }
}
