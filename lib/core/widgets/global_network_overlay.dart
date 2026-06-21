import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lottie/lottie.dart';
import '../../features/dashboard/presentation/providers/network_provider.dart';

class GlobalNetworkOverlay extends StatelessWidget {
  final Widget child; 

  const GlobalNetworkOverlay({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    // 🌟 الحل الهندسي: لقد أزلنا الـ Directionality تماماً.
    // التطبيق الآن سيتنفس بحرية ويأخذ اتجاهه من MaterialApp تلقائياً.
    return Stack(
      children: [
        // 1. التطبيق (الشاشات)
        child,

        // 2. إشعار الإنترنت
        Consumer<NetworkProvider>(
          builder: (context, network, _) {
            if (network.state == NetworkState.normal) {
              return const SizedBox.shrink();
            }

            final isOffline = network.state == NetworkState.offline;

            return Positioned(
              top: 60, 
              left: 20,
              right: 20,
              child: Material(
                color: Colors.transparent, 
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeInOut,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: isOffline ? Colors.red.shade50 : Colors.green.shade50,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isOffline ? Colors.redAccent : Colors.green,
                      width: 1.5,
                    ),
                    boxShadow: const [
                      BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 5))
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 40,
                        height: 40,
                        child: Lottie.asset(
                          isOffline 
                              ? 'assets/lotties/no_internet.json' 
                              : 'assets/lotties/connected.json',
                          repeat: isOffline, 
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        isOffline ? 'core.network_offline'.tr() : 'core.network_online'.tr(),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isOffline ? Colors.red : Colors.green,
                        ),
                      ),
                    ],
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