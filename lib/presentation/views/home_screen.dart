
import 'package:dash_rise/presentation/widgets/game_over_widget.dart';
import 'package:dash_rise/presentation/widgets/game_start_text_widget.dart';
import 'package:dash_rise/presentation/widgets/score_widget.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';

import '../../blocs/game_cubit/game_cubit.dart';
import '../../flappy_bird_game.dart';
import '../../utils/audio_controller.dart';
import '../../utils/constants/color_constants.dart';
import '../../utils/constants/string_constants.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late FlappyBirdGame _flappyBirdGame;
  late GameCubit gameCubit;
  PlayingState? latestState;

  // Replace bools with ValueNotifiers
  final ValueNotifier<bool> _musicOn = ValueNotifier<bool>(true);
  final ValueNotifier<bool> _soundOn = ValueNotifier<bool>(true);

  @override
  void initState() {
    super.initState();
    gameCubit = BlocProvider.of<GameCubit>(context);
    _flappyBirdGame = FlappyBirdGame(gameCubit: gameCubit);
    _initAudio();
  }

  void _initAudio() async {
    final audio = AudioController();
    await audio.init();
    _musicOn.value = audio.musicEnabled.value;
    _soundOn.value = audio.soundEnabled.value;
    if (_musicOn.value) {
      audio.playBackgroundLoop();
    }
  }

  @override
  void dispose() {
    _musicOn.dispose();
    _soundOn.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<GameCubit, GameState>(
      listener: (context, state) {
        if (state.currentPlayingState == PlayingState.idle &&
            latestState == PlayingState.gameOver) {
          setState(() {
            _flappyBirdGame = FlappyBirdGame(gameCubit: gameCubit);
          });
        }
        latestState = state.currentPlayingState;
      },
      builder: (BuildContext context, GameState state) {
        final topPadding = MediaQuery.of(context).padding.top; // dynamic top spacing
        return Scaffold(
          body: Stack(
            children: [
              GameWidget(game: _flappyBirdGame),
              if (state.currentPlayingState == PlayingState.gameOver)
                GameOverWidget(),
              if (state.currentPlayingState == PlayingState.idle)
                GameStartTextWidget(),
              if (state.currentPlayingState != PlayingState.gameOver)
                ScoreWidget(score: state.currentScore.toString()),
              // Top-right music & sound toggles (placed last for highest z-order)
              _AudioTogglePanel(
                topPadding: topPadding,
                musicOn: _musicOn,
                soundOn: _soundOn,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _AudioTogglePanel extends StatelessWidget {
  final double topPadding;
  final ValueNotifier<bool> musicOn;
  final ValueNotifier<bool> soundOn;
  const _AudioTogglePanel({
    required this.topPadding,
    required this.musicOn,
    required this.soundOn,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: topPadding,
      right: 12,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ToggleIcon(
            stateListenable: musicOn,
            onIcon: Icons.music_note,
            offIcon: Icons.music_off,
            tooltipOn: StringConstants.musicOn,
            tooltipOff: StringConstants.musicOff,
            onToggle: () {
              musicOn.value = !musicOn.value;
              AudioController().setMusic(musicOn.value);
              debugPrint(StringConstants.musicToggledPrefix + musicOn.value.toString());
            },
          ),
          const SizedBox(height: 16),
          _ToggleIcon(
            stateListenable: soundOn,
            onIcon: Icons.volume_up,
            offIcon: Icons.volume_off,
            tooltipOn: StringConstants.soundOn,
            tooltipOff: StringConstants.soundOff,
            onToggle: () {
              soundOn.value = !soundOn.value;
              AudioController().setSound(soundOn.value);
              debugPrint(StringConstants.soundToggledPrefix + soundOn.value.toString());
            },
          ),
        ],
      ),
    );
  }
}

class _ToggleIcon extends StatelessWidget {
  final ValueListenable<bool> stateListenable;
  final IconData onIcon;
  final IconData offIcon;
  final VoidCallback onToggle;
  final String tooltipOn;
  final String tooltipOff;
  const _ToggleIcon({
    required this.stateListenable,
    required this.onIcon,
    required this.offIcon,
    required this.onToggle,
    required this.tooltipOn,
    required this.tooltipOff,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: stateListenable,
      builder: (context, isOn, _) {
        return Material(
          color: ColorConstants.shimmerContainer,
          shape: const CircleBorder(),
          child: Tooltip(
            message: isOn ? tooltipOn : tooltipOff,
            child: IconButton(
              onPressed: onToggle,
              icon: Icon(isOn ? onIcon : offIcon),
              color: ColorConstants.colorIconWhite,
              iconSize: 28,
              splashRadius: 24,
            ),
          ),
        );
      },
    );
  }
}
