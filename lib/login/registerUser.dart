import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';
import 'package:tes/main.dart';

void main() {
  runApp(MaterialApp(
    theme: ThemeData(
      fontFamily: 'Poppins',
    ),
    home: RegisterUser(),
  ));
}

class RegisterUser extends StatefulWidget {
  @override
  _RegisterUserState createState() => _RegisterUserState();
}

class _RegisterUserState extends State<RegisterUser> {
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController tanggalLahirController =
      TextEditingController();
  final TextEditingController noHpController = TextEditingController();
  bool _obscureText = true;
  bool _obscureTextConfirm = true;
  Timer? _timer;
  Timer? _timerConfirm;
  int _remainingSeconds = 3;
  int _remainingSecondsConfirm = 3;

  Future<void> register(BuildContext context) async {
    if (_checkFormFields()) {
      var url = 'http://192.168.1.5/tes/register.php';
      var response = await http.post(Uri.parse(url), body: {
        'username': usernameController.text,
        'password': passwordController.text,
        'confirm_password': confirmPasswordController.text,
        'email': emailController.text,
        'tanggal_lahir': tanggalLahirController.text,
        'no_hp': noHpController.text,
      });

      var data = json.decode(response.body);
      print(data['message']);

      if (data['success']) {
        _showSuccessDialog(context, 'Registration successful!');
        _clearFormFields();
      } else {
        _showErrorDialog(context, data['message']);
      }
    }
  }

  bool _checkFormFields() {
    if (usernameController.text.isEmpty ||
        passwordController.text.isEmpty ||
        confirmPasswordController.text.isEmpty ||
        emailController.text.isEmpty ||
        tanggalLahirController.text.isEmpty ||
        noHpController.text.isEmpty) {
      _showErrorDialog(context, 'Please fill in all fields.');
      return false;
    } else if (passwordController.text != confirmPasswordController.text) {
      _showErrorDialog(context, 'Passwords do not match.');
      return false;
    } else if (noHpController.text.length < 13) {
      _showErrorDialog(context, 'Phone number must be at least 13 digits.');
      return false;
    } else if (!_isValidEmail(emailController.text)) {
      _showErrorDialog(context, 'Email must end with @gmail.com');
      return false;
    }
    return true;
  }

  bool _isValidEmail(String email) {
    return email.toLowerCase().endsWith('@gmail.com');
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

  void _showSuccessDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Success'),
          content: Text(message),
          actions: <Widget>[
            ElevatedButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context)
                    .push(MaterialPageRoute(builder: (context) => MyApp()));
                _clearFormFields();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != DateTime.now())
      setState(() {
        tanggalLahirController.text = "${picked.toLocal()}".split(' ')[0];
      });
  }

  void _togglePasswordVisibility(bool isPassword) {
    setState(() {
      if (isPassword) {
        _obscureText = !_obscureText;
        if (!_obscureText) {
          _remainingSeconds = 3;
          _startCountdown();
        } else {
          _timer?.cancel();
        }
      } else {
        _obscureTextConfirm = !_obscureTextConfirm;
        if (!_obscureTextConfirm) {
          _remainingSecondsConfirm = 3;
          _startCountdownConfirm();
        } else {
          _timerConfirm?.cancel();
        }
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

  void _startCountdownConfirm() {
    _timerConfirm = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingSecondsConfirm > 0) {
          _remainingSecondsConfirm--;
        } else {
          _obscureTextConfirm = true;
          _timerConfirm?.cancel();
        }
      });
    });
  }

  void _clearFormFields() {
    usernameController.clear();
    passwordController.clear();
    confirmPasswordController.clear();
    emailController.clear();
    tanggalLahirController.clear();
    noHpController.clear();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _timerConfirm?.cancel();
    usernameController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    emailController.dispose();
    tanggalLahirController.dispose();
    noHpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text('Daftar Akun',
              style: TextStyle(
                  fontFamily: 'Poppins', fontWeight: FontWeight.w600)),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text(
                'Masukkan data dibawah untuk membuat akun',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              SizedBox(
                height: 20,
              ),
              TextField(
                controller: usernameController,
                decoration: InputDecoration(
                    labelText: 'Nama',
                    labelStyle: TextStyle(fontFamily: 'Poppins'),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none),
                    filled: true,
                    fillColor: Colors.grey[300]),
              ),
              SizedBox(
                height: 12,
              ),
              TextFormField(
                controller: tanggalLahirController,
                readOnly: true,
                onTap: () => _selectDate(context),
                decoration: InputDecoration(
                    suffixIcon: Icon(Icons.date_range_outlined),
                    labelText: 'Tanggal Lahir',
                    labelStyle: TextStyle(fontFamily: 'Poppins'),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none),
                    filled: true,
                    fillColor: Colors.grey[300]),
              ),
              SizedBox(
                height: 12,
              ),
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
                          onPressed: () => _togglePasswordVisibility(true),
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
              SizedBox(
                height: 12,
              ),
              TextField(
                controller: confirmPasswordController,
                obscureText: _obscureTextConfirm,
                decoration: InputDecoration(
                  labelText: 'Confirm Password',
                  labelStyle: TextStyle(fontFamily: 'Poppins'),
                  suffixIcon: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (!_obscureTextConfirm)
                        Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: Text('$_remainingSecondsConfirm'),
                        ),
                      IconButton(
                        icon: Icon(
                          _obscureTextConfirm
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed: () => _togglePasswordVisibility(false),
                      ),
                    ],
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.grey[300],
                ),
              ),
              SizedBox(
                height: 12,
              ),
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
            SizedBox(
              height: 12,
            ),
              TextField(
  controller: noHpController,
  decoration: InputDecoration(
    labelText: 'No.Hp',
    labelStyle: TextStyle(fontFamily: 'Poppins'),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide.none,
    ),
    filled: true,
    fillColor: Colors.grey[300],
  ),
  keyboardType: TextInputType.phone, 
  inputFormatters: <TextInputFormatter>[
    FilteringTextInputFormatter.digitsOnly, 
  ],
),
              SizedBox(
                height: 12,
              ),
              ElevatedButton(
                onPressed:
 () => register(context),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: Text(
                  'Register',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
          ]),
        ),
      ),
    );
  }
}
