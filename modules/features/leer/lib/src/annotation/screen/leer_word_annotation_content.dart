import 'package:flutter/material.dart';
import 'package:shared_ui/shared_ui.dart';

import '../bloc/leer_word_annotation_bloc.dart';
import '../widgets/word_annotation_card.dart';

class LeerWordAnnotationContent extends StatelessWidget {
  const LeerWordAnnotationContent({super.key});

  @override
  Widget build(BuildContext context) {
    final LeerWordAnnotationBloc bloc = context.read<LeerWordAnnotationBloc>();

    return Material(
      type: MaterialType.transparency,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => bloc.add(const ClosePressed()),
        // Anchored to the bottom so the line being read stays in view above it.
        child: Align(
          alignment: Alignment.bottomCenter,
          child: BlocBuilder<LeerWordAnnotationBloc, LeerWordAnnotationState>(
            builder: (BuildContext context, LeerWordAnnotationState state) {
              if (state.isLoading) return const SizedBox.shrink();

              return WordAnnotationCard(
                word: state.word,
                isInDictionary: state.isInDictionary,
                isAdding: state.isAdding,
                error: state.error,
                onAddPressed: () => bloc.add(const AddPressed()),
                onClosePressed: () => bloc.add(const ClosePressed()),
              );
            },
          ),
        ),
      ),
    );
  }
}
