import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:moneyvesto/core/constants/color.dart'; // Ditambahkan import AppColors
import 'package:moneyvesto/core/global_components/global_text.dart';
import 'package:intl/intl.dart'; // Untuk formatting angka jika diperlukan (opsional)

class FinanceSummaryCard extends StatefulWidget {
  final int pengeluaran;
  final int pemasukan;
  final int sisaSaldo;
  final String bulan;

  const FinanceSummaryCard({
    super.key,
    required this.pengeluaran,
    required this.pemasukan,
    required this.sisaSaldo,
    required this.bulan,
  });

  @override
  State<FinanceSummaryCard> createState() => _FinanceSummaryCardState();
}

class _FinanceSummaryCardState extends State<FinanceSummaryCard> {
  bool obscureNominal =
      false; // Defaultnya terlihat berdasarkan gambar referensi

  String _formatCurrency(int value) {
    // Menggunakan NumberFormat untuk format mata uang yang lebih baik dan lokal
    final formatter = NumberFormat.currency(
      locale: 'id_ID', // Sesuaikan dengan lokal Anda
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return formatter
        .format(value)
        .replaceAll(RegExp(r'\s+'), ' '); // Hapus spasi berlebih jika ada
  }

  @override
  Widget build(BuildContext context) {
    // Berdasarkan gambar referensi, kartu "Pendapatan" berwarna teal (primaryAccent)
    // Kartu "Pengeluaran" berwarna abu-abu (secondaryAccent)
    // Kartu ini adalah ringkasan, mari kita gunakan secondaryAccent sebagai dasar,
    // atau primaryAccent jika ingin menonjolkan aspek positif.
    // Untuk meniru gambar (IDR 8m di atas dengan warna hijau), kita bisa atur background ini.
    // Namun, karena ini card ringkasan, secondaryAccent lebih netral.
    // Jika kita ingin card ini mirip "Pendapatan" di gambar, gunakan AppColors.primaryAccent.
    // Mari kita coba AppColors.secondaryAccent agar berbeda dari tombol menu aktif.

    // Mengacu pada image_899b51.png, "Pendapatan" menggunakan warna hijau/teal.
    // Karena kartu ini bisa dianggap sebagai ringkasan total atau "Total Balance/Cashflow"
    // seperti pada gambar (IDR 8m dengan warna hijau), kita akan gunakan AppColors.primaryAccent.
    Color cardBackgroundColor =
        AppColors.primaryAccent; // Mirip kartu "Pendapatan" di gambar

    // Jika ingin lebih gelap seperti area "Adjust Balance" di gambar:
    // Color cardBackgroundColor = AppColors.secondaryAccent;

    return Container(
      decoration: BoxDecoration(
        color: cardBackgroundColor, // Warna latar card disesuaikan
        borderRadius: BorderRadius.circular(16.r),
      ),
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Berdasarkan gambar, bagian atas menampilkan "Total Balance" atau "Cashflow"
              // Bukan "Pengeluaran" secara eksplisit.
              GlobalText.medium(
                'Cashflow', // Diubah agar lebih umum seperti gambar
                color: AppColors.textLight,
                fontSize: 16.sp, // Disesuaikan
              ),
              GestureDetector(
                // Membuat bulan bisa diklik jika ada fungsionalitas
                onTap: () {
                  // Aksi saat bulan diklik, misal ganti bulan
                },
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 4.h,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.textLight.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: GlobalText.regular(
                    widget.bulan, // Bulan tetap dari prop
                    color: AppColors.textLight,
                    fontSize: 12.sp,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  setState(() {
                    obscureNominal = !obscureNominal;
                  });
                },
                child: Icon(
                  obscureNominal
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: AppColors.textLight,
                  size: 22.sp, // Disesuaikan
                ),
              ),
              SizedBox(width: 10.w),
              // Mengacu pada gambar, nominal utama besar dan berwarna putih/hijau muda
              GlobalText.semiBold(
                obscureNominal
                    ? 'Rp *********'
                    // Sisa saldo (cashflow) lebih relevan sebagai angka utama di sini
                    : _formatCurrency(widget.pemasukan - widget.pengeluaran),
                fontSize: 28.sp, // Disesuaikan
                color: AppColors.textLight,
              ),
            ],
          ),
          SizedBox(height: 20.h), // Jarak lebih besar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _infoCard(
                icon: Icons.arrow_downward_rounded, // Ikon Pemasukan
                iconColor:
                    AppColors
                        .textLight, // Warna ikon netral karena background sudah hijau
                title: 'Pemasukan',
                value: widget.pemasukan,
                backgroundColor: AppColors.textLight.withOpacity(
                  0.1,
                ), // Background sub-card
                titleColor: AppColors.textLight.withOpacity(0.8),
                valueColor: AppColors.textLight,
              ),
              SizedBox(width: 10.w), // Jarak antar info card
              _infoCard(
                icon: Icons.arrow_upward_rounded, // Ikon Pengeluaran
                iconColor: AppColors.textLight,
                title: 'Pengeluaran',
                value: widget.pengeluaran,
                backgroundColor: AppColors.textLight.withOpacity(0.1),
                titleColor: AppColors.textLight.withOpacity(0.8),
                valueColor: AppColors.textLight,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _infoCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required int value,
    required Color backgroundColor,
    required Color titleColor,
    required Color valueColor,
  }) {
    return Expanded(
      // Agar kedua card memiliki lebar yang sama
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: backgroundColor, // Warna latar sub-info card
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: iconColor,
              size: 18.sp,
            ), // Ukuran ikon disesuaikan
            SizedBox(width: 8.w),
            Expanded(
              // Agar teks tidak overflow
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GlobalText.regular(
                    title,
                    color: titleColor,
                    fontSize: 13.sp,
                  ), // Ukuran font disesuaikan
                  GlobalText.medium(
                    obscureNominal
                        ? 'Rp *******' // Bintang lebih sedikit untuk nominal lebih kecil
                        : _formatCurrency(value),
                    color: valueColor,
                    fontSize: 14.sp, // Ukuran font disesuaikan
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
