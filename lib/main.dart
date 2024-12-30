import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MusicApp(),
    );
  }
}

class MusicApp extends StatefulWidget {
  const MusicApp({super.key});

  @override
  State<MusicApp> createState() => _MusicAppState();
}

class _MusicAppState extends State<MusicApp> {
  bool playing = false;
  IconData playButton = Icons.play_arrow_rounded;

  late AudioPlayer _player;
  late AudioCache cache;

  Duration position = const Duration();
  Duration musicLength = const Duration();
  double volume = 0.5;

  Widget slider(BuildContext context) {
    return Expanded(
      child: Slider.adaptive(
        value: position.inSeconds.toDouble(),
        max: musicLength.inSeconds.toDouble(),
        onChanged: (value) {
          seekToSec(value.toInt());
        },
        activeColor: Colors.purple.shade900,
        inactiveColor: Colors.grey.shade500,
      ),
    );
  }

  Widget volumeSlider(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          onPressed: () {
            setState(() {
              volume = (volume - 0.1).clamp(0.0, 1.0);
              _player.setVolume(volume);
            });
          },
          icon: Icon(Icons.volume_down),
          color: Colors.purple.shade900,
        ),
        SizedBox(
          width: screenWidth * 0.5,
          child: Slider(
            value: volume,
            onChanged: (value) {
              setState(() {
                volume = value;
                _player.setVolume(volume);
              });
            },
            min: 0,
            max: 1,
            divisions: 10,
            activeColor: Colors.purple.shade900,
            inactiveColor: Colors.grey.shade500,
          ),
        ),
        IconButton(
          onPressed: () {
            setState(() {
              volume = (volume + 0.1).clamp(0.0, 1.0);
              _player.setVolume(volume);
            });
          },
          icon: Icon(Icons.volume_up),
          color: Colors.purple.shade900,
        ),
      ],
    );
  }

  void seekToSec(int sec) {
    Duration newPos = Duration(seconds: sec);
    _player.seek(newPos);
  }

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();
    cache = AudioCache(prefix: 'assets/');

    cache.load('hanuman_chalisa.mp3');

    _player.onDurationChanged.listen((d) {
      setState(() {
        musicLength = d;
      });
    });

    _player.onPositionChanged.listen((p) {
      setState(() {
        position = p;
      });
    });

    _player.onPlayerComplete.listen((event) {
      setState(() {
        playing = false;
        playButton = Icons.play_arrow_rounded;
        position = const Duration(seconds: 0);
      });
    });
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Container(
        width: double.infinity,
        color: const Color.fromARGB(255, 29, 26, 26),
        child: Padding(
          padding: EdgeInsets.only(
            top: screenHeight * 0.06,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(left: screenWidth * 0.03),
                child: const Text(
                  "Hanuman Chalisa",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 38,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: screenWidth * 0.07),
                child: const Text(
                  "Listen from Aditya Gadhvi",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              SizedBox(
                height: screenHeight * 0.03,
              ),
              Center(
                child: Container(
                  width: screenWidth * 0.75,
                  height: screenWidth * 0.75,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30.0),
                    image: const DecorationImage(
                      image: AssetImage("assets/hanuman.png"),
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: screenHeight * 0.015,
              ),
              const Center(
                child: Text(
                  "Hanuman Chalisa",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.w600),
                ),
              ),
              SizedBox(
                height: screenHeight * 0.03,
              ),
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(40.0),
                      topRight: Radius.circular(40.0),
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: screenWidth * 0.85,
                        height: screenHeight * 0.04,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              "${position.inMinutes}:${position.inSeconds.remainder(60).toString().padLeft(2, '0')}",
                              style: const TextStyle(fontSize: 18.0),
                            ),
                            slider(context),
                            Text(
                              "${musicLength.inMinutes}:${musicLength.inSeconds.remainder(60).toString().padLeft(2, '0')}",
                              style: const TextStyle(fontSize: 18.0),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          IconButton(
                            onPressed: () async {
                              await _player.seek(const Duration(seconds: 0));
                              await _player.resume();
                            },
                            iconSize: screenWidth * 0.15,
                            color: Colors.purple.shade900,
                            icon: const Icon(Icons.skip_previous_rounded),
                          ),
                          IconButton(
                            onPressed: () async {
                              if (!playing) {
                                await _player
                                    .play(AssetSource('hanuman_chalisa.mp3'));
                                setState(() {
                                  playButton = Icons.pause;
                                  playing = true;
                                });
                              } else {
                                await _player.pause();
                                setState(() {
                                  playButton = Icons.play_arrow_rounded;
                                  playing = false;
                                });
                              }
                            },
                            iconSize: screenWidth * 0.17,
                            color: Colors.black,
                            icon: Icon(playButton),
                          ),
                          IconButton(
                            onPressed: () async {
                              await _player.seek(musicLength);
                              await _player.stop();
                              setState(() {
                                playing = false;
                                playButton = Icons.play_arrow_rounded;
                              });
                            },
                            iconSize: screenWidth * 0.15,
                            color: Colors.purple.shade900,
                            icon: const Icon(Icons.skip_next_rounded),
                          ),
                        ],
                      ),
                      volumeSlider(context),
                      SizedBox(height: screenHeight * 0.03),
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Developed by ",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            "Ayush Vora",
                            style: TextStyle(
                              color: Colors.purple,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
