import 'package:flutter/material.dart';

class TmbhPengeluaranInputField extends StatelessWidget {
  final String label;
  final String hint;
  final bool isDropdown;
  final IconData? suffixIcon;
  final bool enabled;
  final Color? fillColor;
  final int maxLines;
  final TextEditingController? controller; // Tambahkan controller

  const TmbhPengeluaranInputField({
    super.key,
    required this.label,
    required this.hint,
    this.isDropdown = false,
    this.suffixIcon,
    this.enabled = true,
    this.fillColor,
    this.maxLines = 1,
    this.controller, // Masukkan ke constructor
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 15, bottom: 8),
          child: Text(
            label,
            style: const TextStyle(color: Colors.grey, fontSize: 13),
          ),
        ),
        if (isDropdown)
          // Untuk Dropdown, biasanya menggunakan InkWell untuk trigger Picker
          InkWell(
            onTap: enabled
                ? () {
                    /* Logika buka picker/bottom sheet */
                  }
                : null,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
              decoration: BoxDecoration(
                color: enabled ? Colors.transparent : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(hint, style: const TextStyle(fontSize: 14)),
                  const Icon(Icons.arrow_drop_down, color: Colors.grey),
                ],
              ),
            ),
          )
        else
          TextField(
            controller: controller, // Hubungkan controller di sini
            enabled: enabled,
            maxLines: maxLines,
            style: const TextStyle(fontSize: 14),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(color: Colors.black38, fontSize: 14),
              suffixIcon: suffixIcon != null
                  ? Icon(suffixIcon, size: 20)
                  : null,
              filled: fillColor != null || !enabled,
              fillColor: enabled ? fillColor : Colors.grey.shade100,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 15,
                vertical: 12,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.grey.shade200),
              ),
            ),
          ),
      ],
    );
  }
}
