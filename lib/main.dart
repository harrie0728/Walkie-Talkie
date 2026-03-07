import 'package:flutter/material.dart';

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
  int currentChannel = 1;
  bool isTransmitting = false;

  // This formats our standard number (1) into the digital style ("00:01")
  String get formattedChannel {
    return "00:0$currentChannel";
  }

  // Logic for the Right Arrow
  void nextChannel() {
    setState(() {
      if (currentChannel < 4) {
        currentChannel++;
      } else {
        currentChannel = 1; // Loop back to 1
      }
    });
  }

  // Logic for the Left Arrow
  void previousChannel() {
    setState(() {
      if (currentChannel > 1) {
        currentChannel--;
      } else {
        currentChannel = 4; // Loop back to 4
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        title: const Text('My Radio'),
        backgroundColor: Colors.black,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // --- NEW: Digital Frequency Display ---
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
                // Left Arrow Button
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios),
                  color: Colors.blueAccent,
                  iconSize: 35,
                  onPressed: previousChannel,
                ),
                
                const SizedBox(width: 15),
                
                // The LCD-style Screen
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
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
                    ]
                  ),
                  child: Text(
                    formattedChannel,
                    style: const TextStyle(
                      color: Colors.greenAccent, // Gives it that classic digital glow
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'MyDigitalFont', // Monospace font for a hardware look
                    ),
                  ),
                ),
                
                const SizedBox(width: 15),
                
                // Right Arrow Button
                IconButton(
                  icon: const Icon(Icons.arrow_forward_ios),
                  color: Colors.blueAccent,
                  iconSize: 35,
                  onPressed: nextChannel,
                ),
              ],
            ),
            // --------------------------------------

            const SizedBox(height: 80), // Increased spacing

            // Status Text
            Text(
              isTransmitting ? "TRANSMITTING..." : "STANDBY",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: isTransmitting ? Colors.red : Colors.green,
              ),
            ),
            
            const SizedBox(height: 30),
            
            // The Push to Talk Button
            GestureDetector(
              onTapDown: (details) {
                setState(() {
                  isTransmitting = true;
                });
                print("Transmitting on Frequency $formattedChannel");
              },
              onTapUp: (details) {
                setState(() {
                  isTransmitting = false;
                });
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