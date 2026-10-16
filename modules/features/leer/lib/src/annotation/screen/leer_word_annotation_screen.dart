import 'package:auto_route/auto_route.dart';
import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:shared_ui/shared_ui.dart';

import '../../navigation/leer_navigator.dart';
import '../bloc/leer_word_annotation_bloc.dart';
import 'leer_word_annotation_content.dart';

@RoutePage()
class LeerWordAnnotationScreen extends StatelessWidget {
  final String wordId;

  const LeerWordAnnotationScreen({
    super.key,
    required this.wordId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider<LeerWordAnnotationBloc>(
      create: (BuildContext context) {
        return LeerWordAnnotationBloc(
          wordId: wordId,
          getLunfardoWordUseCase: context.resolve<GetLunfardoWordUseCase>(),
          isWordInDictionaryUseCase: context.resolve<IsWordInDictionaryUseCase>(),
          addWordToDictionaryUseCase: context.resolve<AddWordToDictionaryUseCase>(),
          navigator: context.resolve<LeerNavigator>(),
        )..add(const AnnotationStarted());
      },
      child: const LeerWordAnnotationContent(),
    );
  }
}
