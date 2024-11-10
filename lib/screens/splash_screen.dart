import 'package:flutter/material.dart';
import 'package:crm_app/services/business_config.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateBasedOnConfig();
  }

  Future<void> _navigateBasedOnConfig() async {
    final isConfigured = await BusinessConfig.isBusinessInfoSet();
    final nextRoute = isConfigured ? '/dashboard' : '/login';
    await Future.delayed(const Duration(seconds: 2));
    Navigator.pushReplacementNamed(context, nextRoute);
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
