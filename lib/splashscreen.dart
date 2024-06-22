import 'dart:async';
import 'package:flutter/material.dart';
import 'package:tes/main.dart'; 
class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    
    Timer(Duration(seconds: 4), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MyApp()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent, 
      body: Stack(
        children: [
          
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(
                  'https://pict-b.sindonews.net/dyn/850/pena/news/2020/04/16/120/2744/daihatsu-perpanjang-stop-operasional-sementara-hingga-24-april-2020-hew.jpg',
                ),
                fit: BoxFit.cover, 
              ),
            ),
          ),
          // Gradient di atas gambar
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.transparent,
                  Colors.red.withOpacity(0.5),
                  Colors.white.withOpacity(0.8),
                ],
              ),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  
                  Image.asset(
                    'images/DMS3.png',
                    width: 200, 
                  ),
                  SizedBox(height: 20),
                  CircularProgressIndicator(
                    color: Colors.red,
                  ), 
                ],
              ),
            ),
          ),
          
          Positioned(
            bottom: 20, 
            left: 0,
            right: 0,
            child: Center(
              child: Image.asset(
                'images/CAPELLAMEDAN.png',
                width: 200, 
              ),
            ),
          ),
        ],
      ),
    );
  }
}
