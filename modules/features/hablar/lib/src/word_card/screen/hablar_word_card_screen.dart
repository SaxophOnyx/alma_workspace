import 'package:auto_route/auto_route.dart';
import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:shared_ui/shared_ui.dart';

import '../../navigation/hablar_navigator.dart';
import '../bloc/hablar_word_card_bloc.dart';
import 'hablar_word_card_content.dart';

@RoutePage()
class HablarWordCardScreen extends StatelessWidget {
  /// The word to show; `null` shows the word of the day.
  final String? wordId;

  const HablarWordCardScreen({
    super.key,
    this.wordId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider<HablarWordCardBloc>(
      create: (BuildContext context) {
        return HablarWordCardBloc(
          wordId: wordId,
          getWordOfTheDayUseCase: context.resolve<GetWordOfTheDayUseCase>(),
          getLunfardoWordUseCase: context.resolve<GetLunfardoWordUseCase>(),
          isWordInDictionaryUseCase: context.resolve<IsWordInDictionaryUseCase>(),
          addWordToDictionaryUseCase: context.resolve<AddWordToDictionaryUseCase>(),
          markWordEncounteredUseCase: context.resolve<MarkWordEncounteredUseCase>(),
          navigator: context.resolve<HablarNavigator>(),
        )..add(const WordCardStarted());
      },
      child: const HablarWordCardContent(),
    );
  }
}
