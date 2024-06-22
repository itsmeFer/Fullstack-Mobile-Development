import 'dart:async'; // Import dart:async untuk menggunakan Timer
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:tes/splashscreen.dart';
import 'NextScreen.dart';
import 'package:tes/login/registerUser.dart';

void main() {
  runApp(MaterialApp(
    theme: ThemeData(
      fontFamily: 'Poppins',
    ),
    home: SplashScreen(),
  ));
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  bool _obscureText = true;
  Timer? _timer; 

  int _remainingSeconds = 3;

  Future<void> login(BuildContext context) async {
    var url = 'http://192.168.1.5/tes/login.php';
    var response = await http.post(Uri.parse(url), body: {
      'email': emailController.text,
      'password': passwordController.text,
    });

    print('Response body: ${response.body}'); 

    try {
      var data = json.decode(response.body);
      print(data['message']);

      if (data['success']) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => NextScreen(userId: data['userId']),
          ),
        );
      } else {
        _showErrorDialog(context, data['message']);
      }
    } catch (e) {
      print('Error parsing JSON: $e');
      _showErrorDialog(context, 'Error parsing response from server.');
    }
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text(message),
          actions: <Widget>[
            ElevatedButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscureText = !_obscureText;
      if (!_obscureText) {
        _remainingSeconds = 3;
        _startCountdown();
      } else {
        _timer?.cancel();
      }
    });
  }

  void _startCountdown() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingSeconds > 0) {
          _remainingSeconds--;
        } else {
          _obscureText = true;
          _timer?.cancel();
        }
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Capella Daihatsu App',
          style: TextStyle(fontFamily: 'Poppins'),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Image.network(
                  'https://www.sbtjapan.com/assets/cms-global/img/how-to-buy/shipment-2.png?v=1'),
              SizedBox(height: 20),
              Text(
                'Welcome Back',
                style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.w900,
                    fontSize: 25,
                    fontFamily: 'Poppins'),
              ),
              Text('Pastikan akun login anda sudah benar',
                  style: TextStyle(fontFamily: 'Poppins')),
              SizedBox(height: 25),
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                    labelText: 'Email',
                    labelStyle: TextStyle(fontFamily: 'Poppins'),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none),
                    filled: true,
                    fillColor: Colors.grey[300]),
              ),
              SizedBox(height: 20),
              TextField(
                controller: passwordController,
                obscureText: _obscureText,
                decoration: InputDecoration(
                    labelText: 'Password',
                    labelStyle: TextStyle(fontFamily: 'Poppins'),
                    suffixIcon: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (!_obscureText)
                          Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: Text('$_remainingSeconds'),
                          ),
                        IconButton(
                          icon: Icon(
                            _obscureText
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          onPressed: _togglePasswordVisibility,
                        ),
                      ],
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.grey[300]),
              ),
              SizedBox(height: 20.0),
              ElevatedButton(
                onPressed: () => login(context),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: Text(
                  'Login',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(height: 10.0),
              Center(
                  child: Text('Tidak memiliki akun?',
                      style: TextStyle(fontFamily: 'Poppins'))),
              SizedBox(height: 10.0),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    side: BorderSide(color: Colors.grey),
                    backgroundColor: Colors.white),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => RegisterUser()),
                  );
                },
                child: Text('Register',
                    style: TextStyle(
                        color: Colors.grey[600],
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Poppins')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
