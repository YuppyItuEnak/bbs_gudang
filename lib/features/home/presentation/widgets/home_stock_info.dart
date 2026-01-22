import 'package:flutter/material.dart';

class HomeStockInfo extends StatelessWidget {
  final String count;
  final String label;
  final IconData icon;
  final Color iconColor;
  final VoidCallback? onTap; // Tambahkan parameter onTap

  const HomeStockInfo({
    super.key,
    required this.count,
    required this.label,
    required this.icon,
    required this.iconColor,
    this.onTap, // Inisialisasi di constructor
  });

  @override
  Widget build(BuildContext context) {
    // Gunakan InkWell agar ada efek visual saat ditekan (ripple effect)
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(
        8,
      ), // Menyesuaikan area klik agar rapi
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
        child: Row(
          mainAxisSize:
              MainAxisSize.min, // Agar luas area klik tidak berlebihan
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: Colors.white,
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  count,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  label,
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
