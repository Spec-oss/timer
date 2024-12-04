import 'package:flutter/material.dart';
import 'dart:async';
import 'package:just_audio/just_audio.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: AlarmApp(),
    );
  }
}

class AlarmApp extends StatefulWidget {
  @override
  _AlarmAppState createState() => _AlarmAppState();
}

class _AlarmAppState extends State<AlarmApp> {
  final TextEditingController _durationController = TextEditingController();
  final TextEditingController _repeatsController = TextEditingController();

  int _duration = 0;
  int _repeats = 0;
  int _currentRepeat = 0;
  int _remainingTime = 0;
  bool _isTimerRunning = false;
  late Timer _timer;
  String _statusMessage = 'Süre ve tekrar sayısı girin.';

  final AudioPlayer _audioPlayer = AudioPlayer();

  void _playAlarmSound() async {
    await _audioPlayer.setAsset('assets/alarm_sound.mp3');
    await _audioPlayer.play();
  }

  void _startTimer() {
    setState(() {
      _currentRepeat = 0;
      _remainingTime = _duration;
      _isTimerRunning = true;
      _statusMessage = 'Timer başlatıldı!';
    });

    _runAlarm();
  }

  void _runAlarm() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_remainingTime > 0) {
        setState(() {
          _remainingTime--;
        });
      } else {
        if (_currentRepeat < _repeats) {
          print("Alarm çalıyor: ${_currentRepeat + 1}. tekrar");
          _playAlarmSound();

          setState(() {
            _currentRepeat++;
            _remainingTime = _duration;
          });

          if (_currentRepeat >= _repeats) {
            setState(() {
              _isTimerRunning = false;
              _statusMessage = 'Tüm tekrarlar tamamlandı!';
            });
            timer.cancel();
          }
        }
      }
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Alarm Uygulaması"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _durationController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Süre (saniye)',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _repeatsController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Tekrar Sayısı',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _duration = int.parse(_durationController.text);
                  _repeats = int.parse(_repeatsController.text);
                  _startTimer();
                });
              },
              child: Text("Alarmı Başlat"),
            ),
            SizedBox(height: 20),
            Text(
              'Kalan Süre: $_remainingTime saniye',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              _statusMessage,
              style: TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}
