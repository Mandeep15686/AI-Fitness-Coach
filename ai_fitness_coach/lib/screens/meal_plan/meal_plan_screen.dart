import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/colors.dart';
import '../../providers/meal_plan_provider.dart';
import '../../providers/auth_provider.dart';

class MealPlanScreen extends StatelessWidget {
  const MealPlanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        title: Text('Meal Plan', style: GoogleFonts.barlow(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary), onPressed: () => Navigator.pop(context)),
      ),
      body: Consumer2<MealPlanProvider, AuthProvider>(
        builder: (context, mealPlan, auth, _) {
          final plan = mealPlan.mealPlan;
          final user = auth.currentUser;

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Generate button
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [Color(0xFF1A1A2E), Color(0xFF12121E)]),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('AI-Generated', style: GoogleFonts.barlow(fontSize: 11, color: AppColors.primary, fontWeight: FontWeight.w700, letterSpacing: 1)),
                      const SizedBox(height: 4),
                      Text('Your Personalized\nMeal Plan', style: GoogleFonts.barlow(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textPrimary, height: 1.2)),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: mealPlan.isLoading || user == null ? null : () {
                            mealPlan.generateMealPlan(
                              user: user,
                              fitnessGoal: user.fitnessGoal,
                              dietaryRestrictions: [],
                              foodPreferences: [],
                              foodDislikes: [],
                              budget: 100,
                            );
                          },
                          icon: mealPlan.isLoading
                              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.textOnPrimary))
                              : const Icon(Icons.auto_awesome_rounded),
                          label: Text(mealPlan.isLoading ? 'Generating...' : 'Generate Plan'),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                if (plan != null) ...[
                  // Calorie target
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: AppColors.bgCard, borderRadius: BorderRadius.circular(12)),
                    child: Row(children: [
                      const Icon(Icons.local_fire_department_rounded, color: AppColors.accent, size: 28),
                      const SizedBox(width: 12),
                      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text('Daily Target', style: GoogleFonts.barlow(fontSize: 12, color: AppColors.textSecondary)),
                        Text('${(plan['targetCalories'] as num?)?.toStringAsFixed(0) ?? '—'} kcal', style: GoogleFonts.barlow(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                      ]),
                    ]),
                  ),
                  const SizedBox(height: 20),

                  Text('Daily Meals', style: GoogleFonts.barlow(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                  const SizedBox(height: 12),

                  ...(plan['dailyPlan'] as Map<String, dynamic>? ?? {}).entries.map((entry) {
                    final meal = entry.value as Map<String, dynamic>;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: AppColors.bgCard, borderRadius: BorderRadius.circular(14)),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Row(children: [
                          Text(_mealEmoji(entry.key), style: const TextStyle(fontSize: 20)),
                          const SizedBox(width: 8),
                          Text(entry.key, style: GoogleFonts.barlow(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.primary)),
                          const Spacer(),
                          Text('${meal['calories'] ?? 0} kcal', style: GoogleFonts.barlow(fontSize: 13, color: AppColors.accent, fontWeight: FontWeight.w600)),
                        ]),
                        const SizedBox(height: 6),
                        Text(meal['name'] ?? '', style: GoogleFonts.barlow(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                        const SizedBox(height: 4),
                        Text(meal['recipe'] ?? '', style: GoogleFonts.barlow(fontSize: 13, color: AppColors.textSecondary)),
                      ]),
                    );
                  }),

                  const SizedBox(height: 20),
                  Text('Grocery List', style: GoogleFonts.barlow(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                  const SizedBox(height: 12),
                  Wrap(spacing: 8, runSpacing: 8, children: [
                    ...((plan['groceryList'] as List<dynamic>? ?? []).map((item) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(color: AppColors.bgCard, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.bgCardElevated)),
                      child: Text(item.toString(), style: GoogleFonts.barlow(fontSize: 13, color: AppColors.textPrimary)),
                    ))),
                  ]),
                ],
                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }

  String _mealEmoji(String meal) {
    switch (meal.toLowerCase()) {
      case 'breakfast': return '🌅';
      case 'lunch': return '☀️';
      case 'dinner': return '🌙';
      case 'snack': return '🍎';
      default: return '🍽️';
    }
  }
}
