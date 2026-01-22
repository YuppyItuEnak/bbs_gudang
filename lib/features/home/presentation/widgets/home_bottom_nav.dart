import 'package:flutter/material.dart';

class HomeBottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const HomeBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      // Notch margin diperbesar agar ada celah putih di sekitar tombol kuning
      shape: const CircularNotchedRectangle(),
      notchMargin: 10.0,
      clipBehavior: Clip.antiAlias,
      elevation: 20,
      color: Colors.white,
      shadowColor: Colors.black45,
      child: SizedBox(
        height: 70,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            // KIRI - ITEM HOME
            Expanded(
              child: InkWell(
                onTap: () => onTap(0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.home_rounded, // Icon Home Solid
                      size: 30,
                      color: currentIndex == 0
                          ? const Color(0xFF4CAF50)
                          : Colors.grey.shade400,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Home",
                      style: TextStyle(
                        fontSize: 12,
                        color: currentIndex == 0
                            ? const Color(0xFF4CAF50)
                            : Colors.grey.shade400,
                        fontWeight: currentIndex == 0
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // SPACER TENGAH (Penting: Lebar ini memberi ruang untuk FAB Kuning)
            const SizedBox(width: 90),

            // KANAN - ITEM PROFILE
            Expanded(
              child: InkWell(
                onTap: () => onTap(2), // UBAH INI JADI 1
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.person_outline_rounded,
                      size: 30,
                      color:
                          currentIndex ==
                              2 // UBAH INI JADI 1
                          ? const Color(0xFF4CAF50)
                          : Colors.grey.shade400,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Profile",
                      style: TextStyle(
                        fontSize: 12,
                        color:
                            currentIndex ==
                                2 // UBAH INI JADI 1
                            ? const Color(0xFF4CAF50)
                            : Colors.grey.shade400,
                        fontWeight: currentIndex == 2
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
