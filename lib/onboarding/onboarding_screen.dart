import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'onboarding_controller.dart';
import 'step_preferences.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => OnboardingController(),
      child: Builder(
        builder: (context) {
          final controller = Provider.of<OnboardingController>(context, listen: false);

          return Scaffold(
            body: StepPreferences(
              onFinish: () async {
                try {
                  await controller.guardarEnFirestore();
                  if (context.mounted) {
                    Navigator.pushReplacementNamed(context, '/home');
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Error al guardar: ${e.toString()}")),
                    );
                  }
                }
              },
            ),
          );
        },
      ),
    );
  }
}