import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../utils/constants/color_constants.dart';
import '../../utils/constants/string_constants.dart';
import '../blocs/game_cubit/game_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../utils/routing/route_names.dart';
import 'animated_border_container.dart';
import '../../data/controllers/audio_controller.dart';

class PauseMenuWidget extends StatelessWidget {
  const PauseMenuWidget({super.key, required this.onClose, required this.musicOn, required this.soundOn});
  final VoidCallback onClose;
  final ValueNotifier<bool> musicOn;
  final ValueNotifier<bool> soundOn;

  @override
  Widget build(BuildContext context) {
    final gameCubit = context.read<GameCubit>();
    return AnimatedBorderContainer(
      gradientColors: const [
        ColorConstants.color2387FC,
        ColorConstants.color448AFF,
        ColorConstants.colorFFD740,
      ],
      darkOverlayColor: ColorConstants.color8A000000,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            StringConstants.pausedTitle,
            style: const TextStyle(
              fontSize: 32,
              color: ColorConstants.colorFFFFFF,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _PauseIconButton(
                icon: Icons.play_arrow,
                tooltip: StringConstants.resume,
                onTap: () {
                  gameCubit.resumeGame();
                  onClose();
                },
              ),
              const SizedBox(width: 16),
              _PauseIconButton(
                icon: Icons.refresh,
                tooltip: StringConstants.restart,
                onTap: () {
                  gameCubit.restartGame();
                  onClose();
                },
              ),
              const SizedBox(width: 16),
              _PauseIconButton(
                icon: Icons.home,
                tooltip: StringConstants.exitToMenu,
                onTap: () {
                  Navigator.of(context).pushReplacementNamed(RouteNames.welcomeScreen);
                  onClose();
                },
              ),
            ],
          ),
          const SizedBox(height: 28),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _AudioToggleIcon(
                listenable: musicOn,
                activeIcon: Icons.music_note,
                inactiveIcon: Icons.music_off,
                tooltipOn: StringConstants.musicOn,
                tooltipOff: StringConstants.musicOff,
                onToggle: () {
                  final newVal = !musicOn.value;
                  musicOn.value = newVal;
                  AudioController().setMusic(newVal);
                },
              ),
              const SizedBox(width: 20),
              _AudioToggleIcon(
                listenable: soundOn,
                activeIcon: Icons.volume_up,
                inactiveIcon: Icons.volume_off,
                tooltipOn: StringConstants.soundOn,
                tooltipOff: StringConstants.soundOff,
                onToggle: () {
                  final newVal = !soundOn.value;
                  soundOn.value = newVal;
                  AudioController().setSound(newVal);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PauseIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final String tooltip;
  const _PauseIconButton({required this.icon, required this.onTap, required this.tooltip});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: ColorConstants.color2387FC,
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(
                color: ColorConstants.shimmerShadow,
                blurRadius: 6,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Tooltip(
            message: tooltip,
            child: Icon(
              icon,
              color: ColorConstants.colorFFFFFF,
              size: 28,
            ),
          ),
        ),
      ),
    );
  }
}

class _AudioToggleIcon extends StatelessWidget {
  const _AudioToggleIcon({
    required this.listenable,
    required this.activeIcon,
    required this.inactiveIcon,
    required this.tooltipOn,
    required this.tooltipOff,
    required this.onToggle,
  });
  final ValueListenable<bool> listenable;
  final IconData activeIcon;
  final IconData inactiveIcon;
  final String tooltipOn;
  final String tooltipOff;
  final VoidCallback onToggle;
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: listenable,
      builder: (context, isOn, _) {
        final bgColor = isOn ? ColorConstants.colorFFD740 : ColorConstants.color9E9E9E;
        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onToggle,
            borderRadius: BorderRadius.circular(16),
            child: Ink(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(
                    color: ColorConstants.shimmerShadow,
                    blurRadius: 6,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Tooltip(
                message: isOn ? tooltipOn : tooltipOff,
                child: Icon(
                  isOn ? activeIcon : inactiveIcon,
                  color: ColorConstants.colorFFFFFF, // always white now
                  size: 28,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
