import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:wave_player/wave_player.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Wave Player Example',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      ),
      home: const WavePlayerExample(),
    );
  }
}

class WavePlayerExample extends StatefulWidget {
  const WavePlayerExample({super.key});

  @override
  State<WavePlayerExample> createState() => _WavePlayerExampleState();
}

class _WavePlayerExampleState extends State<WavePlayerExample> {
  Timer? _volumeTimer;
  final WaveformPlayerController _controller = WaveformPlayerController();

  // Constants
  static const String _audioUrl =
      'https://raw.githubusercontent.com/QuangNH0606/wave_player/main/assets/mp3_url.mp3';

  static const Duration _refreshInterval = Duration(milliseconds: 500);
  static const Duration _volumeSimulationInterval = Duration(milliseconds: 100);

  @override
  void initState() {
    super.initState();
    _startVolumeSimulation();
  }

  @override
  void dispose() {
    _volumeTimer?.cancel();
    super.dispose();
  }

  void _startVolumeSimulation() {
    _volumeTimer = Timer.periodic(_volumeSimulationInterval, (timer) {
      if (mounted) {
        setState(() {});
      } else {
        timer.cancel();
      }
    });
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:'
          '${minutes.toString().padLeft(2, '0')}:'
          '${seconds.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
  }

  List<double> _generateSampleWaveform() {
    final random = math.Random();
    return List.generate(50, (index) => random.nextDouble() * 20 + 5);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Wave Player Example'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 24,
          children: [
            _buildSectionTitle('Controller Player'),
            _buildControllerPlayer(),
            _buildSectionTitle('Basic Player'),
            _buildBasicPlayer(),
            _buildSectionTitle('Audio Slider'),
            _buildBasicSlider(),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildControllerPlayer() {
    return _buildCard(
      child: Column(
        children: [
          WaveformPlayer(
            thumbColor: Colors.red,
            audioUrl: _audioUrl,
            controller: _controller,
          ),
          const SizedBox(height: 12),
          _buildControlButtons(),
          const SizedBox(height: 8),
          _buildSeekButtons(),
          const SizedBox(height: 8),
          _buildStatusDisplay(),
        ],
      ),
    );
  }

  Widget _buildBasicPlayer() {
    return _buildCard(
      child: WaveformPlayer(
        assetPath: 'assets/500kb.mp3',
      ),
    );
  }

  Widget _buildBasicSlider() {
    return _buildCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: BasicAudioSlider(
        value: 0.0,
        max: 100.0,
        onChanged: (value) {
          // Handle value change
        },
        onChangeStart: () {
          // Handle start
        },
        onChangeEnd: () {
          // Handle end
        },
        waveformData: _generateSampleWaveform(),
        activeColor: WavePlayerColors.waveformActive,
        inactiveColor: WavePlayerColors.waveformInactive,
        thumbColor: WavePlayerColors.waveformThumb,
        thumbShape: ThumbShape.verticalBar,
      ),
    );
  }

  Widget _buildCard({
    required Widget child,
    EdgeInsets? padding,
  }) {
    return Container(
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildControlButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildControlButton(
          onPressed: () => _controller.play(),
          icon: Icons.play_arrow,
          label: 'Play',
          color: Colors.green,
        ),
        _buildControlButton(
          onPressed: () => _controller.pause(),
          icon: Icons.pause,
          label: 'Pause',
          color: Colors.orange,
        ),
        _buildControlButton(
          onPressed: () => _controller.togglePlayPause(),
          icon: _controller.isPlaying ? Icons.pause : Icons.play_arrow,
          label: 'Toggle',
          color: Colors.blue,
        ),
      ],
    );
  }

  Widget _buildControlButton({
    required VoidCallback onPressed,
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(label, style: const TextStyle(fontSize: 12)),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
        ),
      ),
    );
  }

  Widget _buildSeekButtons() {
    final seekPercentages = [0.25, 0.5, 0.75];

    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        ...seekPercentages.map(
          (percentage) => ElevatedButton(
            onPressed: () => _controller.seekToPercentage(percentage),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey[200],
              foregroundColor: Colors.black87,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            child: Text('${(percentage * 100).toInt()}%',
                style: const TextStyle(fontSize: 11)),
          ),
        ),
        ElevatedButton(
          onPressed: () => _controller.seekTo(Duration.zero),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red[100],
            foregroundColor: Colors.red[700],
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          child: const Text('Reset', style: TextStyle(fontSize: 11)),
        ),
      ],
    );
  }

  Widget _buildStatusDisplay() {
    return StreamBuilder<void>(
      stream: Stream.periodic(_refreshInterval),
      builder: (context, snapshot) {
        return Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Column(
            children: [
              _buildStatusRow(
                'Status',
                _controller.isPlaying ? 'Playing' : 'Paused',
                _controller.isPlaying ? Colors.green : Colors.orange,
              ),
              const SizedBox(height: 2),
              _buildStatusRow(
                'Position',
                '${_formatDuration(_controller.position)} / ${_formatDuration(_controller.duration)}',
                Colors.black87,
              ),
              const SizedBox(height: 2),
              _buildStatusRow(
                'Progress',
                '${(_controller.positionPercentage * 100).toStringAsFixed(1)}%',
                Colors.blue,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatusRow(String label, String value, Color valueColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '$label:',
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.black54,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}
