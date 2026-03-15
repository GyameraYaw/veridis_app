import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../services/session_service.dart';
import '../theme/app_theme.dart';
import '../widgets/responsive_layout.dart';
import 'active_session_screen.dart';

class QrScanScreen extends StatefulWidget {
  const QrScanScreen({super.key});

  @override
  State<QrScanScreen> createState() => _QrScanScreenState();
}

class _QrScanScreenState extends State<QrScanScreen> {
  bool _scanned = false;
  final MobileScannerController _controller = MobileScannerController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Parses veridis://session?machine=X&token=Y and starts a session.
  bool _handleQrCode(String raw) {
    try {
      final uri = Uri.parse(raw);
      if (uri.scheme != 'veridis' || uri.host != 'session') return false;
      final machineId = uri.queryParameters['machine'];
      final token = uri.queryParameters['token'];
      if (machineId == null || machineId.isEmpty) return false;
      if (token == null || token.isEmpty) return false;
      // TODO: validate token against Firebase in production
      SessionService().startSession(machineId);
      return true;
    } catch (_) {
      return false;
    }
  }

  void _onDetect(BarcodeCapture capture) {
    if (_scanned) return;
    final raw = capture.barcodes.firstOrNull?.rawValue;
    if (raw == null) return;
    if (_handleQrCode(raw)) {
      setState(() => _scanned = true);
      _navigateToSession();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('Invalid QR code. Please scan a VERIDIS machine code.'),
          backgroundColor: AppColors.errorRed,
        ),
      );
    }
  }

  void _navigateToSession() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const ActiveSessionScreen()),
    );
  }

  void _simulateScan() {
    final testQr =
        'veridis://session?machine=MACHINE_001&token=${DateTime.now().millisecondsSinceEpoch}';
    if (_handleQrCode(testQr)) {
      _navigateToSession();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveWrapper(
      child: Scaffold(
        appBar: AppBar(title: const Text('Scan Machine QR')),
        body: Stack(
          children: [
            // Camera view
            MobileScanner(
              controller: _controller,
              onDetect: _onDetect,
            ),

            // Dark overlay with scan window cutout hint
            Column(
              children: [
                Expanded(
                  flex: 2,
                  child: Container(color: Colors.black54),
                ),
                Row(
                  children: [
                    Expanded(child: Container(color: Colors.black54)),
                    Container(
                      width: 240,
                      height: 240,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: AppColors.freshGreen,
                          width: 3,
                        ),
                        borderRadius: BorderRadius.circular(AppRadius.card),
                      ),
                    ),
                    Expanded(child: Container(color: Colors.black54)),
                  ],
                ),
                Expanded(
                  flex: 3,
                  child: Container(
                    color: Colors.black54,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Point camera at the\nmachine QR code',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        OutlinedButton.icon(
                          onPressed: _simulateScan,
                          icon: const Icon(
                            Icons.developer_mode,
                            color: AppColors.freshGreen,
                          ),
                          label: const Text(
                            'Simulate QR Scan (Testing)',
                            style: TextStyle(color: AppColors.freshGreen),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(
                              color: AppColors.freshGreen,
                              width: 1.5,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(AppRadius.chip),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
