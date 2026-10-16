part of 'hablar_dictionary_bloc.dart';

sealed class HablarDictionaryEvent {
  const HablarDictionaryEvent();
}

final class DictionaryStarted extends HablarDictionaryEvent {
  const DictionaryStarted();
}

final class WordPressed extends HablarDictionaryEvent {
  final String wordId;

  const WordPressed(this.wordId);
}

final class DictionaryBackPressed extends HablarDictionaryEvent {
  const DictionaryBackPressed();
}
