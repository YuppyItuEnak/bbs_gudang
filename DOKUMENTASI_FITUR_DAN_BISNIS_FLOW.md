# Dokumentasi Fitur & Bisnis Flow Aplikasi bbs_gudang (MBG QL App)

Dokumen ini menjelaskan seluruh modul fitur yang ada di aplikasi beserta alur bisnis (business flow) end-to-end.

- **Platform:** Flutter (Dart)
- **Backend:** REST API `https://server.qqltech.com:7180/api`
- **Tombol kunci arsitektur:** `Pages/Widgets → Provider (ChangeNotifier) → Repository (HTTP) → REST API`
- **Autentikasi:** JWT (Bearer) + SharedPreferences, cek kedaluwarsa via `jwt_decoder`

---

## 1. Daftar Fitur per Modul

| Modul | Fungsi | Pengguna |
|---|---|---|
| **Auth** | Login/logout dengan JWT, cek sesi kedaluwarsa, cek izin `userMobile`, ganti password | Semua user |
| **Home/Dashboard** | Menu shortcut, kartu stok overstock/understock, notifikasi (5 terbaru), riwayat transaksi gabungan + pencarian | Semua user |
| **Quotation** | Buat/edit penawaran penjualan: pilih grup produk, produk, customer + alamat, term of payment (ToP), simpan header + detail | Sales |
| **Penerimaan Barang (PB)** | Terima barang dari supplier berdasarkan Purchase Order: pilih PO, isi info header, pilih item + qty, validasi, simpan → stok masuk | Staff gudang |
| **Pengeluaran Barang (SJ/DO)** | Buat Surat Jalan/Delivery Order dari Delivery Plan yang siap kirim: pilih DP, pilih item, generate No. DO, simpan → stok keluar | Staff gudang |
| **Kartu Stock** | Rekap buku stok per item (mutasi per transaksi) + laporan Stock per Warehouse | Supervisor/audit |
| **Stock Opname** | Hitung fisik stok: buat/edit laporan opname + detail + laporan | Staff gudang |
| **Stock Adjustment** | Sesuaikan stok dari hasil opname yang sudah dipost (selisih susut/menang) | Supervisor |
| **Transfer Warehouse** | Pindah stok antar gudang (pilih company → gudang asal → gudang tujuan → item + qty) | Staff gudang |
| **List Item** | Katalog master barang (`m_item`) dengan filter + stok per gudang, tambah barang | Admin |
| **Notification** | Notifikasi unread (maks 5) dari backend | Semua user |
| **Profile** | Foto profil, info user, logout | Semua user |

### Penjelasan Singkat per Fitur

1. **Auth**
   - Endpoint `POST /auth/login` dengan `{username, password}` → mengembalikan `{status, message, data.user, token}`.
   - Token JWT disimpan di SharedPreferences (`auth_token`, `auth_user`).
   - Setelah login, aplikasi mengambil `unit_bussiness_id` (company) untuk kebutuhan dokumen.
   - Cek izin: jika `userMobile != true`, akses ditolak.
   - Logout menghapus token dan kembali ke halaman Login.

2. **Home/Dashboard**
   - Halaman utama setelah login (IndexedStack + bottom nav Home/Profile).
   - Menampilkan greeting, menu shortcut (Penerimaan, Kartu Stock, dll.), kartu stok overstock/understock, notifikasi unread (maks 5), dan panel riwayat gudang.
   - Riwayat gudang menggabungkan 4 jenis transaksi: Pengeluaran (SJ), Penerimaan (PB), Stock Adjustment, dan Stock Opname — diurutkan berdasarkan tanggal dan bisa dicari berdasarkan kode dokumen.

3. **Quotation**
   - Fitur penawaran penjualan (`t_sales_quotation`).
   - List dengan pagination + filter (keyword, customer, status, rentang tanggal).
   - Form create/edit memakai pemilih: grup produk (`m_item_division`), produk (`m_item`), customer (`m_customer` + alamat kirim), dan ToP (`m_top_sales_quotation`).
   - Dikunci oleh id sales yang sedang login.

4. **Penerimaan Barang (PB)**
   - Penerimaan stok dari supplier berdasarkan PO.
   - Dukungan list (pagination/filter), detail, create, edit/post.
   - Endpoint utama: `getAvailablePos`, `with-details`, `generateCode`, `checkStatusPurchaseOrder`, `insertInventory`.

5. **Pengeluaran Barang (SJ/DO)**
   - Pengiriman stok keluar (Surat Jalan / Delivery Order).
   - Dibuat dari Delivery Plan yang siap (`status=4` dan `sj_used=false`).
   - Endpoint utama: `fn/t_surat_jalan/createSuratJalanv3`, `with-details/{id}`, `generateCode`.

6. **Kartu Stock**
   - Buku stok dari `t_inventory_ledger` — menampilkan mutasi stok per item.
   - Memiliki filter warehouse dan rentang tanggal (`filter_kartu_stock.dart`).
   - Juga menampilkan laporan **Stock Warehouse** per gudang.

7. **Stock Opname**
   - Laporan perhitungan fisik stok vs sistem (`t_inventory_s_opname`).
   - List dengan filter tanggal/status/search, halaman detail/report, create (auto-generate kode opname), dan edit.

8. **Stock Adjustment**
   - Penyesuaian stok (`t_inventory_s_adjustment`) yang berawal dari opname yang sudah dipost.
   - Memuat item opname, memperkaya dengan master item, menghitung selisih qty.
   - Cek `checkCanSubmit` (kelayakan approval) sebelum submit.

9. **Transfer Warehouse**
   - Pemindahan stok antar gudang (`t_inventory_transfer_warehouse`).
   - Memuat daftar company (`fn/user_detail/getUserCompanies`) dan warehouse (`m_warehouse`).
   - Simpan via `fn/t_inventory_transfer_warehouse/saveTransaction`.

10. **List Item**
    - Katalog master barang (`m_item`) dengan pagination + filter (kode/nama/status/tipe).
    - Menampilkan stok per gudang (`fn/t_inventory_ledger/getItemStock`).

11. **Notification**
    - Mengambil maksimal 5 notifikasi belum dibaca (`fn/notifications/getFiveUnreadNotification`).
    - Badge count + bottom-sheet daftar notifikasi.

12. **Profile**
    - Foto profil (ambil dari galeri/kamera via `image_picker`), info identitas user, dan konfirmasi logout.

---

## 2. Bisnis Flow

### 2.1 Alur End-to-End

```
                    ┌───────────────────────────────────────────────┐
                    │             ALUR BISNIS GUDANG BBS             │
                    └───────────────────────────────────────────────┘

 [SISI SALES / STOK KELUAR]
   Quotation (penawaran) ──terkait──► Sales Order (SO)
        (modul quotation)                    │
                                            ▼
                                  Delivery Plan (DP)
                                    (status=4, sj_used=false)
                                            │
                                            ▼
       Pengeluaran Barang (Surat Jalan/DO)  ──►  STOK GUDANG BERKURANG
       (pilih DP ─ muat item ─ generate No.DO ─ createSuratJalanv3)

 [SISI PEMBELIAN / STOK MASUK]
   Purchase Order (PO) ───────────────────────────► dikirim supplier
                                            │
                                            ▼
       Penerimaan Barang (PB)  ──►  STOK GUDANG BERTAMBAH
       (pilih PO ─ isi header: supplier, SJ, invoice,
        no polisi, supir ─ pilih item+qty ─ validasi
        tolerance PO ─ checkStatusPO ─ insertInventory)

 [PENGENDALIAN & KOREKSI STOK]
   Stock Opname (hitung fisik vs sistem)
        │   hasil opname dipost
        ▼
   Stock Adjustment (selisih positif/negatif)  ──► stok disesuaikan
   Transfer Warehouse (antar gudang)            ──► stok pindah

 [PELAPORAN & MONITORING]
   Kartu Stock (buku mutasi stok per item) + Stock Warehouse report
   Home Dashboard: overstock/understock + riwayat semua transaksi
```

### 2.2 Detail Alur per Modul Inti

#### A. Sisi Masuk — Penerimaan Barang (PB)

1. User membuka form PB → memilih **PO yang tersedia** (endpoint `getAvailablePos`).
2. Sistem memuat detail PO/PR + **item outstanding** (sisa yang belum diterima), lalu generate **No. PB** otomatis (`generateCode`).
3. User mengisi header: Company, Warehouse, Supplier, No. PR, Tgl Surat Jalan, No. SJ Supplier, No. Invoice, No. Polisi, Nama Supir.
4. User memilih item & qty yang diterima; sistem menghitung `qty_outstanding = qty pesanan − qty sudah diterima` dan memvalidasi terhadap **excess tolerance** PO.
5. Sistem memanggil `checkStatusPurchaseOrder` (server memvalidasi akhir), lalu `insertInventory` → **stok gudang bertambah**.
6. Ada mode **edit/post** untuk PB yang belum diposting.

#### B. Sisi Keluar — Pengeluaran Barang (Surat Jalan / DO)

1. Ambil daftar **Delivery Plan** yang siap kirim (`status=4` dan `sj_used=false`).
2. Pilih DP → sistem memuat header (customer, alamat, kendaraan) + baris item dari SO terkait.
3. Generate **No. DO** (`generateCode` dengan `menu_id` khusus surat jalan).
4. User isi info kirim (tanggal kirim, ekspedisi, catatan) + pilih item & qty.
5. Simpan via `fn/t_surat_jalan/createSuratJalanv3` → server cek stok cukup (`insufficient`), batas kredit (`credit limit`), lalu **stok gudang berkurang**.

#### C. Koreksi Stok

1. **Stock Opname**: user hitung fisik barang → simpan laporan opname (berisi stok sistem vs stok fisik), bisa edit.
2. **Stock Adjustment**: dari opname yang dipost, sistem memuat item opname, menghitung selisih, cek `checkCanSubmit` (kelayakan approval), lalu membuat penyesuaian stok.
3. **Transfer Warehouse**: pilih company → gudang asal → gudang tujuan → pilih item & qty → `saveTransaction`.

#### D. Monitoring & Pelaporan

- **Kartu Stock** & **Stock Warehouse**: rekap mutasi per item/gudang (via `t_inventory_ledger`).
- **Dashboard**: menampilkan overstock/understock + feed riwayat gabungan (PB, SJ, adjustment, opname) yang bisa dicari berdasarkan kode dokumen.

---

## 3. Catatan Teknis

- Semua request memakai header `Authorization: Bearer <JWT>` + `Content-Type: application/json`.
- Respons backend berbentuk `{status, message, data, pagination}`.
- Nomor dokumen digenerate backend dengan `menu_id` tetap per modul (misal surat jalan: `b5d79799-51d1-4089-bc2e-71916b00200f`).
- Error validasi backend berbentuk `{errors: {field: [pesan]}}`; aplikasi sudah memetakan nama field teknis ke label Indonesia di beberapa repository.

*Dokumen ini dapat diperbarui seiring perkembangan fitur.*