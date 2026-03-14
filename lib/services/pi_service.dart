import 'dart:async';
import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/foundation.dart'; // Added for ValueNotifier
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';

class PiService {
  WebSocket? _socket;
  bool transmitting = false;
  
  // NEW: A reactive variable to track connection status
  final ValueNotifier<bool> isConnected = ValueNotifier<bool>(false);

  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  final FlutterSoundPlayer _player = FlutterSoundPlayer();
  
  StreamController<Uint8List>? _recordingDataController;

  Future<void> connect() async {
    // 1. Request microphone permission
    var status = await Permission.microphone.request();
    if (!status.isGranted) {
      print('Microphone permission denied');
      return;
    }

    // 2. Connect WebSocket to Raspberry Pi
    try {
      _socket = await WebSocket.connect('ws://192.168.68.110:8765');
      print('Connected to Raspberry Pi WebSocket');
      
      // Update status to connected!
      isConnected.value = true;

      // 3. Initialize player
      await _player.openPlayer(); 
      await _player.startPlayer(   
        codec: Codec.pcm16, 
        sampleRate: 44100,
        numChannels: 1,
      );

      // 4. Listen for audio from Pi
      _socket!.listen((data) {
        if (!transmitting && _player.uint8ListSink != null) {
          if (data is Uint8List) {
            _player.uint8ListSink!.add(data);
          } else if (data is List<int>) {
            _player.uint8ListSink!.add(Uint8List.fromList(data));
          }
        }
      }, 
      onError: (error) {
        print('WebSocket Error: $error');
        isConnected.value = false; // Update status on error
      },
      onDone: () {
        print('WebSocket Disconnected');
        isConnected.value = false; // Update status on disconnect
      });
      
    } catch (e) {
      print('Failed to connect to Pi: $e');
      isConnected.value = false; // Update status if connection fails
    }
  }

  Future<void> startTransmit() async {
    transmitting = true;
    await _recorder.openRecorder(); 
    _recordingDataController = StreamController<Uint8List>();
    
    _recordingDataController!.stream.listen((buffer) {
      if (_socket != null && transmitting && isConnected.value) {
        _socket!.add(buffer);
      }
    });

    await _recorder.startRecorder(
      codec: Codec.pcm16,
      sampleRate: 44100,
      numChannels: 1,
      toStream: _recordingDataController!.sink,
    );
  }

  Future<void> stopTransmit() async {
    transmitting = false;
    await _recorder.stopRecorder();
    await _recorder.closeRecorder(); 
    await _recordingDataController?.close();
  }

  Future<void> dispose() async {
    await _player.stopPlayer();
    await _player.closePlayer(); 
    await _recorder.closeRecorder(); 
    await _recordingDataController?.close();
    await _socket?.close();
    isConnected.dispose(); // Clean up the notifier
  }
}