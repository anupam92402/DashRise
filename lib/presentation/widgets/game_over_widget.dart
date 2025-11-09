import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../utils/constants/color_constants.dart';
import '../../utils/constants/string_constants.dart';
import '../blocs/game_cubit/game_cubit.dart';
import 'animated_border_container.dart';

class GameOverWidget extends StatefulWidget {
  const GameOverWidget({super.key});

  @override
  State<GameOverWidget> createState() => _GameOverWidgetState();
}

class _GameOverWidgetState extends State<GameOverWidget>
    with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GameCubit, GameState>(
      builder: (context, state) {
        return AnimatedBorderContainer(
          gradientColors: const [
            ColorConstants.colorFFD740,
            ColorConstants.colorFFFFFF,
            ColorConstants.color2387FC,
          ],
          darkOverlayColor: ColorConstants.color8A000000,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                StringConstants.gameOver,
                style: TextStyle(
                  color: ColorConstants.colorFFCA00,
                  fontWeight: FontWeight.bold,
                  fontSize: 48,
                  letterSpacing: 2,
                ),
              ),
              Text(
                '${StringConstants.score} ${state.currentScore}',
                style: const TextStyle(
                  color: ColorConstants.colorFFFFFF,
                  fontSize: 22,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 54),
              ElevatedButton(
                onPressed: () {
                  BlocProvider.of<GameCubit>(context).restartGame();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColorConstants.color2387FC,
                  foregroundColor: ColorConstants.colorFFFFFF,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 28,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                child: Text(
                  StringConstants.playAgain,
                  style: const TextStyle(
                    fontSize: 22,
                    letterSpacing: 2,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
