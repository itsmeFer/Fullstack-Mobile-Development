import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:tes/main.dart';

class NextScreen extends StatefulWidget {
  final String userId;

  NextScreen({Key? key, required this.userId}) : super(key: key);

  @override
  _NextScreenState createState() => _NextScreenState();
}

class _NextScreenState extends State<NextScreen> {
  Timer? _timer;
  int _idleTimeInSeconds = 300; // 5 menit dalam detik
  bool _showAlert = false;
  String? _username;
  String? _selectedPlate;

  List<String> _plateNumbers = [
    'B 1234 ABC',
    'B 5678 DEF',
    'B 9101 GHI',
    'B 2345 JKL',
  ];

  List<String> _choices = [
    'Service Berkala',
    'Promo Dasyat',
    'Cabang Terdekat',
    'Acara',
    'Tentang Kami',
  ];

  // Index untuk BottomNavigationBar
  int _selectedIndex = 0;

  // Daftar halaman yang akan ditampilkan berdasarkan bottom navigation bar
  List<Widget> _widgetOptions = <Widget>[
    PlaceholderWidget('Profil'), // Ganti dengan halaman profil Anda
    PlaceholderWidget('Pencarian'), // Ganti dengan halaman pencarian Anda
    PlaceholderWidget('Beranda'), // Ganti dengan halaman beranda Anda
    PlaceholderWidget('Mobile'), // Ganti dengan halaman mobile Anda
  ];

  @override
  void initState() {
    super.initState();
    _initializeTimer();
    _loadUsername();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _initializeTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_idleTimeInSeconds > 0) {
        setState(() {
          _idleTimeInSeconds--;
          if (_idleTimeInSeconds <= 10) {
            _showAlert = true;
          } else {
            _showAlert = false;
          }
        });
      } else {
        _logout(); // Logout otomatis jika waktu habis
      }
    });
  }

  void _loadUsername() async {
    var url =
        'http://192.168.1.5/tes/getUsername.php'; // Ganti dengan URL getUsername.php Anda
    var response = await http.post(Uri.parse(url), body: {
      'userId': widget.userId,
    });

    print(
        'Get username response body: ${response.body}'); // Cetak respons untuk debugging

    try {
      var data = json.decode(response.body);
      if (data['success']) {
        setState(() {
          _username = data['username'];
        });
      } else {
        print('Failed to get username: ${data['message']}');
      }
    } catch (e) {
      print('Error parsing JSON: $e');
    }
  }

  void _resetTimer() {
    setState(() {
      _idleTimeInSeconds = 300; // Reset timer ke 5 menit jika ada interaksi
      _showAlert = false;
    });
  }

  void _logout() async {
    _timer?.cancel();

    // Langsung melakukan proses logout tanpa konfirmasi
    await _logoutWithoutDialog();
  }

  Future<void> _logoutWithoutDialog() async {
    var url =
        'http://192.168.1.5/tes/logout.php'; // Ganti dengan URL logout.php Anda
    var response = await http.post(Uri.parse(url), body: {
      'userId': widget.userId,
    });

    print(
        'Logout response body: ${response.body}'); // Cetak respons untuk debugging

    try {
      var data = json.decode(response.body);
      if (data['success']) {
        // Menampilkan alert setelah logout berhasil
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Berhasil Logout'),
              content: Text(
                  'Terima kasih sudah menggunakan aplikasi kami.\nIngat mobil, ingat Daihatsu!'),
              actions: <Widget>[
                TextButton(
                  child: Text('OK'),
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => MyApp()),
                      (Route<dynamic> route) => false,
                    );
                  },
                ),
              ],
            );
          },
        );
      } else {
        print('Gagal logout: ${data['message']}');
      }
    } catch (e) {
      print('Error parsing JSON: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, // Menghilangkan tombol back
        title: Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: Text(
            'Hello, ${_username ?? ""}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
        ),
        actions: [
          Container(
            margin: EdgeInsets.symmetric(horizontal: 16),
            padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(8),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedPlate,
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedPlate = newValue;
                  });
                  // Handle selection, if needed
                },
                items:
                    _plateNumbers.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(
                      value,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                }).toList(),
                icon: Icon(
                  Icons.arrow_drop_down,
                  color: Colors.black,
                ),
                elevation: 0,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                dropdownColor: Colors.white,
              ),
            ),
          ),
        ],
      ),
      body: GestureDetector(
        onTap: _resetTimer,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Gambar di bagian atas
            Image.asset(
              'images/Frame 3860.png',
              fit: BoxFit.cover,
            ),
            // Spasi antara gambar dan TextField
            SizedBox(height: 20),
            // TextField untuk pencarian
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Rekomendasi mobil keluarga',labelStyle: TextStyle(
                    color: Colors.grey[200]
                  ),
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  filled: true,
                  fillColor: Colors.grey[200],
                ),
              ),
            ),
            SizedBox(height: 10),
            // ChoiceChips untuk pilihan
            Container(
              height: 40,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _choices.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: EdgeInsets.symmetric(horizontal: 15),
                    child: ChoiceChip(
                      
                      label: Text(
                        
                        _choices[index],
                        style: TextStyle(
                          
                          color: Colors.grey[400],
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      
                      backgroundColor: Colors.grey[200],
                      shape: StadiumBorder(
                        side: BorderSide(
                          color: Colors.white
                        )
                      ),
                      selected: false,
                      onSelected: (isSelected) {
                        // Handle chip selection, if needed
                      },
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 20),
            Card(
              child: Image.asset('images/image-removebg-preview (12).png'),
            ),
            SizedBox(height: 20),
           
            Spacer(),
            Padding(
              padding: const EdgeInsets.only(left: 30,right: 30),
              child: ElevatedButton(
                style:ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                ),
                onPressed: () => _logout(),
                child: Text('Logout',style: TextStyle(
                  color: Colors.white
                ),),
              ),
            ),
            
            if (_showAlert)
              Text(
                'Sesi login akan berakhir dalam $_idleTimeInSeconds detik',
                style: TextStyle(fontSize: 16, color: Colors.red),
              ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
          // Tambahkan navigasi sesuai dengan index yang dipilih
          // Misalnya: Navigator.push(context, MaterialPageRoute(builder: (context) => HalamanProfil()));
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Beranda',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.car_crash_outlined),
            label: 'Kendaraan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Pencarian',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}

class PlaceholderWidget extends StatelessWidget {
  final String text;

  PlaceholderWidget(this.text);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        text,
        style: TextStyle(fontSize: 24),
      ),
    );
  }
}
