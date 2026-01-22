import 'package:flutter/material.dart';

class HomeHistorySection extends StatelessWidget {
  final ScrollController scrollController;

  const HomeHistorySection({super.key, required this.scrollController});

  @override
  Widget build(BuildContext context) {
    // ... data dummy tetap sama ...
    final List<Map<String, String>> historyData = [
      {"code": "TW-250101-0001", "date": "04 Mei 2023", "type": "TW"},
      {"code": "LPB-250101-0001", "date": "03 Mei 2023", "type": "LPB"},
      {"code": "SO-250101-0001", "date": "02 Mei 2023", "type": "SO"},
      {"code": "TW-250101-0002", "date": "01 Mei 2023", "type": "TW"},
      {"code": "LPB-250101-0002", "date": "30 April 2023", "type": "LPB"},
      {"code": "TW-250101-0003", "date": "29 April 2023", "type": "TW"},
      {"code": "SO-250101-0002", "date": "28 April 2023", "type": "SO"},
      {"code": "LPB-250101-0003", "date": "27 April 2023", "type": "LPB"},
    ];

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 10, spreadRadius: 1),
        ],
      ),
      child: Column(
        children: [
          // --- WRAPPER UNTUK HANDLE DRAG ---
          // SingleChildScrollView mini ini memungkinkan area header ikut merespon drag
          SingleChildScrollView(
            controller: scrollController,
            child: Column(
              children: [
                const SizedBox(height: 12),
                // Garis Abu-abu (Handle)
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Histori Gudang",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton(
                        onPressed: () {},
                        child: Text(
                          "Lihat Semua",
                          style: TextStyle(
                            color: Colors.blue[400],
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Search Bar (Tetap di Column agar tidak scroll, tapi tidak merespon drag sheet)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Search",
                hintStyle: TextStyle(color: Colors.grey[400]),
                prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[100],
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          const SizedBox(height: 15),

          // --- LIST DATA (RESPON DRAG & SCROLL) ---
          Expanded(
            child: ListView.builder(
              controller: scrollController, // Controller yang sama
              physics: const ClampingScrollPhysics(),
              padding: const EdgeInsets.only(bottom: 120),
              itemCount: historyData.length,
              itemBuilder: (context, index) {
                final item = historyData[index];
                Color iconColor = item['type'] == 'TW'
                    ? Colors.blue
                    : (item['type'] == 'LPB' ? Colors.green : Colors.redAccent);

                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: iconColor.withOpacity(0.1),
                    child: Icon(
                      Icons.assignment_outlined,
                      color: iconColor,
                      size: 20,
                    ),
                  ),
                  title: Text(
                    item['code']!,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  subtitle: Text(item['date']!),
                  trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
