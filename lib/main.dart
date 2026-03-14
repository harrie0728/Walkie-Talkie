import 'package:flutter/material.dart';
import 'services/pi_service.dart';

void main() {
  runApp(const WalkieTalkieApp());
}

class WalkieTalkieApp extends StatelessWidget {
  const WalkieTalkieApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RoIP Radio',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const RadioScreen(),
    );
  }
}

class RadioScreen extends StatefulWidget {
  const RadioScreen({super.key});

  @override
  State<RadioScreen> createState() => _RadioScreenState();
}

class _RadioScreenState extends State<RadioScreen> {
  final PiService piService = PiService();
  int currentChannel = 1;
  bool isTransmitting = false;

  @override
  void initState() {
    super.initState();
    piService.connect();
  }
  
  @override
  void dispose() {
    piService.dispose();
    super.dispose();
  }

  String get formattedChannel => "00:0$currentChannel";

  void nextChannel() {
    setState(() {
      currentChannel = currentChannel < 4 ? currentChannel + 1 : 1;
    });
  }

  void previousChannel() {
    setState(() {
      currentChannel = currentChannel > 1 ? currentChannel - 1 : 4;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        title: const Text('My Radio'),
        backgroundColor: Colors.black,
        // NEW: Live connection status indicator in the top right corner
        actions: [
          ValueListenableBuilder<bool>(
            valueListenable: piService.isConnected,
            builder: (context, isConnected, child) {
              return Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: Row(
                  children: [
                    Icon(
                      Icons.circle,
                      color: isConnected ? Colors.greenAccent : Colors.redAccent,
                      size: 12,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      isConnected ? 'CONNECTED' : 'DISCONNECTED',
                      style: TextStyle(
                        color: isConnected ? Colors.greenAccent : Colors.redAccent,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "FREQUENCY",
              style: TextStyle(
                color: Colors.white70,
                fontSize: 16,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios),
                  color: Colors.blueAccent,
                  iconSize: 35,
                  onPressed: previousChannel,
                ),
                const SizedBox(width: 15),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey[800]!, width: 3),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.5),
                        blurRadius: 10,
                        spreadRadius: 2,
                      )
                    ],
                  ),
                  child: Text(
                    formattedChannel,
                    style: const TextStyle(
                      color: Colors.greenAccent,
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'MyDigitalFont',
                    ),
                  ),
                ),
                const SizedBox(width: 15),
                IconButton(
                  icon: const Icon(Icons.arrow_forward_ios),
                  color: Colors.blueAccent,
                  iconSize: 35,
                  onPressed: nextChannel,
                ),
              ],
            ),
            const SizedBox(height: 80),
            Text(
              isTransmitting ? "TRANSMITTING..." : "STANDBY",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: isTransmitting ? Colors.red : Colors.green,
              ),
            ),
            const SizedBox(height: 30),
            GestureDetector(
              onTapDown: (details) async {
                // Prevent transmitting if we aren't connected
                if (!piService.isConnected.value) {
                  print("Cannot transmit: Not connected to Pi");
                  return; 
                }
                
                await piService.startTransmit();
                setState(() {
                  isTransmitting = true;
                });
                print("Transmitting on Frequency $formattedChannel");
              },
              onTapUp: (details) async {
                if (isTransmitting) {
                  await piService.stopTransmit();
                  setState(() {
                    isTransmitting = false;
                  });
                }
              },
              onTapCancel: () async {
                // Safety catch just in case the finger slides off the button
                if (isTransmitting) {
                  await piService.stopTransmit();
                  setState(() {
                    isTransmitting = false;
                  });
                }
              },
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  color: isTransmitting ? Colors.red : Colors.grey[800],
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: isTransmitting ? Colors.redAccent : Colors.black54,
                      blurRadius: 20,
                      spreadRadius: 5,
                    )
                  ],
                ),
                child: const Center(
                  child: Icon(
                    Icons.mic,
                    size: 80,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}