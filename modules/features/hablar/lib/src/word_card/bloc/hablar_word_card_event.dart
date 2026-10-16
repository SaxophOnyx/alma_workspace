part of 'hablar_word_card_bloc.dart';

sealed class HablarWordCardEvent {
  const HablarWordCardEvent();
}

final class WordCardStarted extends HablarWordCardEvent {
  const WordCardStarted();
}

final class AddPressed extends HablarWordCardEvent {
  const AddPressed();
}

final class OpenTextPressed extends HablarWordCardEvent {
  const OpenTextPressed();
}

final class WordCardBackPressed extends HablarWordCardEvent {
  const WordCardBackPressed();
}
