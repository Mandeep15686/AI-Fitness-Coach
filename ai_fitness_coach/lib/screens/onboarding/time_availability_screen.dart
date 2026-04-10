import 'package:flutter/material.dart';
import '../../core/routes/app_routes.dart';

class TimeAvailabilityScreen extends StatelessWidget {
  const TimeAvailabilityScreen({super.key});
  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.of(context).pushReplacementNamed(AppRoutes.signup);
    });
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
