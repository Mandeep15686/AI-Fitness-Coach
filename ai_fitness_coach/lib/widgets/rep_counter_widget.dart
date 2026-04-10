import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/constants/colors.dart';

class RepCounterWidget extends StatelessWidget {
  final int repCount;
  final String exerciseType;
  final double formScore;

  const RepCounterWidget({
    super.key,
    required this.repCount,
    required this.exerciseType,
    required this.formScore,
  });

  @override
  Widget build(BuildContext context) {
    final color = AppColors.exerciseColor(exerciseType);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: const BoxDecoration(
        color: AppColors.bgSurface,
        border: Border(top: BorderSide(color: AppColors.bgCard, width: 1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text('$repCount', style: GoogleFonts.barlow(
              fontSize: 52, fontWeight: FontWeight.w900, color: color, height: 1,
            )),
            Text('REPS', style: GoogleFonts.barlow(
              fontSize: 11, letterSpacing: 3, color: AppColors.textSecondary, fontWeight: FontWeight.w600,
            )),
          ]),
          Container(width: 1, height: 50, color: AppColors.bgCard),
          Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            SizedBox(
              width: 52, height: 52,
              child: Stack(alignment: Alignment.center, children: [
                CircularProgressIndicator(
                  value: (formScore / 100).clamp(0.0, 1.0),
                  backgroundColor: AppColors.bgCard,
                  strokeWidth: 5,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    formScore > 70 ? AppColors.primary : formScore > 40 ? AppColors.warning : AppColors.error,
                  ),
                ),
                Text('${formScore.toInt()}', style: GoogleFonts.barlow(
                  fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.textPrimary,
                )),
              ]),
            ),
            const SizedBox(height: 4),
            Text('FORM', style: GoogleFonts.barlow(
              fontSize: 11, letterSpacing: 3, color: AppColors.textSecondary, fontWeight: FontWeight.w600,
            )),
          ]),
        ],
      ),
    );
  }
}
