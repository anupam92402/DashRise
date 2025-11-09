import 'package:dash_rise/presentation/widgets/game_over_widget.dart';
import 'package:dash_rise/presentation/widgets/game_start_text_widget.dart';
import 'package:dash_rise/presentation/widgets/score_widget.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/game_cubit/game_cubit.dart';
import '../../flappy_bird_game.dart';
import '../../data/controllers/audio_controller.dart';
import '../../utils/constants/color_constants.dart';
import '../widgets/pause_menu_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  late FlappyBirdGame _flappyBirdGame;
  late GameCubit gameCubit;
  PlayingState? latestState;

  // Replace bools with ValueNotifiers
  final ValueNotifier<bool> _musicOn = ValueNotifier<bool>(true);
  final ValueNotifier<bool> _soundOn = ValueNotifier<bool>(true);
  final ValueNotifier<bool> _showPauseMenu = ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
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
    WidgetsBinding.instance.removeObserver(this);
    _musicOn.dispose();
    _soundOn.dispose();
    _showPauseMenu.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final audio = AudioController();
    if (state == AppLifecycleState.paused) {
      audio.stopBackground();
    } else if (state == AppLifecycleState.resumed) {
      if (audio.musicEnabled.value) {
        audio.playBackgroundLoop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<GameCubit, GameState>(
      listener: (context, state) {
        if (state.currentPlayingState == PlayingState.idle &&
            (latestState == PlayingState.gameOver || latestState == PlayingState.paused)) {
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
              // Show pause menu if explicitly requested or game is paused
              ValueListenableBuilder<bool>(
                valueListenable: _showPauseMenu,
                builder: (context, show, _) {
                  if (!show && state.currentPlayingState != PlayingState.paused) {
                    return const SizedBox.shrink();
                  }
                  return PauseMenuWidget(
                    onClose: () => _showPauseMenu.value = false,
                    musicOn: _musicOn,
                    soundOn: _soundOn,
                  );
                },
              ),
              if (state.currentPlayingState != PlayingState.gameOver)
                Positioned(
                  top: topPadding + 8,
                  left: 12,
                  child: _PauseButton(
                    onTap: () {
                      if (state.currentPlayingState == PlayingState.playing) {
                        gameCubit.pauseGame();
                        _showPauseMenu.value = true;
                      } else if (state.currentPlayingState == PlayingState.paused) {
                        gameCubit.resumeGame();
                        _showPauseMenu.value = false;
                      } else {
                        _showPauseMenu.value = !_showPauseMenu.value;
                      }
                    },
                    isPaused: state.currentPlayingState == PlayingState.paused || _showPauseMenu.value,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _PauseButton extends StatelessWidget {
  final VoidCallback onTap;
  final bool isPaused;
  const _PauseButton({required this.onTap, required this.isPaused});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: ColorConstants.color9E9E9E.withValues(alpha: 0.35),
          ),
          padding: const EdgeInsets.all(10),
          child: Icon(
            isPaused ? Icons.play_arrow : Icons.pause,
            color: ColorConstants.colorFFFFFF,
            size: 28,
          ),
        ),
      ),
    );
  }
}
