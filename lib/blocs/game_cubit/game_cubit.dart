import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../data/local_storage/score_storage.dart';

part 'game_state.dart';

class GameCubit extends Cubit<GameState> {
  GameCubit() : super(const GameState());

  void startPlaying() {
    emit(
      state.copyWith(
        currentPlayingState: PlayingState.playing,
        currentScore: 0,
      ),
    );
  }

  void increaseScore() {
    emit(state.copyWith(currentScore: state.currentScore + 1));
  }

  void gameOver() {
    // Store last score and update highest score if needed
    ScoreStorage.saveLastScore(state.currentScore);
    ScoreStorage.saveHighestScore(state.currentScore);
    emit(state.copyWith(currentPlayingState: PlayingState.gameOver));
  }

  void restartGame() {
    emit(
      state.copyWith(currentPlayingState: PlayingState.idle, currentScore: 0),
    );
  }
}
