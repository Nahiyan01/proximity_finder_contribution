import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:proximity_finder/pages/home_page.dart';
import 'package:proximity_finder/pages/login_page.dart';

class SplashPage extends StatefulWidget {
  SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  double _opacity = 0.0;

  double _scale = 0.8;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: 100), () {
      setState(() {
        _opacity = 1;
        _scale = 1;
      });
    });
    Future.delayed(Duration(seconds: 2), () {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => HomePage()));
      } else {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => LoginPage()));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: Center(
          child: AnimatedOpacity(
            opacity: _opacity,
            duration: Duration(seconds: 2),
            child: AnimatedScale(
              scale: _scale,
              duration: Duration(seconds: 2),
              child: Lottie.asset('assets/animations/proximate_finder.json'),
            ),
          ),
        ));
  }
}
