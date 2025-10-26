import 'package:flutter/material.dart';
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
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          // Rep counter
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '$repCount',
                style: const TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryColor,
                ),
              ),
              const Text('REPS'),
            ],
          ),

          // Exercise type
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.fitness_center, size: 32),
              const SizedBox(height: 4),
              Text(
                exerciseType,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),

          // Form score
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                value: formScore / 100,
                backgroundColor: Colors.grey[300],
                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.successColor),
              ),
              const SizedBox(height: 4),
              Text('${formScore.toStringAsFixed(0)}%'),
              const Text('Form', style: TextStyle(fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }
}
