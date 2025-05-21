import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:moneyvesto/core/global_components/global_text.dart';

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
  bool obscureNominal = true;

  String _formatCurrency(int value) {
    return value.toString().replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (match) => '.',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF002366),
        borderRadius: BorderRadius.circular(16.r),
      ),
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Bagian atas: Pengeluaran dan Bulan
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GlobalText.medium(
                'Pengeluaran',
                color: Colors.white,
                fontSize: 18.sp,
              ),
              GlobalText.regular(
                'Bulan ${widget.bulan}',
                color: Colors.white,
                fontSize: 12.sp,
              ),
            ],
          ),
          SizedBox(height: 8.h),

          /// Nominal + Toggle Eye
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  setState(() {
                    obscureNominal = !obscureNominal;
                  });
                },
                child: Icon(
                  obscureNominal ? Icons.visibility_off : Icons.visibility,
                  color: Colors.white,
                  size: 20.sp,
                ),
              ),
              SizedBox(width: 8.w),
              GlobalText.semiBold(
                obscureNominal
                    ? 'Rp. *********'
                    : 'Rp. ${_formatCurrency(widget.pengeluaran)}',
                fontSize: 30.sp,
                color: Colors.white,
              ),
            ],
          ),
          SizedBox(height: 16.h),

          /// Bagian bawah: Pemasukan dan Sisa Saldo
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _infoCard(
                icon: Icons.arrow_downward,
                iconColor: Colors.greenAccent,
                title: 'Pemasukan',
                value: widget.pemasukan,
              ),
              _infoCard(
                icon: Icons.attach_money,
                iconColor: Colors.white,
                title: 'Sisa Saldo',
                value: widget.sisaSaldo,
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
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 20.sp),
          SizedBox(width: 6.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GlobalText.regular(title, color: Colors.white, fontSize: 14.sp),
              GlobalText.medium(
                obscureNominal
                    ? 'Rp. **********'
                    : 'Rp. ${_formatCurrency(value)}',
                color: Colors.white,
                fontSize: 15.sp,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
