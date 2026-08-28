import 'dart:async';
import 'package:flutter/material.dart';

import 'package:booking/services/network_service.dart';

class NetworkOverlay extends StatefulWidget {
  final Widget child;

  const NetworkOverlay({super.key, required this.child});

  @override
  State<NetworkOverlay> createState() => _NetworkOverlayState();
}

class _NetworkOverlayState extends State<NetworkOverlay> {
  final NetworkService _networkService = NetworkService();
  late final ValueNotifier<bool> _isConnectedNotifier;
  StreamSubscription<bool>? _subscription;

  @override
  void initState() {
    super.initState();
    _isConnectedNotifier = ValueNotifier<bool>(_networkService.hasConnection);
    _networkService.initialize();
    
    _subscription = _networkService.onConnectionChange.listen((isConnected) {
      _isConnectedNotifier.value = isConnected;
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _isConnectedNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Main app content - kept outside of status rebuilds
        widget.child,
        
        // Offline Banner
        ValueListenableBuilder<bool>(
          valueListenable: _isConnectedNotifier,
          builder: (context, isConnected, _) {
            return AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              top: isConnected ? -200 : 0, // Slide down when offline, up when online
              left: 0,
              right: 0,
              child: SafeArea(
                child: Material(
                  color: Colors.transparent,
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.redAccent,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.cloud_off_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                        SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            'You are offline. Some features may not work.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
