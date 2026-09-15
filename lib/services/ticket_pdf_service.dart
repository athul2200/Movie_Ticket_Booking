import 'dart:io';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:printing/printing.dart';
import 'package:booking/models/booking_model.dart';
import 'package:booking/core/utils/ist_time_utils.dart';

/// ============================================================
/// Ticket PDF Service — Generates professional PDF movie tickets
/// and handles Android storage saving.
/// ============================================================

class TicketPdfResult {
  final bool success;
  final String filePath;
  final String? errorMessage;

  TicketPdfResult({
    required this.success,
    required this.filePath,
    this.errorMessage,
  });
}

class TicketPdfService {
  /// Generates and saves a PDF ticket for the given [booking].
  static Future<TicketPdfResult> downloadTicket(BookingModel booking) async {
    try {
      // 1. Request permissions if needed on Android
      if (Platform.isAndroid) {
        await _requestStoragePermissions();
      }

      // 2. Load movie poster image if available
      pw.ImageProvider? posterImage = await _loadPosterImage(booking.moviePosterUrl);

      // 3. Format current IST timestamp
      final istNow = IstTimeUtils.nowInIst();
      final istFormatted = _formatIstDateTime(istNow);

      // 4. Build PDF document
      final pdf = pw.Document();

      // Theme colors matching Movix app theme
      final primaryColor = PdfColor.fromHex('#E50914'); // Red accent
      final bgDark = PdfColor.fromHex('#0F0F14');      // Deep navy/black
      final cardBg = PdfColor.fromHex('#1B1C24');      // Card background
      final textWhite = PdfColors.white;
      final textMuted = PdfColor.fromHex('#9CA3AF');   // Light grey text
      final borderClr = PdfColor.fromHex('#2D2E3A');

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          build: (pw.Context context) {
            return pw.Container(
              decoration: pw.BoxDecoration(
                color: bgDark,
                borderRadius: pw.BorderRadius.circular(16),
                border: pw.Border.all(color: primaryColor, width: 2),
              ),
              padding: const pw.EdgeInsets.all(24),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                mainAxisSize: pw.MainAxisSize.min,
                children: [
                  // ── HEADER ──
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            'Movix',
                            style: pw.TextStyle(
                              color: primaryColor,
                              fontSize: 26,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                          pw.SizedBox(height: 2),
                          pw.Text(
                            'OFFICIAL E-TICKET',
                            style: pw.TextStyle(
                              color: textMuted,
                              fontSize: 10,
                              fontWeight: pw.FontWeight.bold,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ],
                      ),
                      pw.Container(
                        padding: const pw.EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: pw.BoxDecoration(
                          color: primaryColor,
                          borderRadius: pw.BorderRadius.circular(6),
                        ),
                        child: pw.Text(
                          'CONFIRMED',
                          style: pw.TextStyle(
                            color: textWhite,
                            fontSize: 12,
                            fontWeight: pw.FontWeight.bold,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ),
                    ],
                  ),

                  pw.SizedBox(height: 20),
                  pw.Divider(color: borderClr, thickness: 1),
                  pw.SizedBox(height: 20),

                  // ── MOVIE BANNER & DETAILS ──
                  pw.Container(
                    padding: const pw.EdgeInsets.all(16),
                    decoration: pw.BoxDecoration(
                      color: cardBg,
                      borderRadius: pw.BorderRadius.circular(12),
                    ),
                    child: pw.Row(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        // Poster image thumbnail
                        if (posterImage != null)
                          pw.ClipRRect(
                            horizontalRadius: 8,
                            verticalRadius: 8,
                            child: pw.Image(
                              posterImage,
                              width: 85,
                              height: 120,
                              fit: pw.BoxFit.cover,
                            ),
                          )
                        else
                          pw.Container(
                            width: 85,
                            height: 120,
                            decoration: pw.BoxDecoration(
                              color: borderClr,
                              borderRadius: pw.BorderRadius.circular(8),
                            ),
                            child: pw.Center(
                              child: pw.Text(
                                'MOVIX',
                                style: pw.TextStyle(
                                  color: textMuted,
                                  fontSize: 12,
                                  fontWeight: pw.FontWeight.bold,
                                ),
                              ),
                            ),
                          ),

                        pw.SizedBox(width: 16),

                        // Movie Info Column
                        pw.Expanded(
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Container(
                                padding: const pw.EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: pw.BoxDecoration(
                                  color: PdfColor(primaryColor.red, primaryColor.green, primaryColor.blue, 0.2),
                                  borderRadius: pw.BorderRadius.circular(4),
                                ),
                                child: pw.Text(
                                  booking.experience.toUpperCase(),
                                  style: pw.TextStyle(
                                    color: primaryColor,
                                    fontSize: 9,
                                    fontWeight: pw.FontWeight.bold,
                                    letterSpacing: 0.8,
                                  ),
                                ),
                              ),
                              pw.SizedBox(height: 8),
                              pw.Text(
                                booking.movieTitle,
                                style: pw.TextStyle(
                                  color: textWhite,
                                  fontSize: 20,
                                  fontWeight: pw.FontWeight.bold,
                                ),
                              ),
                              pw.SizedBox(height: 6),
                              pw.Text(
                                booking.cinema,
                                style: pw.TextStyle(
                                  color: textMuted,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  pw.SizedBox(height: 20),

                  // ── TICKET INFO GRID ──
                  pw.Container(
                    padding: const pw.EdgeInsets.all(16),
                    decoration: pw.BoxDecoration(
                      color: cardBg,
                      borderRadius: pw.BorderRadius.circular(12),
                      border: pw.Border.all(color: borderClr),
                    ),
                    child: pw.Column(
                      children: [
                        pw.Row(
                          children: [
                            _buildInfoCell('DATE', booking.date, textMuted, textWhite),
                            _buildInfoCell('SHOW TIME', booking.time, textMuted, textWhite),
                          ],
                        ),
                        pw.SizedBox(height: 16),
                        pw.Row(
                          children: [
                            _buildInfoCell('CINEMA / THEATRE', booking.cinema, textMuted, textWhite),
                            _buildInfoCell('EXPERIENCE', booking.experience, textMuted, primaryColor),
                          ],
                        ),
                        pw.SizedBox(height: 16),
                        if (booking.screen.isNotEmpty) ...[
                          pw.Row(
                            children: [
                              _buildInfoCell('SCREEN', booking.screen, textMuted, textWhite),
                              _buildInfoCell('', '', textMuted, textWhite),
                            ],
                          ),
                          pw.SizedBox(height: 16),
                        ],
                        pw.Row(
                          children: [
                            _buildInfoCell('SEATS', booking.seatsFormatted, textMuted, primaryColor),
                            _buildInfoCell('NO. OF TICKETS', '${booking.seats.length} Ticket(s)', textMuted, textWhite),
                          ],
                        ),
                      ],
                    ),
                  ),

                  pw.SizedBox(height: 20),

                  // ── QR CODE & BOOKING ID ROW ──
                  pw.Container(
                    padding: const pw.EdgeInsets.all(16),
                    decoration: pw.BoxDecoration(
                      color: cardBg,
                      borderRadius: pw.BorderRadius.circular(12),
                      border: pw.Border.all(color: borderClr),
                    ),
                    child: pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: pw.CrossAxisAlignment.center,
                      children: [
                        pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text(
                              'BOOKING ID',
                              style: pw.TextStyle(
                                color: textMuted,
                                fontSize: 10,
                                fontWeight: pw.FontWeight.bold,
                                letterSpacing: 1.0,
                              ),
                            ),
                            pw.SizedBox(height: 4),
                            pw.Text(
                              booking.id,
                              style: pw.TextStyle(
                                color: textWhite,
                                fontSize: 16,
                                fontWeight: pw.FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                            pw.SizedBox(height: 12),
                            pw.Text(
                              'TOTAL AMOUNT PAID',
                              style: pw.TextStyle(
                                color: textMuted,
                                fontSize: 10,
                                fontWeight: pw.FontWeight.bold,
                                letterSpacing: 1.0,
                              ),
                            ),
                            pw.SizedBox(height: 4),
                            pw.Text(
                              'INR ${booking.totalAmount.toStringAsFixed(2)}',
                              style: pw.TextStyle(
                                color: textWhite,
                                fontSize: 18,
                                fontWeight: pw.FontWeight.bold,
                              ),
                            ),
                            pw.SizedBox(height: 10),
                            pw.Text(
                              'Booked on: $istFormatted',
                              style: pw.TextStyle(
                                color: textMuted,
                                fontSize: 9,
                              ),
                            ),
                          ],
                        ),

                        // QR Code Widget for booking ID
                        pw.Container(
                          padding: const pw.EdgeInsets.all(8),
                          decoration: pw.BoxDecoration(
                            color: PdfColors.white,
                            borderRadius: pw.BorderRadius.circular(8),
                          ),
                          child: pw.BarcodeWidget(
                            barcode: pw.Barcode.qrCode(),
                            data: booking.id,
                            width: 90,
                            height: 90,
                          ),
                        ),
                      ],
                    ),
                  ),

                  pw.SizedBox(height: 20),

                  // ── IMPORTANT INFORMATION ──
                  pw.Container(
                    padding: const pw.EdgeInsets.all(12),
                    decoration: pw.BoxDecoration(
                      color: cardBg,
                      borderRadius: pw.BorderRadius.circular(8),
                    ),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'IMPORTANT INFORMATION',
                          style: pw.TextStyle(
                            color: primaryColor,
                            fontSize: 10,
                            fontWeight: pw.FontWeight.bold,
                            letterSpacing: 1.0,
                          ),
                        ),
                        pw.SizedBox(height: 4),
                        pw.Text(
                          '• Please arrive at least 15 minutes before showtime.\n'
                          '• Present this QR code or Booking ID at the theatre entrance for scanning.\n'
                          '• All sales are final in accordance with cinema cancellation policies.',
                          style: pw.TextStyle(
                            color: textMuted,
                            fontSize: 9,
                            lineSpacing: 2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      );

      // Save file to device
      final pdfBytes = await pdf.save();
      final sanitizedMovie = booking.movieTitle
          .replaceAll(RegExp(r'[^\w\s-]'), '')
          .trim()
          .replaceAll(RegExp(r'\s+'), '_');
      final fileName = '${sanitizedMovie}_Ticket_${booking.id}.pdf';

      final savedFile = await _savePdfToStorage(pdfBytes, fileName);

      return TicketPdfResult(
        success: true,
        filePath: savedFile.path,
      );
    } catch (e) {
      return TicketPdfResult(
        success: false,
        filePath: '',
        errorMessage: e.toString(),
      );
    }
  }

  /// Helper cell for info grid
  static pw.Widget _buildInfoCell(
    String label,
    String value,
    PdfColor labelColor,
    PdfColor valueColor,
  ) {
    return pw.Expanded(
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            label,
            style: pw.TextStyle(
              color: labelColor,
              fontSize: 9,
              fontWeight: pw.FontWeight.bold,
              letterSpacing: 0.8,
            ),
          ),
          pw.SizedBox(height: 3),
          pw.Text(
            value,
            style: pw.TextStyle(
              color: valueColor,
              fontSize: 13,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  /// Request Android storage permissions if needed
  static Future<void> _requestStoragePermissions() async {
    try {
      if (Platform.isAndroid) {
        final status = await Permission.storage.status;
        if (status.isDenied) {
          await Permission.storage.request();
        }
      }
    } catch (_) {}
  }

  /// Load poster image from Network, Asset, or Local File safely
  static Future<pw.ImageProvider?> _loadPosterImage(String posterUrl) async {
    if (posterUrl.isEmpty) return null;
    try {
      if (posterUrl.startsWith('http://') || posterUrl.startsWith('https://')) {
        return await networkImage(posterUrl);
      } else if (posterUrl.startsWith('assets/')) {
        final bytes = await rootBundle.load(posterUrl);
        return pw.MemoryImage(bytes.buffer.asUint8List());
      } else {
        final file = File(posterUrl);
        if (await file.exists()) {
          final bytes = await file.readAsBytes();
          return pw.MemoryImage(bytes);
        }
      }
    } catch (_) {}
    return null;
  }

  /// Save PDF bytes to Android public Downloads or fallback directory
  static Future<File> _savePdfToStorage(Uint8List bytes, String fileName) async {
    Directory? targetDir;

    if (Platform.isAndroid) {
      // Primary target: /storage/emulated/0/Download
      final downloadDir = Directory('/storage/emulated/0/Download');
      if (await downloadDir.exists()) {
        try {
          final targetFile = File('${downloadDir.path}/$fileName');
          await targetFile.writeAsBytes(bytes, flush: true);
          return targetFile;
        } catch (_) {
          // If direct write fails due to Android Scoped Storage, try external storage
        }
      }

      targetDir = await getExternalStorageDirectory();
    } else {
      targetDir = await getDownloadsDirectory();
    }

    targetDir ??= await getApplicationDocumentsDirectory();

    final file = File('${targetDir.path}/$fileName');
    await file.writeAsBytes(bytes, flush: true);
    return file;
  }

  /// Format DateTime into standard IST string representation (e.g. "15 Sep 2026, 11:45 PM IST")
  static String _formatIstDateTime(DateTime dt) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    final day = dt.day.toString().padLeft(2, '0');
    final month = months[dt.month - 1];
    final year = dt.year;

    int hour = dt.hour;
    final minute = dt.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    hour = hour % 12;
    if (hour == 0) hour = 12;

    final timeStr = '${hour.toString().padLeft(2, '0')}:$minute $period';
    return '$day $month $year, $timeStr IST';
  }
}
