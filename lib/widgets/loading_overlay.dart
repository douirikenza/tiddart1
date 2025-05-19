import 'package:flutter/material.dart';

class LoadingOverlay {
  final BuildContext _context;
  final String _message;
  OverlayEntry? _overlayEntry;

  LoadingOverlay._(this._context, this._message);

  static LoadingOverlay show(BuildContext context, String message) {
    final overlay = LoadingOverlay._(context, message);
    overlay._show();
    return overlay;
  }

  void _show() {
    _overlayEntry = OverlayEntry(
      builder: (context) => Material(
        color: Colors.black.withOpacity(0.5),
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  offset: const Offset(0, 2),
                  blurRadius: 4,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                Text(
                  _message,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );

    Overlay.of(_context).insert(_overlayEntry!);
  }

  void dismiss() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }
} 